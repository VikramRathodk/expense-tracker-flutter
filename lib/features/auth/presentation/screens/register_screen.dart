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
                        icon: Icons.person_add_rounded,
                        title: 'Create Account',
                        subtitle: 'Start tracking your finances today',
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
                              28,
                              28,
                              MediaQuery.of(context).viewInsets.bottom + 24,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Your Details',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Fill in your information to get started',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Full Name
                                  AppTextField(
                                    controller: _nameController,
                                    label: 'Full Name',
                                    hint: 'John Doe',
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    prefixIcon: const Icon(
                                        Icons.person_outline,
                                        size: 20),
                                    enabled: !isLoading,
                                    autofillHints: const [AutofillHints.name],
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context)
                                            .requestFocus(_emailFocusNode),
                                    validator: validateName,
                                  ),
                                  const SizedBox(height: AppSpacing.md),

                                  // Email
                                  AppTextField(
                                    controller: _emailController,
                                    label: 'Email Address',
                                    hint: 'you@example.com',
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    focusNode: _emailFocusNode,
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
                                    textInputAction: TextInputAction.next,
                                    focusNode: _passwordFocusNode,
                                    prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        size: 20),
                                    enabled: !isLoading,
                                    autofillHints: const [
                                      AutofillHints.newPassword
                                    ],
                                    onFieldSubmitted: (_) =>
                                        FocusScope.of(context).requestFocus(
                                            _confirmPasswordFocusNode),
                                    validator: validatePassword,
                                  ),
                                  const SizedBox(height: AppSpacing.md),

                                  // Confirm password
                                  AppTextField(
                                    controller: _confirmPasswordController,
                                    label: 'Confirm Password',
                                    obscureText: true,
                                    textInputAction: TextInputAction.done,
                                    focusNode: _confirmPasswordFocusNode,
                                    prefixIcon: const Icon(
                                        Icons.lock_outline,
                                        size: 20),
                                    enabled: !isLoading,
                                    onFieldSubmitted: (_) => _submit(),
                                    validator: (value) =>
                                        validateConfirmPassword(
                                            value, _passwordController.text),
                                  ),
                                  const SizedBox(height: 24),

                                  // Create Account button
                                  AuthSubmitButton(
                                    label: 'Create Account',
                                    isLoading: isLoading,
                                    onPressed: _submit,
                                  ),
                                  const SizedBox(height: AppSpacing.xl),

                                  const AuthOrDivider(),
                                  const SizedBox(height: AppSpacing.xl),

                                  // Login link
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Already have an account?',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: isLoading
                                            ? null
                                            : () =>
                                                context.go(AppRoutes.login),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                        ),
                                        child: const Text(
                                          'Sign In',
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
