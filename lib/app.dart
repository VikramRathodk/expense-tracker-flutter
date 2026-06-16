import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config/app_theme.dart';
import 'core/constants/api_constants.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
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
    // Plain Dio (no auth interceptor) — used for the token refresh call
    // inside AuthInterceptor to avoid interceptor recursion.
    final plainDio = DioClient.plain();

    // Main Dio with AuthInterceptor. The onLogout closure safely captures
    // `_authBloc` via the late variable — by the time onLogout is ever
    // called at runtime, _authBloc is already assigned below.
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

    // ── Auth feature wiring ────────────────────────────────────────────────
    final authDataSource = AuthRemoteDataSource(mainDio);
    final authRepository = AuthRepositoryImpl(authDataSource, _storage);

    _authBloc = AuthBloc(repository: authRepository, storage: _storage);
    _appRouter = AppRouter(_authBloc);
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
        themeMode: ThemeMode.light, // Phase 4: wire to ThemeCubit
        routerConfig: _appRouter.router,
      ),
    );
  }
}
