import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../domain/models/category_model.dart';
import '../cubit/category_manage_cubit.dart';
import 'add_edit_category_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryManageCubit>().load();
  }

  Future<void> _openAdd() async {
    final cubit = context.read<CategoryManageCubit>();
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: const AddEditCategoryScreen(),
        ),
      ),
    );
  }

  Future<void> _openEdit(CategoryModel category) async {
    final cubit = context.read<CategoryManageCubit>();
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: AddEditCategoryScreen(category: category),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Category',
      message:
          'Delete "${category.name}"? Expenses using this category won\'t be affected.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      context.read<CategoryManageCubit>().deleteCategory(category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<CategoryManageCubit, CategoryManageState>(
        listener: (context, state) {
          if (state is CategoryManageError && state.categories.isNotEmpty) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          final List<CategoryModel> categories = switch (state) {
            CategoryManageLoaded s => s.categories,
            CategoryManageError s => s.categories,
            _ => [],
          };

          if (state is CategoryManageLoading && categories.isEmpty) {
            return _CategorySkeleton();
          }

          if (state is CategoryManageError && categories.isEmpty) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<CategoryManageCubit>().load(),
            );
          }

          if (categories.isEmpty) {
            return EmptyStateWidget(
              title: 'No categories yet',
              subtitle: 'Create your first custom category.',
              icon: Icons.category_outlined,
              actionLabel: 'Add Category',
              onAction: _openAdd,
            );
          }

          final systemCats =
              categories.where((c) => c.isSystem).toList();
          final customCats =
              categories.where((c) => !c.isSystem).toList();

          return RefreshIndicator(
            onRefresh: () =>
                context.read<CategoryManageCubit>().refresh(),
            child: ListView(
              padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  bottom: 96,
                  left: AppSpacing.md,
                  right: AppSpacing.md),
              children: [
                if (systemCats.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'System',
                    subtitle: 'Built-in categories (read-only)',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _CategorySection(
                    categories: systemCats,
                    onEdit: null,
                    onDelete: null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (customCats.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Custom',
                    subtitle: 'Your personal categories',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _CategorySection(
                    categories: customCats,
                    onEdit: _openEdit,
                    onDelete: _confirmDelete,
                  ),
                ] else if (systemCats.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Custom',
                    subtitle: 'Your personal categories',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          const Icon(Icons.add_circle_outline,
                              size: 40, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'No custom categories yet',
                            style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton.icon(
                            onPressed: _openAdd,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Category'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.8,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFFCBD5E1)),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Category section card ────────────────────────────────────────────────────

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CategoryModel> categories;
  final void Function(CategoryModel)? onEdit;
  final void Function(CategoryModel)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: categories.asMap().entries.map((e) {
          final isLast = e.key == categories.length - 1;
          return Column(
            children: [
              _CategoryTile(
                category: e.value,
                onEdit: onEdit != null ? () => onEdit!(e.value) : null,
                onDelete:
                    onDelete != null ? () => onDelete!(e.value) : null,
              ),
              if (!isLast) const Divider(height: 1, indent: 64),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Category tile ────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    this.onEdit,
    this.onDelete,
  });

  final CategoryModel category;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = category.displayColor;
    final isEditable = onEdit != null;

    final tile = ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(category.iconData, color: color, size: 18),
      ),
      title: Text(
        category.name,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: category.isSystem
          ? const Text('System',
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))
          : null,
      trailing: isEditable
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: Color(0xFF94A3B8)),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Color(0xFFEF4444)),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            )
          : const Icon(Icons.lock_outline,
              size: 16, color: Color(0xFFCBD5E1)),
      onTap: isEditable ? onEdit : null,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );

    return tile;
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _CategorySkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        ShimmerCard(height: 52),
        SizedBox(height: 1),
        ShimmerCard(height: 52),
        SizedBox(height: 1),
        ShimmerCard(height: 52),
        SizedBox(height: AppSpacing.md),
        ShimmerCard(height: 52),
        SizedBox(height: 1),
        ShimmerCard(height: 52),
      ],
    );
  }
}