import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../../../features/auth/domain/models/user_model.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/cubits/theme_cubit.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../cubit/profile_cubit.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        (context.watch<AuthBloc>().state as AuthAuthenticated?)?.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: 'Account',
            tiles: [
              _SettingsTile(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProfileCubit>(),
                      child: const EditProfileScreen(),
                    ),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProfileCubit>(),
                      child: const ChangePasswordScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: 'Preferences',
            tiles: [
              _CurrencyTile(currency: user.baseCurrency),
              _ThemeToggleTile(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: 'Data',
            tiles: [
              _SettingsTile(
                icon: Icons.category_outlined,
                label: 'Manage Categories',
                onTap: () => context.push(AppRoutes.categories),
              ),
              _SettingsTile(
                icon: Icons.tag_outlined,
                label: 'Manage Tags',
                onTap: () => context.push(AppRoutes.tags),
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () => context.push(AppRoutes.notifications),
              ),
              _SettingsTile(
                icon: Icons.bar_chart_outlined,
                label: 'Reports',
                onTap: () => context.push(AppRoutes.reports),
              ),
              _SettingsTile(
                icon: Icons.history_outlined,
                label: 'Audit Logs',
                onTap: () => context.push(AppRoutes.auditLogs),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: 'App',
            tiles: [
              const _SettingsTile(
                icon: Icons.info_outline,
                label: 'Version',
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _SignOutButton(),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── Profile header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final joinDate = _formatDate(user.createdAt);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary,
              child: Text(
                user.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              user.email,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: AppSpacing.sm),
            _RoleBadge(
              label: user.isSuperAdmin
                  ? 'Super Admin'
                  : user.isAdmin
                      ? 'Admin'
                      : 'Member',
            ),
            if (joinDate.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Member since $joinDate',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      return DateFormat('MMMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return '';
    }
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Settings section ─────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.tiles});

  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 4, vertical: AppSpacing.xs),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.8,
            ),
          ),
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: tiles.asMap().entries.map((e) {
              final isLast = e.key == tiles.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast) const Divider(height: 1, indent: 52),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1))
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 2),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({required this.currency});

  final String currency;

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      icon: Icons.currency_exchange_outlined,
      label: 'Default Currency',
      trailing: Text(
        currency,
        style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark;
        return ListTile(
          leading: Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: AppColors.primary,
            size: 22,
          ),
          title: const Text('Dark Mode',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          trailing: Switch.adaptive(
            value: isDark,
            onChanged: (_) => context.read<ThemeCubit>().toggle(),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        );
      },
    );
  }
}

// ─── Sign out ─────────────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final confirmed = await ConfirmationDialog.show(
          context,
          title: 'Sign Out',
          message: 'Are you sure you want to sign out?',
          confirmLabel: 'Sign Out',
          isDestructive: true,
        );
        if (confirmed && context.mounted) {
          context.read<AuthBloc>().add(AuthLogoutRequested());
        }
      },
      icon: const Icon(Icons.logout, size: 18),
      label: const Text('Sign Out'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error),
        minimumSize: const Size.fromHeight(48),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}