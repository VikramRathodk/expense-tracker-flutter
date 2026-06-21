import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

const _supportedCurrencies = [
  ('INR', '₹', 'Indian Rupee'),
  ('USD', '\$', 'US Dollar'),
  ('EUR', '€', 'Euro'),
  ('GBP', '£', 'British Pound'),
  ('JPY', '¥', 'Japanese Yen'),
  ('AUD', 'A\$', 'Australian Dollar'),
  ('CAD', 'C\$', 'Canadian Dollar'),
  ('SGD', 'S\$', 'Singapore Dollar'),
  ('AED', 'د.إ', 'UAE Dirham'),
  ('CHF', 'Fr', 'Swiss Franc'),
];

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Currency',
          prefixIcon: Icon(Icons.currency_exchange, size: 18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.arrow_drop_down, size: 20, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CurrencyPickerSheet(
        selected: value,
        onSelected: (code) {
          onChanged(code);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  const _CurrencyPickerSheet({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            'Select Currency',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const Divider(height: 1),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _supportedCurrencies.length,
            itemBuilder: (_, index) {
              final (code, symbol, name) = _supportedCurrencies[index];
              final isSelected = code == selected;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      symbol,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0xFF1E1E2E),
                      ),
                    ),
                  ),
                ),
                title: Text(code,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(name),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () => onSelected(code),
              );
            },
          ),
        ),
        SizedBox(height: MediaQuery.paddingOf(context).bottom),
      ],
    );
  }
}
