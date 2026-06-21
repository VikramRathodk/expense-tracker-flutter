import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/app_theme.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/currency_selector.dart';
import '../../../categories/domain/models/category_model.dart';
import '../../../categories/presentation/cubit/category_cubit.dart';
import '../../domain/models/recurring_expense_model.dart';
import '../cubit/recurring_form_cubit.dart';

class AddEditRecurringScreen extends StatefulWidget {
  const AddEditRecurringScreen({super.key, this.item});

  final RecurringExpenseModel? item;

  @override
  State<AddEditRecurringScreen> createState() =>
      _AddEditRecurringScreenState();
}

class _AddEditRecurringScreenState extends State<AddEditRecurringScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;

  late String _currency;
  late RecurringFrequency _frequency;
  late String _startDate;
  String? _endDate;
  CategoryModel? _selectedCategory;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _descCtrl = TextEditingController(text: item?.description ?? '');
    _amountCtrl = TextEditingController(
      text: item != null ? item.amount.toStringAsFixed(2) : '',
    );
    _currency = item?.currency ?? 'INR';
    _frequency = item?.frequency ?? RecurringFrequency.monthly;
    _startDate = item?.startDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _endDate = item?.endDate;

    context.read<CategoryCubit>().loadCategories();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _resolveCategory(List<CategoryModel> categories) {
    if (_selectedCategory != null) return;
    if (widget.item?.category != null) {
      _selectedCategory = categories.cast<CategoryModel?>().firstWhere(
            (c) => c?.id == widget.item!.category.id,
            orElse: () => null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RecurringFormCubit, RecurringFormState>(
      listener: (context, state) {
        if (state is RecurringFormSuccess) {
          context.showSuccessSnackBar(
              _isEdit ? 'Recurring expense updated.' : 'Recurring expense added.');
          context.pop();
        } else if (state is RecurringFormError) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEdit ? 'Edit Recurring' : 'Add Recurring',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Description
              TextFormField(
                controller: _descCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g. Netflix, Rent, Gym',
                  prefixIcon: Icon(Icons.description_outlined, size: 18),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),

              // Amount + Currency
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

              // Category picker
              BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state is! CategoryLoaded) {
                    return const SizedBox(
                      height: 56,
                      child: Center(
                          child: LinearProgressIndicator()),
                    );
                  }
                  _resolveCategory(state.categories);
                  return _CategoryDropdown(
                    categories: state.categories,
                    selected: _selectedCategory,
                    onSelect: (cat) =>
                        setState(() => _selectedCategory = cat),
                  );
                },
              ),
              if (_selectedCategory == null)
                const Padding(
                  padding: EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    'Please select a category',
                    style: TextStyle(fontSize: 12, color: AppColors.error),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),

              // Frequency
              DropdownButtonFormField<RecurringFrequency>(
                key: ValueKey(_frequency),
                initialValue: _frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.repeat, size: 18),
                ),
                items: RecurringFrequency.values
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(f.label),
                      ),
                    )
                    .toList(),
                onChanged: (f) {
                  if (f != null) setState(() => _frequency = f);
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Start date
              InkWell(
                onTap: () => _pickDate(isStart: true),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    prefixIcon:
                        Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                  child: Text(
                    _formatDate(_startDate),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // End date (optional)
              InkWell(
                onTap: () => _pickDate(isStart: false),
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'End Date (optional)',
                    prefixIcon: const Icon(
                        Icons.event_available_outlined,
                        size: 18),
                    suffixIcon: _endDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () =>
                                setState(() => _endDate = null),
                          )
                        : null,
                  ),
                  child: Text(
                    _endDate != null
                        ? _formatDate(_endDate!)
                        : 'No end date (ongoing)',
                    style: TextStyle(
                      fontSize: 14,
                      color: _endDate == null
                          ? const Color(0xFF94A3B8)
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              BlocBuilder<RecurringFormCubit, RecurringFormState>(
                builder: (context, state) => AppButton(
                  label: _isEdit ? 'Save Changes' : 'Add Recurring',
                  isLoading: state is RecurringFormSubmitting,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? DateTime.parse(_startDate)
        : (_endDate != null ? DateTime.parse(_endDate!) : DateTime.now());

    final firstDate = isStart
        ? DateTime(2020)
        : DateTime.parse(_startDate);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime(DateTime.now().year + 5, 12, 31),
    );

    if (picked == null) return;
    final iso = DateFormat('yyyy-MM-dd').format(picked);
    setState(() {
      if (isStart) {
        _startDate = iso;
        if (_endDate != null && _endDate!.compareTo(iso) < 0) {
          _endDate = null;
        }
      } else {
        _endDate = iso;
      }
    });
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('d MMMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() {});
      return;
    }

    final request = CreateRecurringRequest(
      description: _descCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text),
      currency: _currency,
      categoryId: _selectedCategory!.id,
      frequency: _frequency,
      startDate: _startDate,
      endDate: _endDate,
    );

    final cubit = context.read<RecurringFormCubit>();
    if (_isEdit) {
      cubit.updateRecurring(widget.item!.id, request);
    } else {
      cubit.createRecurring(request);
    }
  }
}

// ─── Category dropdown ────────────────────────────────────────────────────────

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<CategoryModel> categories;
  final CategoryModel? selected;
  final ValueChanged<CategoryModel?> onSelect;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<CategoryModel>(
      key: ValueKey(selected?.id),
      initialValue: selected,
      decoration: const InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category_outlined, size: 18),
      ),
      items: categories
          .map(
            (cat) => DropdownMenuItem(
              value: cat,
              child: Row(
                children: [
                  Icon(cat.iconData, size: 16, color: cat.displayColor),
                  const SizedBox(width: AppSpacing.sm),
                  Text(cat.name),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: onSelect,
    );
  }
}
