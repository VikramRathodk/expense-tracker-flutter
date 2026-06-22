import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/features/reports/domain/models/report_model.dart';
import 'package:expense_tracker/features/reports/domain/repositories/report_repository.dart';
import 'package:expense_tracker/features/reports/presentation/cubit/report_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockReportRepository extends Mock implements ReportRepository {}

void main() {
  late _MockReportRepository repo;

  final tSummary = ReportSummary(
    totalSpent: 8000.0,
    avgPerDay: 267.0,
    expenseCount: 30,
    currency: 'INR',
    startDate: '2024-01-01',
    endDate: '2024-01-31',
  );

  setUp(() {
    repo = _MockReportRepository();
    // Default stubs — each test can override
    when(() => repo.getSummary(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => tSummary);
    when(() => repo.getCategoryBreakdown(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
        )).thenAnswer((_) async => []);
    when(() => repo.getTrends(months: any(named: 'months')))
        .thenAnswer((_) async => []);
  });

  ReportCubit build() => ReportCubit(repo);

  group('load', () {
    blocTest<ReportCubit, ReportState>(
      'emits [Loading, Loaded] on success',
      build: build,
      act: (c) => c.load(),
      expect: () => [isA<ReportLoading>(), isA<ReportLoaded>()],
      verify: (c) {
        final loaded = c.state as ReportLoaded;
        expect(loaded.data.summary.totalSpent, 8000.0);
      },
    );

    blocTest<ReportCubit, ReportState>(
      'emits [Loading, Error] when summary fetch fails',
      build: build,
      setUp: () => when(() => repo.getSummary(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
          )).thenThrow(Exception('Server error')),
      act: (c) => c.load(),
      expect: () => [isA<ReportLoading>(), isA<ReportError>()],
    );
  });

  group('changeFilter', () {
    blocTest<ReportCubit, ReportState>(
      'reloads data with new period filter',
      build: build,
      act: (c) => c.changeFilter(ReportPeriod.thisYear),
      expect: () => [isA<ReportLoading>(), isA<ReportLoaded>()],
      verify: (c) {
        final loaded = c.state as ReportLoaded;
        expect(loaded.data.filter.period, ReportPeriod.thisYear);
      },
    );

    blocTest<ReportCubit, ReportState>(
      'requests 12 months of trends for thisYear period',
      build: build,
      act: (c) => c.changeFilter(ReportPeriod.thisYear),
      verify: (_) =>
          verify(() => repo.getTrends(months: 12)).called(1),
    );
  });
}