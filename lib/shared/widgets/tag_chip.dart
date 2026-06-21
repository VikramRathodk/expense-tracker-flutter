import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.tag,
    this.onRemove,
  });

  final String tag;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$tag',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 14,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TagInputField extends StatefulWidget {
  const TagInputField({
    super.key,
    required this.tags,
    required this.onTagsChanged,
    this.maxTags = 5,
  });

  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final int maxTags;

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final _controller = TextEditingController();

  void _addTag(String value) {
    final tag = value.trim().toLowerCase().replaceAll(' ', '_');
    if (tag.isEmpty) return;
    if (widget.tags.contains(tag)) {
      _controller.clear();
      return;
    }
    if (widget.tags.length >= widget.maxTags) return;
    widget.onTagsChanged([...widget.tags, tag]);
    _controller.clear();
  }

  void _removeTag(String tag) {
    widget.onTagsChanged(widget.tags.where((t) => t != tag).toList());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: widget.tags
                  .map((t) => TagChip(tag: t, onRemove: () => _removeTag(t)))
                  .toList(),
            ),
          ),
        if (widget.tags.length < widget.maxTags)
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Add tag',
              hintText: 'Press Enter to add',
              prefixIcon: Icon(Icons.tag, size: 18),
            ),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: _addTag,
          ),
      ],
    );
  }
}
