import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/budgets/domain/models/budget_model.dart';
import '../features/budgets/presentation/cubit/budget_form_cubit.dart';
import '../features/budgets/presentation/cubit/budget_list_cubit.dart';
import '../features/budgets/presentation/screens/add_edit_budget_screen.dart';
import '../features/budgets/presentation/screens/budget_list_screen.dart';
import '../features/categories/presentation/cubit/category_cubit.dart';
import '../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/expenses/domain/models/expense_model.dart';
import '../features/expenses/presentation/cubit/expense_form_cubit.dart';
import '../features/expenses/presentation/cubit/expense_list_cubit.dart';
import '../features/expenses/presentation/screens/add_edit_expense_screen.dart';
import '../features/expenses/presentation/screens/expense_list_screen.dart';
import '../features/recurring/domain/models/recurring_expense_model.dart';
import '../features/recurring/presentation/cubit/recurring_form_cubit.dart';
import '../features/recurring/presentation/cubit/recurring_list_cubit.dart';
import '../features/recurring/presentation/screens/add_edit_recurring_screen.dart';
import '../features/recurring/presentation/screens/recurring_list_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/shell/shell_screen.dart';
import 'app_routes.dart';
import 'route_guards.dart';

class AppRouter {
  AppRouter._(this._authBloc, this._cubits);

  factory AppRouter.create({
    required AuthBloc authBloc,
    required DashboardCubit Function() dashboardCubit,
    required ExpenseListCubit Function() expenseListCubit,
    required ExpenseFormCubit Function() expenseFormCubit,
    required CategoryCubit Function() categoryCubit,
    required BudgetListCubit Function() budgetListCubit,
    required BudgetFormCubit Function() budgetFormCubit,
    required RecurringListCubit Function() recurringListCubit,
    required RecurringFormCubit Function() recurringFormCubit,
  }) {
    return AppRouter._(
      authBloc,
      _RouterCubits(
        dashboardCubit: dashboardCubit,
        expenseListCubit: expenseListCubit,
        expenseFormCubit: expenseFormCubit,
        categoryCubit: categoryCubit,
        budgetListCubit: budgetListCubit,
        budgetFormCubit: budgetFormCubit,
        recurringListCubit: recurringListCubit,
        recurringFormCubit: recurringFormCubit,
      ),
    );
  }

  final AuthBloc _authBloc;
  final _RouterCubits _cubits;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthChangeNotifier(_authBloc),
    redirect: authGuard,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, s) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, s) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, s) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, s) => const RegisterScreen(),
      ),

      // ── Authenticated shell (bottom nav) ──────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, s, navigationShell) =>
            ShellScreen(navigationShell: navigationShell),
        branches: [
          // Tab 0 — Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, s) => BlocProvider(
                  create: (_) => _cubits.dashboardCubit(),
                  child: const DashboardScreen(),
                ),
              ),
            ],
          ),

          // Tab 1 — Expenses
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.expenses,
                builder: (context, s) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                        create: (_) => _cubits.expenseListCubit()),
                    BlocProvider(
                        create: (_) => _cubits.categoryCubit()),
                  ],
                  child: const ExpenseListScreen(),
                ),
                routes: [
                  // Add expense
                  GoRoute(
                    path: 'new',
                    builder: (context, s) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                            create: (_) => _cubits.expenseFormCubit()),
                        BlocProvider(
                            create: (_) => _cubits.categoryCubit()),
                      ],
                      child: const AddEditExpenseScreen(),
                    ),
                  ),
                  // Edit expense — expense passed via extra
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) {
                      final expense = state.extra as ExpenseModel?;
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider(
                              create: (_) => _cubits.expenseFormCubit()),
                          BlocProvider(
                              create: (_) => _cubits.categoryCubit()),
                        ],
                        child: AddEditExpenseScreen(expense: expense),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Tab 2 — Budgets
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.budgets,
                builder: (context, s) => BlocProvider(
                  create: (_) => _cubits.budgetListCubit(),
                  child: const BudgetListScreen(),
                ),
                routes: [
                  // Add budget
                  GoRoute(
                    path: 'new',
                    builder: (context, s) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                            create: (_) => _cubits.budgetFormCubit()),
                        BlocProvider(
                            create: (_) => _cubits.categoryCubit()),
                      ],
                      child: const AddEditBudgetScreen(),
                    ),
                  ),
                  // Edit budget — BudgetModel passed via extra
                  GoRoute(
                    path: ':id/edit',
                    builder: (context, state) {
                      final budget = state.extra as BudgetModel?;
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider(
                              create: (_) => _cubits.budgetFormCubit()),
                          BlocProvider(
                              create: (_) => _cubits.categoryCubit()),
                        ],
                        child: AddEditBudgetScreen(budget: budget),
                      );
                    },
                  ),
                  // Recurring list (pushed from budgets AppBar action)
                  GoRoute(
                    path: 'recurring',
                    builder: (context, s) => BlocProvider(
                      create: (_) => _cubits.recurringListCubit(),
                      child: const RecurringListScreen(),
                    ),
                    routes: [
                      // Add recurring
                      GoRoute(
                        path: 'new',
                        builder: (context, s) => MultiBlocProvider(
                          providers: [
                            BlocProvider(
                                create: (_) =>
                                    _cubits.recurringFormCubit()),
                            BlocProvider(
                                create: (_) => _cubits.categoryCubit()),
                          ],
                          child: const AddEditRecurringScreen(),
                        ),
                      ),
                      // Edit recurring — RecurringExpenseModel passed via extra
                      GoRoute(
                        path: ':id/edit',
                        builder: (context, state) {
                          final item =
                              state.extra as RecurringExpenseModel?;
                          return MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                  create: (_) =>
                                      _cubits.recurringFormCubit()),
                              BlocProvider(
                                  create: (_) =>
                                      _cubits.categoryCubit()),
                            ],
                            child: AddEditRecurringScreen(item: item),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Tab 3 — Profile (Phase 5 placeholder)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, s) => const _PlaceholderScreen(
                  title: 'Profile',
                  subtitle: 'Profile & settings coming in Phase 5.',
                  icon: Icons.person_outline,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _RouterCubits {
  _RouterCubits({
    required this.dashboardCubit,
    required this.expenseListCubit,
    required this.expenseFormCubit,
    required this.categoryCubit,
    required this.budgetListCubit,
    required this.budgetFormCubit,
    required this.recurringListCubit,
    required this.recurringFormCubit,
  });

  final DashboardCubit Function() dashboardCubit;
  final ExpenseListCubit Function() expenseListCubit;
  final ExpenseFormCubit Function() expenseFormCubit;
  final CategoryCubit Function() categoryCubit;
  final BudgetListCubit Function() budgetListCubit;
  final BudgetFormCubit Function() budgetFormCubit;
  final RecurringListCubit Function() recurringListCubit;
  final RecurringFormCubit Function() recurringFormCubit;
}

/// Bridges AuthBloc stream changes to GoRouter's refresh mechanism.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700))),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

