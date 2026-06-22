import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../features/auth/domain/models/user_model.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../services/secure_storage_service.dart';

// ─── States ───────────────────────────────────────────────────────────────────

sealed class ProfileState {}

class ProfileIdle extends ProfileState {}

class ProfileSaving extends ProfileState {}

class ProfileActionSuccess extends ProfileState {
  ProfileActionSuccess(this.message, {this.updatedUser});
  final String message;
  final UserModel? updatedUser;
}

class ProfileActionError extends ProfileState {
  ProfileActionError(this.message);
  final String message;
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository, this._storage) : super(ProfileIdle());

  final AuthRepository _repository;
  final SecureStorageService _storage;

  Future<void> updateProfile({required String name}) async {
    emit(ProfileSaving());
    try {
      final user = await _repository.updateProfile(name: name);
      await _storage.saveUser(user);
      emit(ProfileActionSuccess('Profile updated successfully.', updatedUser: user));
    } on AppException catch (e) {
      emit(ProfileActionError(e.message));
    } catch (_) {
      emit(ProfileActionError('An unexpected error occurred.'));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(ProfileSaving());
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(ProfileActionSuccess('Password changed successfully.'));
    } on AppException catch (e) {
      emit(ProfileActionError(e.message));
    } catch (_) {
      emit(ProfileActionError('An unexpected error occurred.'));
    }
  }

  void reset() => emit(ProfileIdle());
}
