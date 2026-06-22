import 'package:bloc_test/bloc_test.dart';
import 'package:expense_tracker/features/budgets/domain/models/budget_model.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/presentation/cubit/budget_list_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late _MockBudgetRepository repo;

  final tBudget = BudgetModel(
    id: 1,
    amount: 10000.0,
    spentAmount: 3000.0,
    period: '2024-01',
    currency: 'INR',
    category: null,
  );

  setUp(() => repo = _MockBudgetRepository());

  BudgetListCubit build() => BudgetListCubit(repo);

  group('loadBudgets', () {
    blocTest<BudgetListCubit, BudgetListState>(
      'emits [Loading, Loaded] on success',
      build: build,
      setUp: () => when(() => repo.getBudgets(period: any(named: 'period')))
          .thenAnswer((_) async => [tBudget]),
      act: (c) => c.loadBudgets(),
      expect: () => [isA<BudgetListLoading>(), isA<BudgetListLoaded>()],
      verify: (c) {
        final loaded = c.state as BudgetListLoaded;
        expect(loaded.budgets.length, 1);
        expect(loaded.overallBudget?.id, 1);
      },
    );

    blocTest<BudgetListCubit, BudgetListState>(
      'emits [Loading, Error] on failure',
      build: build,
      setUp: () => when(() => repo.getBudgets(period: any(named: 'period')))
          .thenThrow(Exception('Server error')),
      act: (c) => c.loadBudgets(),
      expect: () => [isA<BudgetListLoading>(), isA<BudgetListError>()],
    );
  });

  group('deleteBudget', () {
    blocTest<BudgetListCubit, BudgetListState>(
      'removes budget optimistically and confirms on success',
      build: build,
      seed: () => BudgetListLoaded([tBudget], '2024-01'),
      setUp: () => when(() => repo.deleteBudget(any())).thenAnswer((_) async {}),
      act: (c) => c.deleteBudget(1),
      expect: () => [
        isA<BudgetListLoaded>(),
      ],
      verify: (c) {
        final loaded = c.state as BudgetListLoaded;
        expect(loaded.budgets, isEmpty);
      },
    );

    blocTest<BudgetListCubit, BudgetListState>(
      'restores budget on delete failure',
      build: build,
      seed: () => BudgetListLoaded([tBudget], '2024-01'),
      setUp: () =>
          when(() => repo.deleteBudget(any())).thenThrow(Exception('Failed')),
      act: (c) => c.deleteBudget(1),
      errors: () => [isA<Exception>()],
      expect: () => [
        isA<BudgetListLoaded>(), // optimistic empty
        isA<BudgetListLoaded>(), // restored
      ],
    );
  });
}