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
import '../features/categories/presentation/cubit/category_manage_cubit.dart';
import '../features/categories/presentation/screens/category_list_screen.dart';
import '../features/tags/presentation/cubit/tag_cubit.dart';
import '../features/tags/presentation/screens/tag_list_screen.dart';
import '../features/notifications/presentation/cubit/notification_cubit.dart';
import '../features/notifications/presentation/screens/notification_screen.dart';
import '../features/reports/presentation/cubit/report_cubit.dart';
import '../features/reports/presentation/screens/report_screen.dart';
import '../features/audit_logs/presentation/cubit/audit_log_cubit.dart';
import '../features/audit_logs/presentation/screens/audit_log_screen.dart';
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
import '../features/profile/presentation/cubit/profile_cubit.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
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
    required ProfileCubit Function() profileCubit,
    required CategoryManageCubit Function() categoryManageCubit,
    required TagCubit Function() tagCubit,
    required NotificationCubit Function() notificationCubit,
    required ReportCubit Function() reportCubit,
    required AuditLogCubit Function() auditLogCubit,
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
        profileCubit: profileCubit,
        categoryManageCubit: categoryManageCubit,
        tagCubit: tagCubit,
        notificationCubit: notificationCubit,
        reportCubit: reportCubit,
        auditLogCubit: auditLogCubit,
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

      // ── Top-level push routes (shown over the shell) ─────────────────────
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, s) => BlocProvider(
          create: (_) => _cubits.categoryManageCubit(),
          child: const CategoryListScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.tags,
        builder: (context, s) => BlocProvider(
          create: (_) => _cubits.tagCubit(),
          child: const TagListScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, s) => BlocProvider(
          create: (_) => _cubits.notificationCubit(),
          child: const NotificationScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (context, s) => BlocProvider(
          create: (_) => _cubits.reportCubit(),
          child: const ReportScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.auditLogs,
        builder: (context, s) => BlocProvider(
          create: (_) => _cubits.auditLogCubit(),
          child: const AuditLogScreen(),
        ),
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

          // Tab 3 — Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, s) => BlocProvider(
                  create: (_) => _cubits.profileCubit(),
                  child: const ProfileScreen(),
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
    required this.profileCubit,
    required this.categoryManageCubit,
    required this.tagCubit,
    required this.notificationCubit,
    required this.reportCubit,
    required this.auditLogCubit,
  });

  final DashboardCubit Function() dashboardCubit;
  final ExpenseListCubit Function() expenseListCubit;
  final ExpenseFormCubit Function() expenseFormCubit;
  final CategoryCubit Function() categoryCubit;
  final BudgetListCubit Function() budgetListCubit;
  final BudgetFormCubit Function() budgetFormCubit;
  final RecurringListCubit Function() recurringListCubit;
  final RecurringFormCubit Function() recurringFormCubit;
  final ProfileCubit Function() profileCubit;
  final CategoryManageCubit Function() categoryManageCubit;
  final TagCubit Function() tagCubit;
  final NotificationCubit Function() notificationCubit;
  final ReportCubit Function() reportCubit;
  final AuditLogCubit Function() auditLogCubit;
}

/// Bridges AuthBloc stream changes to GoRouter's refresh mechanism.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}


