import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/mixins/form_validation_mixin.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          context.showErrorSnackBar(state.message);
        }
        // Successful navigation is handled by GoRouter's authGuard
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xxl,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        // Header
                        Text(
                          'Create account',
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Start tracking your expenses today',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Name field
                        AppTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'John Doe',
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          enabled: !isLoading,
                          autofillHints: const [AutofillHints.name],
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_emailFocusNode),
                          validator: validateName,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Email field
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          focusNode: _emailFocusNode,
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          enabled: !isLoading,
                          autofillHints: const [AutofillHints.email],
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(_passwordFocusNode),
                          validator: validateEmail,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Password field
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          focusNode: _passwordFocusNode,
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          enabled: !isLoading,
                          autofillHints: const [AutofillHints.newPassword],
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(_confirmPasswordFocusNode),
                          validator: validatePassword,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Confirm password field
                        AppTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          focusNode: _confirmPasswordFocusNode,
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          enabled: !isLoading,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (value) => validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Register button
                        AppButton(
                          label: 'Create Account',
                          isLoading: isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            AppButton(
                              label: 'Sign In',
                              variant: AppButtonVariant.text,
                              onPressed: isLoading
                                  ? null
                                  : () => context.go(AppRoutes.login),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
