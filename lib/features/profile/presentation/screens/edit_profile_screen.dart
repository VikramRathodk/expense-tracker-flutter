import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/mixins/form_validation_mixin.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final user =
        (context.read<AuthBloc>().state as AuthAuthenticated?)?.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _nameController.addListener(() => setState(() => _dirty = true));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context
        .read<ProfileCubit>()
        .updateProfile(name: _nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final initials =
        (context.watch<AuthBloc>().state as AuthAuthenticated?)?.user.initials ??
            '?';

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileActionSuccess) {
          if (state.updatedUser != null) {
            context.read<AuthBloc>().add(AuthProfileUpdated(state.updatedUser!));
          }
          _showSnack(context, state.message, AppColors.success);
          Navigator.of(context).pop(true);
        } else if (state is ProfileActionError) {
          _showSnack(context, state.message, AppColors.error);
          context.read<ProfileCubit>().reset();
        }
      },
      builder: (context, state) {
        final isSaving = state is ProfileSaving;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile',
                style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              TextButton(
                onPressed: (isSaving || !_dirty) ? null : _submit,
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700),
                      ),
              ),
            ],
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
                    Center(
                      child: CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Your display name',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      enabled: !isSaving,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: validateName,
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
                          : const Text('Save Changes'),
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