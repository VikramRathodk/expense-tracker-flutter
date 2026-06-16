import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import 'app_routes.dart';
import 'route_guards.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthChangeNotifier(_authBloc),
    redirect: authGuard,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      // Placeholder dashboard — will be replaced by ShellRoute + real screens in Phase 3
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (_, _) => const _PlaceholderDashboard(),
      ),
    ],
  );
}

/// Bridges AuthBloc stream changes to GoRouter's refresh mechanism so
/// the auth guard re-evaluates whenever auth state changes.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}

class _PlaceholderDashboard extends StatelessWidget {
  const _PlaceholderDashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(
        child: Text(
          'Dashboard — Phase 3',
          style: TextStyle(fontSize: 18, color: Color(0xFF64748B)),
        ),
      ),
    );
  }
}
