import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'features/categories/presentation/cubit/category_manage_cubit.dart';
import 'features/tags/data/datasources/tag_remote_datasource.dart';
import 'features/tags/data/repositories/tag_repository_impl.dart';
import 'features/tags/presentation/cubit/tag_cubit.dart';
import 'features/notifications/data/datasources/notification_remote_datasource.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/notifications/presentation/cubit/notification_cubit.dart';
import 'features/reports/data/datasources/report_remote_datasource.dart';
import 'features/reports/data/repositories/report_repository_impl.dart';
import 'features/reports/presentation/cubit/report_cubit.dart';
import 'features/audit_logs/data/datasources/audit_log_remote_datasource.dart';
import 'features/audit_logs/data/repositories/audit_log_repository_impl.dart';
import 'features/audit_logs/presentation/cubit/audit_log_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'shared/cubits/theme_cubit.dart';
import 'config/app_theme.dart';
import 'core/constants/api_constants.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/budgets/data/datasources/budget_remote_datasource.dart';
import 'features/budgets/data/repositories/budget_repository_impl.dart';
import 'features/budgets/presentation/cubit/budget_form_cubit.dart';
import 'features/budgets/presentation/cubit/budget_list_cubit.dart';
import 'features/categories/data/datasources/category_remote_datasource.dart';
import 'features/categories/data/repositories/category_repository_impl.dart';
import 'features/categories/presentation/cubit/category_cubit.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'features/expenses/data/datasources/expense_remote_datasource.dart';
import 'features/expenses/data/repositories/expense_repository_impl.dart';
import 'features/expenses/presentation/cubit/expense_form_cubit.dart';
import 'features/expenses/presentation/cubit/expense_list_cubit.dart';
import 'features/recurring/data/datasources/recurring_remote_datasource.dart';
import 'features/recurring/data/repositories/recurring_repository_impl.dart';
import 'features/recurring/presentation/cubit/recurring_form_cubit.dart';
import 'features/recurring/presentation/cubit/recurring_list_cubit.dart';
import 'network/dio_client.dart';
import 'routes/app_router.dart';
import 'services/secure_storage_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final SecureStorageService _storage;
  late final AuthBloc _authBloc;
  late final AppRouter _appRouter;
  late final ThemeCubit _themeCubit;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
    _themeCubit = ThemeCubit();
    _storage = const SecureStorageService(FlutterSecureStorage());

    // ── Network setup ──────────────────────────────────────────────────────
    final plainDio = DioClient.plain();

    final mainDio = DioClient.create(
      getAccessToken: _storage.getAccessToken,
      refreshAccessToken: () async {
        final refreshToken = await _storage.getRefreshToken();
        if (refreshToken == null) return null;
        try {
          final response = await plainDio.post<Map<String, dynamic>>(
            ApiConstants.refresh,
            data: {'refreshToken': refreshToken},
          );
          final newToken = response.data!['accessToken'] as String;
          await _storage.saveAccessToken(newToken);
          return newToken;
        } on DioException catch (_) {
          return null;
        }
      },
      onLogout: () async {
        await _storage.clearAll();
        _authBloc.add(AuthLogoutRequested());
      },
    );

    // ── Auth feature ───────────────────────────────────────────────────────
    final authDataSource = AuthRemoteDataSource(mainDio);
    final authRepository = AuthRepositoryImpl(authDataSource, _storage);
    _authBloc = AuthBloc(repository: authRepository, storage: _storage);

    // ── Profile cubit factory (shares authRepository) ─────────────────────
    ProfileCubit makeProfileCubit() =>
        ProfileCubit(authRepository, _storage);

    // ── Feature repositories ───────────────────────────────────────────────
    final categoryDataSource = CategoryRemoteDataSource(mainDio);
    final categoryRepository = CategoryRepositoryImpl(categoryDataSource);

    final expenseDataSource = ExpenseRemoteDataSource(mainDio);
    final expenseRepository = ExpenseRepositoryImpl(expenseDataSource);

    final dashboardDataSource = DashboardRemoteDataSource(mainDio);
    final dashboardRepository = DashboardRepositoryImpl(dashboardDataSource);

    final budgetDataSource = BudgetRemoteDataSource(mainDio);
    final budgetRepository = BudgetRepositoryImpl(budgetDataSource);

    final recurringDataSource = RecurringRemoteDataSource(mainDio);
    final recurringRepository = RecurringRepositoryImpl(recurringDataSource);

    // ── Router ─────────────────────────────────────────────────────────────
    _appRouter = AppRouter.create(
      authBloc: _authBloc,
      dashboardCubit: () => DashboardCubit(dashboardRepository),
      expenseListCubit: () => ExpenseListCubit(expenseRepository),
      expenseFormCubit: () => ExpenseFormCubit(expenseRepository),
      categoryCubit: () => CategoryCubit(categoryRepository),
      budgetListCubit: () => BudgetListCubit(budgetRepository),
      budgetFormCubit: () => BudgetFormCubit(budgetRepository),
      recurringListCubit: () => RecurringListCubit(recurringRepository),
      recurringFormCubit: () => RecurringFormCubit(recurringRepository),
      profileCubit: makeProfileCubit,
      categoryManageCubit: () => CategoryManageCubit(categoryRepository),
      tagCubit: () => TagCubit(TagRepositoryImpl(TagRemoteDataSource(mainDio))),
      notificationCubit: () => NotificationCubit(
          NotificationRepositoryImpl(NotificationRemoteDataSource(mainDio))),
      reportCubit: () => ReportCubit(
          ReportRepositoryImpl(ReportRemoteDataSource(mainDio))),
      auditLogCubit: () => AuditLogCubit(
          AuditLogRepositoryImpl(AuditLogRemoteDataSource(mainDio))),
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    _themeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<ThemeCubit>.value(value: _themeCubit),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => MaterialApp.router(
          title: 'Expense Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}
