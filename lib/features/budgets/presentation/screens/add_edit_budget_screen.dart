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
import '../../domain/models/budget_model.dart';
import '../cubit/budget_form_cubit.dart';

class AddEditBudgetScreen extends StatefulWidget {
  const AddEditBudgetScreen({super.key, this.budget});

  final BudgetModel? budget;

  @override
  State<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends State<AddEditBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;

  late String _currency;
  late String _period;
  CategoryModel? _selectedCategory;
  bool _isOverall = false;

  bool get _isEdit => widget.budget != null;

  @override
  void initState() {
    super.initState();
    final b = widget.budget;
    _amountCtrl = TextEditingController(
      text: b != null ? b.amount.toStringAsFixed(2) : '',
    );
    _currency = b?.currency ?? 'INR';
    _period = b?.period ?? DateFormat('yyyy-MM').format(DateTime.now());
    _isOverall = b?.isOverall ?? false;

    context.read<CategoryCubit>().loadCategories();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _resolveCategory(List<CategoryModel> categories) {
    if (_selectedCategory != null || _isOverall) return;
    if (widget.budget?.category != null) {
      _selectedCategory = categories.cast<CategoryModel?>().firstWhere(
            (c) => c?.id == widget.budget!.category!.id,
            orElse: () => null,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BudgetFormCubit, BudgetFormState>(
      listener: (context, state) {
        if (state is BudgetFormSuccess) {
          context.showSuccessSnackBar(
              _isEdit ? 'Budget updated.' : 'Budget created.');
          context.pop();
        } else if (state is BudgetFormError) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEdit ? 'Edit Budget' : 'Set Budget',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Period picker
              InkWell(
                onTap: _pickPeriod,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Month',
                    prefixIcon:
                        Icon(Icons.calendar_month_outlined, size: 18),
                  ),
                  child: Text(
                    _formatPeriod(_period),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Overall toggle
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.zero,
                child: SwitchListTile(
                  title: const Text('Overall Budget',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                      'Apply to all spending, not a specific category'),
                  value: _isOverall,
                  activeThumbColor: AppColors.primary,
                  onChanged: (v) => setState(() {
                    _isOverall = v;
                    if (v) _selectedCategory = null;
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Category picker (hidden when overall)
              if (!_isOverall) ...[
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    if (state is! CategoryLoaded) {
                      return const SizedBox.shrink();
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
                      'Select a category or enable Overall Budget',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
              ],

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
                        labelText: 'Budget Amount',
                        prefixIcon:
                            Icon(Icons.attach_money, size: 18),
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
              const SizedBox(height: AppSpacing.xl),

              BlocBuilder<BudgetFormCubit, BudgetFormState>(
                builder: (context, state) => AppButton(
                  label: _isEdit ? 'Save Changes' : 'Set Budget',
                  isLoading: state is BudgetFormSubmitting,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickPeriod() async {
    final current = DateFormat('yyyy-MM').parse(_period);
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 1, 12),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _period = DateFormat('yyyy-MM').format(picked));
    }
  }

  String _formatPeriod(String period) {
    try {
      return DateFormat('MMMM yyyy').format(DateFormat('yyyy-MM').parse(period));
    } catch (_) {
      return period;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_isOverall && _selectedCategory == null) {
      setState(() {});
      return;
    }

    final request = CreateBudgetRequest(
      amount: double.parse(_amountCtrl.text),
      currency: _currency,
      period: _period,
      categoryId: _isOverall ? null : _selectedCategory!.id,
    );

    final cubit = context.read<BudgetFormCubit>();
    if (_isEdit) {
      cubit.updateBudget(widget.budget!.id, request);
    } else {
      cubit.createBudget(request);
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
                  Icon(cat.iconData,
                      size: 16, color: cat.displayColor),
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
