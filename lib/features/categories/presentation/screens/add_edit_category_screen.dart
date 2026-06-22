import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/app_theme.dart';
import '../../domain/models/category_model.dart';
import '../cubit/category_manage_cubit.dart';

// Available icons for category picker
const _availableIcons = <String, IconData>{
  'restaurant': Icons.restaurant_outlined,
  'food': Icons.fastfood_outlined,
  'coffee': Icons.local_cafe_outlined,
  'grocery': Icons.local_grocery_store_outlined,
  'transport': Icons.directions_car_outlined,
  'bus': Icons.directions_bus_outlined,
  'flight': Icons.flight_outlined,
  'shopping': Icons.shopping_bag_outlined,
  'cart': Icons.shopping_cart_outlined,
  'clothing': Icons.checkroom_outlined,
  'electronics': Icons.devices_outlined,
  'health': Icons.health_and_safety_outlined,
  'pharmacy': Icons.local_pharmacy_outlined,
  'fitness': Icons.fitness_center_outlined,
  'entertainment': Icons.movie_outlined,
  'sports': Icons.sports_soccer_outlined,
  'education': Icons.school_outlined,
  'books': Icons.menu_book_outlined,
  'home': Icons.home_outlined,
  'utilities': Icons.bolt_outlined,
  'rent': Icons.apartment_outlined,
  'travel': Icons.luggage_outlined,
  'hotel': Icons.hotel_outlined,
  'gifts': Icons.card_giftcard_outlined,
  'savings': Icons.savings_outlined,
  'investment': Icons.trending_up_outlined,
  'salary': Icons.attach_money_outlined,
  'work': Icons.work_outline,
  'pets': Icons.pets_outlined,
  'subscriptions': Icons.subscriptions_outlined,
  'beauty': Icons.face_outlined,
  'taxes': Icons.account_balance_outlined,
  'insurance': Icons.security_outlined,
};

const _colorPalette = [
  '#6366F1',
  '#8B5CF6',
  '#EC4899',
  '#EF4444',
  '#F97316',
  '#F59E0B',
  '#84CC16',
  '#10B981',
  '#06B6D4',
  '#3B82F6',
  '#64748B',
  '#A78BFA',
];

class AddEditCategoryScreen extends StatefulWidget {
  const AddEditCategoryScreen({super.key, this.category});

  final CategoryModel? category;

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  late String _selectedIcon;
  late String _selectedColor;

  bool _isSaving = false;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _selectedIcon = c?.icon ?? _availableIcons.keys.first;
    _selectedColor = c?.color ?? _colorPalette.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final cubit = context.read<CategoryManageCubit>();
    if (_isEdit) {
      cubit.updateCategory(
        id: widget.category!.id,
        name: _nameCtrl.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
      );
    } else {
      cubit.createCategory(
        name: _nameCtrl.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryManageCubit, CategoryManageState>(
      listener: (context, state) {
        if (!_isSaving) return;
        if (state is CategoryManageLoaded) {
          Navigator.of(context).pop(true);
        } else if (state is CategoryManageError) {
          setState(() => _isSaving = false);
          _showSnack(context, state.message, AppColors.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEdit ? 'Edit Category' : 'New Category',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // ── Preview ───────────────────────────────────────────────────
              _CategoryPreview(
                icon: _availableIcons[_selectedIcon] ?? Icons.category_outlined,
                color: _parseColor(_selectedColor),
                name: _nameCtrl.text.isEmpty ? 'Category Name' : _nameCtrl.text,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Name ─────────────────────────────────────────────────────
              TextFormField(
                controller: _nameCtrl,
                enabled: !_isSaving,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  hintText: 'e.g. Dining Out',
                  prefixIcon: Icon(Icons.label_outline, size: 20),
                ),
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Name is required.';
                  }
                  if (v.trim().length > 50) {
                    return 'Name must be at most 50 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Color ─────────────────────────────────────────────────────
              _SectionLabel(label: 'Color'),
              const SizedBox(height: AppSpacing.sm),
              _ColorPicker(
                selected: _selectedColor,
                onSelected: (c) => setState(() => _selectedColor = c),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Icon ──────────────────────────────────────────────────────
              _SectionLabel(label: 'Icon'),
              const SizedBox(height: AppSpacing.sm),
              _IconPicker(
                selected: _selectedIcon,
                color: _parseColor(_selectedColor),
                onSelected: (k) => setState(() => _selectedIcon = k),
              ),
              const SizedBox(height: AppSpacing.xl),

              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isEdit ? 'Update Category' : 'Create Category'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Preview chip ─────────────────────────────────────────────────────────────

class _CategoryPreview extends StatelessWidget {
  const _CategoryPreview({
    required this.icon,
    required this.color,
    required this.name,
  });

  final IconData icon;
  final Color color;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.8,
      ),
    );
  }
}

// ─── Color picker ─────────────────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _colorPalette.map((hex) {
        final color = _parseColor(hex);
        final isSelected = hex == selected;
        return GestureDetector(
          onTap: () => onSelected(hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Colors.white, width: 3)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// ─── Icon picker ─────────────────────────────────────────────────────────────

class _IconPicker extends StatelessWidget {
  const _IconPicker({
    required this.selected,
    required this.color,
    required this.onSelected,
  });

  final String selected;
  final Color color;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _availableIcons.length,
      itemBuilder: (_, index) {
        final key = _availableIcons.keys.elementAt(index);
        final icon = _availableIcons[key]!;
        final isSelected = key == selected;
        return GestureDetector(
          onTap: () => onSelected(key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: isSelected ? Border.all(color: color, width: 1.5) : null,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isSelected ? color : const Color(0xFF94A3B8),
            ),
          ),
        );
      },
    );
  }
}

Color _parseColor(String hex) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return AppColors.primary;
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