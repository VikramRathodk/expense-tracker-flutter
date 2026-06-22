import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/profile_cubit.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != _newCtrl.text) return 'Passwords do not match.';
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileCubit>().changePassword(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileActionSuccess) {
          _showSnack(context, state.message, AppColors.success);
          Navigator.of(context).pop();
        } else if (state is ProfileActionError) {
          _showSnack(context, state.message, AppColors.error);
          context.read<ProfileCubit>().reset();
        }
      },
      builder: (context, state) {
        final isSaving = state is ProfileSaving;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Change Password',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _currentCtrl,
                      label: 'Current Password',
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      enabled: !isSaving,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_newFocus),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _newCtrl,
                      label: 'New Password',
                      obscureText: true,
                      focusNode: _newFocus,
                      prefixIcon:
                          const Icon(Icons.lock_reset_outlined, size: 20),
                      enabled: !isSaving,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_confirmFocus),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _confirmCtrl,
                      label: 'Confirm New Password',
                      obscureText: true,
                      focusNode: _confirmFocus,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      enabled: !isSaving,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: _validateConfirm,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ElevatedButton(
                      onPressed: isSaving ? null : _submit,
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Update Password'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void _showSnack(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
}