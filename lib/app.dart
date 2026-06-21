import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() {
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
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
      ],
      child: MaterialApp.router(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
