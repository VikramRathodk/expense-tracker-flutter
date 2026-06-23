import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/currency_selector.dart';
import '../../../../shared/widgets/tag_chip.dart';
import '../../../categories/domain/models/category_model.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../domain/models/expense_model.dart';
import '../cubit/expense_form_cubit.dart';

class AddEditExpenseScreen extends StatefulWidget {
  const AddEditExpenseScreen({super.key, this.expense});

  final ExpenseModel? expense;

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _notesCtrl;

  late String _currency;
  late DateTime _date;
  CategoryModel? _selectedCategory;
  List<String> _tags = [];
  bool _showCategoryError = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final exp = widget.expense;
    _amountCtrl = TextEditingController(
      text: exp != null ? exp.amount.toStringAsFixed(2) : '',
    );
    _descriptionCtrl = TextEditingController(text: exp?.description ?? '');
    _notesCtrl = TextEditingController(text: exp?.notes ?? '');
    _currency = exp?.currency ?? 'INR';
    _date = exp != null ? DateTime.parse(exp.date) : DateTime.now();
    _tags = List.from(exp?.tags ?? []);

    context.read<CategoryCubit>().loadCategories();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _resolveInitialCategory(List<CategoryModel> categories) {
    if (_selectedCategory != null) return;
    if (widget.expense != null) {
      _selectedCategory = categories.cast<CategoryModel?>().firstWhere(
            (c) => c?.id == widget.expense!.category.id,
            orElse: () => null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExpenseFormCubit, ExpenseFormState>(
      listener: (context, state) {
        if (state is ExpenseFormSuccess) {
          context.showSuccessSnackBar(
            _isEdit ? 'Expense updated.' : 'Expense added.',
          );
          context.pop();
        } else if (state is ExpenseFormError) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEdit ? 'Edit Expense' : 'Add Expense',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Amount + Currency row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money, size: 18),
                      ),
                      validator: (v) {
                        final val = double.tryParse(v ?? '');
                        if (val == null || val <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: CurrencySelector(
                      value: _currency,
                      onChanged: (c) => setState(() => _currency = c),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              TextFormField(
                controller: _descriptionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.edit_outlined, size: 18),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? 'Description is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Date picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon:
                        Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                  child: Text(
                    DateFormat('d MMMM yyyy').format(_date),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Category selector
              BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  final categories =
                      state is CategoryLoaded ? state.categories : <CategoryModel>[];
                  if (state is CategoryLoaded) {
                    _resolveInitialCategory(categories);
                  }
                  return InkWell(
                    onTap: categories.isEmpty
                        ? null
                        : () => _pickCategory(categories),
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: _selectedCategory != null
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  _selectedCategory!.iconData,
                                  size: 18,
                                  color: _selectedCategory!.displayColor,
                                ),
                              )
                            : const Icon(Icons.category_outlined, size: 18),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                        errorText: _showCategoryError && _selectedCategory == null
                            ? 'Please select a category'
                            : null,
                      ),
                      isEmpty: _selectedCategory == null,
                      child: _selectedCategory != null
                          ? Text(
                              _selectedCategory!.name,
                              style: const TextStyle(fontSize: 14),
                            )
                          : const Text(
                              'Select a category',
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF94A3B8)),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Tags
              TagInputField(
                tags: _tags,
                onTagsChanged: (tags) => setState(() => _tags = tags),
              ),
              const SizedBox(height: AppSpacing.md),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon:
                      Icon(Icons.notes_outlined, size: 18),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit button
              BlocBuilder<ExpenseFormCubit, ExpenseFormState>(
                builder: (context, state) => AppButton(
                  label: _isEdit ? 'Save Changes' : 'Add Expense',
                  isLoading: state is ExpenseFormSubmitting,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickCategory(List<CategoryModel> categories) async {
    final picked = await showModalBottomSheet<CategoryModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CategoryPickerSheet(
        categories: categories,
        selected: _selectedCategory,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedCategory = picked;
        _showCategoryError = false;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() => _showCategoryError = true);
      return;
    }

    final request = CreateExpenseRequest(
      amount: double.parse(_amountCtrl.text),
      currency: _currency,
      description: _descriptionCtrl.text.trim(),
      date: DateFormat('yyyy-MM-dd').format(_date),
      categoryId: _selectedCategory!.id,
      tags: _tags,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    final cubit = context.read<ExpenseFormCubit>();
    if (_isEdit) {
      cubit.updateExpense(widget.expense!.id, request);
    } else {
      cubit.createExpense(request);
    }
  }
}

// ─── Category picker bottom sheet ────────────────────────────────────────────

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({required this.categories, this.selected});

  final List<CategoryModel> categories;
  final CategoryModel? selected;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Category',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: GridView.builder(
              controller: controller,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.0,
              ),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final isSelected = selected?.id == cat.id;
                final color = cat.displayColor;
                return GestureDetector(
                  onTap: () => Navigator.of(context).pop(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color
                          : color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: color.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat.iconData,
                          color:
                              isSelected ? Colors.white : color,
                          size: 28,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          cat.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

