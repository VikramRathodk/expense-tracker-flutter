import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'app_routes.dart';

String? authGuard(BuildContext context, GoRouterState state) {
  final authState = context.read<AuthBloc>().state;
  final isAuthenticated = authState is AuthAuthenticated;
  final isAuthRoute = state.matchedLocation.startsWith(AppRoutes.login) ||
      state.matchedLocation.startsWith(AppRoutes.register);

  if (!isAuthenticated && !isAuthRoute) return AppRoutes.login;
  if (isAuthenticated && isAuthRoute) return AppRoutes.dashboard;
  return null;
}

GoRouterRedirect roleGuard(String requiredRole) {
  return (BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return AppRoutes.login;
    if (!authState.user.roles.contains(requiredRole)) {
      return AppRoutes.dashboard;
    }
    return null;
  };
}
