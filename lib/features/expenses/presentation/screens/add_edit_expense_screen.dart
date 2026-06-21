import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/category_chip.dart';
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

              // Category picker
              BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    _resolveInitialCategory(state.categories);
                    return _CategoryPicker(
                      categories: state.categories,
                      selected: _selectedCategory,
                      onSelect: (cat) =>
                          setState(() => _selectedCategory = cat),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              if (_selectedCategory == null)
                const Padding(
                  padding: EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    'Please select a category',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.error),
                  ),
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() {}); // trigger error text re-render
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

// ─── Category picker ─────────────────────────────────────────────────────────

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<CategoryModel> categories;
  final CategoryModel? selected;
  final ValueChanged<CategoryModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: const Color(0xFF64748B)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: categories
              .map(
                (cat) => CategoryChip(
                  category: cat,
                  isSelected: selected?.id == cat.id,
                  onTap: () => onSelect(cat),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

