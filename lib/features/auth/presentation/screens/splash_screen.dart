import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../routes/app_routes.dart';
import '../../../onboarding/onboarding_service.dart';
import '../bloc/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    // Check onboarding, then restore session
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final seen = await OnboardingService.isComplete();
      if (!mounted) return;
      if (!seen) {
        context.go(AppRoutes.onboarding);
        return;
      }
      if (!mounted) return;
      context.read<AuthBloc>().add(AuthRestoreSession());
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // GoRouter's refreshListenable handles navigation on state change;
    // BlocListener here handles edge cases and shows errors.
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navigation is handled by GoRouter redirect — nothing to do here.
        // Keep listener for future deep-link or error toast handling.
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Expense Tracker',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Track every rupee, every day',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
