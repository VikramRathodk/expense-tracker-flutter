import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/mixins/form_validation_mixin.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) context.showErrorSnackBar(state.message);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF3730A3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Gradient header ──────────────────────────────────
                      const AuthHeader(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'Welcome Back',
                        subtitle: 'Sign in to continue',
                      ),

                      // ── White form card ──────────────────────────────────
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(36),
                            ),
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              28,
                              32,
                              28,
                              MediaQuery.of(context).viewInsets.bottom + 24,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Enter your credentials to access your account',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Email
                                  AppTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hint: 'you@example.com',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    prefixIcon: const Icon(
                                        Icons.email_outlined,
                                        size: 20),
                                    enabled: !isLoading,
                                    autofillHints: const [AutofillHints.email],
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(_passwordFocusNode),
                                    validator: validateEmail,
                                  ),
                                  const SizedBox(height: AppSpacing.md),

                                  // Password
                                  AppTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    focusNode: _passwordFocusNode,
                                    prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        size: 20),
                                    enabled: !isLoading,
                                    autofillHints: const [
                                      AutofillHints.password
                                    ],
                                    onFieldSubmitted: (_) => _submit(),
                                    validator: validatePassword,
                                  ),

                                  // Forgot password
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                      ),
                                      child: const Text(
                                        'Forgot password?',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),

                                  // Sign In button
                                  AuthSubmitButton(
                                    label: 'Sign In',
                                    isLoading: isLoading,
                                    onPressed: _submit,
                                  ),
                                  const SizedBox(height: AppSpacing.xl),

                                  const AuthOrDivider(),
                                  const SizedBox(height: AppSpacing.xl),

                                  // Register link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Don't have an account?",
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: isLoading
                                            ? null
                                            : () => context
                                                .go(AppRoutes.register),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                        ),
                                        child: const Text(
                                          'Create Account',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
