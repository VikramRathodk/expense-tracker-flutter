import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/confirmation_dialog.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/shimmer_loader.dart';
import '../../domain/models/tag_model.dart';
import '../cubit/tag_cubit.dart';

class TagListScreen extends StatefulWidget {
  const TagListScreen({super.key});

  @override
  State<TagListScreen> createState() => _TagListScreenState();
}

class _TagListScreenState extends State<TagListScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    context.read<TagCubit>().load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _showRenameDialog(TagModel tag) async {
    final ctrl = TextEditingController(text: tag.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => _RenameDialog(controller: ctrl, currentName: tag.name),
    );
    ctrl.dispose();
    if (newName != null && newName.trim().isNotEmpty && mounted) {
      context.read<TagCubit>().renameTag(
            name: tag.name,
            newName: newName.trim().toLowerCase().replaceAll(' ', '_'),
          );
    }
  }

  Future<void> _confirmDelete(TagModel tag) async {
    final label = tag.expenseCount > 0
        ? 'This will remove "#${tag.name}" from ${tag.expenseCount} '
            '${tag.expenseCount == 1 ? 'expense' : 'expenses'}.'
        : 'Delete tag "#${tag.name}"?';
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Tag',
      message: label,
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      context.read<TagCubit>().deleteTag(tag.name);
    }
  }

  List<TagModel> _filtered(List<TagModel> tags) {
    if (_query.isEmpty) return tags;
    return tags
        .where((t) => t.name.contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: BlocConsumer<TagCubit, TagState>(
        listener: (context, state) {
          if (state is TagError && state.tags.isNotEmpty) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          final List<TagModel> all = switch (state) {
            TagLoaded s => s.tags,
            TagError s => s.tags,
            _ => [],
          };

          if (state is TagLoading && all.isEmpty) {
            return _TagSkeleton();
          }

          if (state is TagError && all.isEmpty) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<TagCubit>().load(),
            );
          }

          if (all.isEmpty) {
            return const EmptyStateWidget(
              title: 'No tags yet',
              subtitle:
                  'Tags are added when you create or edit expenses.\n'
                  'Once created, manage them here.',
              icon: Icons.tag_outlined,
            );
          }

          final visible = _filtered(all);

          return RefreshIndicator(
            onRefresh: () => context.read<TagCubit>().refresh(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                    child: _SearchBar(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Text(
                      '${visible.length} tag${visible.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                if (visible.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text('No tags match your search.',
                          style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, index) {
                          final tag = visible[index];
                          final isLast = index == visible.length - 1;
                          return _TagTile(
                            tag: tag,
                            isFirst: index == 0,
                            isLast: isLast,
                            onRename: () => _showRenameDialog(tag),
                            onDelete: () => _confirmDelete(tag),
                          );
                        },
                        childCount: visible.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Search bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search tags…',
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
      ),
    );
  }
}

// ─── Tag tile ─────────────────────────────────────────────────────────────────

class _TagTile extends StatelessWidget {
  const _TagTile({
    required this.tag,
    required this.isFirst,
    required this.isLast,
    required this.onRename,
    required this.onDelete,
  });

  final TagModel tag;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(
      top: isFirst ? const Radius.circular(12) : Radius.zero,
      bottom: isLast ? const Radius.circular(12) : Radius.zero,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: radius,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '#',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        title: Text(
          tag.name,
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 15),
        ),
        subtitle: tag.expenseCount > 0
            ? Text(
                '${tag.expenseCount} '
                '${tag.expenseCount == 1 ? 'expense' : 'expenses'}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF94A3B8)),
              )
            : const Text('Unused',
                style:
                    TextStyle(fontSize: 12, color: Color(0xFFCBD5E1))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: Color(0xFF94A3B8)),
              onPressed: onRename,
              tooltip: 'Rename',
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
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    );
  }
}

// ─── Rename dialog ────────────────────────────────────────────────────────────

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({
    required this.controller,
    required this.currentName,
  });

  final TextEditingController controller;
  final String currentName;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Rename Tag',
          style: TextStyle(fontWeight: FontWeight.w700)),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: widget.controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Tag name',
            prefixIcon: Icon(Icons.tag, size: 18),
          ),
          onFieldSubmitted: (_) => _submit(),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Name is required.';
            if (v.trim().length > 30) return 'Max 30 characters.';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          style:
              TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: const Text('Rename',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(widget.controller.text.trim());
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _TagSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: const [
        ShimmerCard(height: 48),
        SizedBox(height: 1),
        ShimmerCard(height: 48),
        SizedBox(height: 1),
        ShimmerCard(height: 48),
        SizedBox(height: 1),
        ShimmerCard(height: 48),
        SizedBox(height: 1),
        ShimmerCard(height: 48),
        SizedBox(height: 1),
        ShimmerCard(height: 48),
      ],
    );
  }
}