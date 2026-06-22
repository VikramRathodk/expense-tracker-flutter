import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/core/errors/network_exception.dart';
import 'package:expense_tracker/features/dashboard/domain/models/dashboard_summary_model.dart';
import 'package:expense_tracker/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:expense_tracker/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late _MockDashboardRepository repo;

  final tSummary = DashboardSummaryModel(
    totalSpent: 5000.0,
    totalBudget: 10000.0,
    currency: 'INR',
    period: '2024-01',
    categoryBreakdown: const [],
    recentExpenses: const [],
    monthlyTrend: const [],
  );

  setUp(() => repo = _MockDashboardRepository());

  DashboardCubit build() => DashboardCubit(repo);

  group('loadSummary', () {
    blocTest<DashboardCubit, DashboardState>(
      'emits [Loading, Loaded] on success',
      build: build,
      setUp: () => when(() => repo.getSummary(period: any(named: 'period')))
          .thenAnswer((_) async => tSummary),
      act: (c) => c.loadSummary(),
      expect: () => [isA<DashboardLoading>(), isA<DashboardLoaded>()],
      verify: (c) {
        expect((c.state as DashboardLoaded).summary.totalSpent, 5000.0);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits [Loading, Error] on network failure',
      build: build,
      setUp: () => when(() => repo.getSummary(period: any(named: 'period')))
          .thenThrow(const NetworkException()),
      act: (c) => c.loadSummary(),
      expect: () => [isA<DashboardLoading>(), isA<DashboardError>()],
    );

    blocTest<DashboardCubit, DashboardState>(
      'refresh reloads with the same period',
      build: build,
      setUp: () => when(() => repo.getSummary(period: any(named: 'period')))
          .thenAnswer((_) async => tSummary),
      act: (c) async {
        await c.loadSummary(period: '2024-01');
        await c.refresh();
      },
      verify: (_) => verify(() => repo.getSummary(period: '2024-01')).called(2),
    );
  });
}