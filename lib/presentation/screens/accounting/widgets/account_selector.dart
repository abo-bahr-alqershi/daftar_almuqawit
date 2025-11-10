import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../domain/entities/account.dart';

/// محدد الحساب المالي
class AccountSelector extends StatefulWidget {
  final int? selectedAccountId;
  final ValueChanged<String?> onChanged;
  final List<Account> accounts;
  final bool enabled;
  final String? errorText;

  const AccountSelector({
    super.key,
    this.selectedAccountId,
    required this.onChanged,
    this.accounts = const [],
    this.enabled = true,
    this.errorText,
  });

  @override
  State<AccountSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends State<AccountSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<Account> _filteredAccounts = [];

  // حسابات افتراضية للعرض
  static final List<Account> _defaultAccounts = [
    const Account(id: 1, name: 'الصندوق', type: 'أصول', balance: 0, icon: 'wallet', color: 'primary'),
    const Account(id: 2, name: 'البنك', type: 'أصول', balance: 0, icon: 'account_balance', color: 'info'),
    const Account(id: 3, name: 'العملاء', type: 'أصول', balance: 0, icon: 'people', color: 'success'),
    const Account(id: 4, name: 'الموردون', type: 'خصوم', balance: 0, icon: 'local_shipping', color: 'warning'),
    const Account(id: 5, name: 'رأس المال', type: 'حقوق ملكية', balance: 0, icon: 'account_balance_wallet', color: 'primary'),
    const Account(id: 6, name: 'المبيعات', type: 'إيرادات', balance: 0, icon: 'point_of_sale', color: 'success'),
    const Account(id: 7, name: 'المشتريات', type: 'مصروفات', balance: 0, icon: 'shopping_cart', color: 'danger'),
    const Account(id: 8, name: 'المصروفات العمومية', type: 'مصروفات', balance: 0, icon: 'receipt', color: 'danger'),
    const Account(id: 9, name: 'الرواتب', type: 'مصروفات', balance: 0, icon: 'payments', color: 'danger'),
    const Account(id: 10, name: 'الإيجار', type: 'مصروفات', balance: 0, icon: 'home', color: 'danger'),
  ];

  @override
  void initState() {
    super.initState();
    _filteredAccounts = widget.accounts.isNotEmpty ? widget.accounts : _defaultAccounts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAccounts(String query) {
    final sourceAccounts = widget.accounts.isNotEmpty ? widget.accounts : _defaultAccounts;
    
    setState(() {
      if (query.isEmpty) {
        _filteredAccounts = sourceAccounts;
      } else {
        _filteredAccounts = sourceAccounts.where((account) {
          return account.name.toLowerCase().contains(query.toLowerCase()) ||
              account.type.contains(query);
        }).toList();
      }
    });
  }

  void _showAccountBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'اختر الحساب',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن حساب...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _filterAccounts,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredAccounts.isEmpty
                  ? const Center(child: Text('لا توجد حسابات'))
                  : ListView.separated(
                      itemCount: _filteredAccounts.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final account = _filteredAccounts[index];
                        final isSelected = widget.selectedAccountId == account.id;
                        
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected
                                ? AppColors.primary
                                : _getAccountTypeColor(account.type).withOpacity(0.1),
                            child: Icon(
                              _getAccountIcon(account.type),
                              color: isSelected
                                  ? Colors.white
                                  : _getAccountTypeColor(account.type),
                            ),
                          ),
                          title: Text(account.name),
                          subtitle: Text(account.type),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () {
                            widget.onChanged(account.id.toString());
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type) {
      case 'أصول':
        return Icons.account_balance_wallet;
      case 'خصوم':
        return Icons.credit_card;
      case 'إيرادات':
        return Icons.trending_up;
      case 'مصروفات':
        return Icons.trending_down;
      default:
        return Icons.account_balance;
    }
  }

  Color _getAccountTypeColor(String type) {
    switch (type) {
      case 'أصول':
        return AppColors.success;
      case 'خصوم':
        return AppColors.warning;
      case 'إيرادات':
        return AppColors.primary;
      case 'مصروفات':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sourceAccounts = widget.accounts.isNotEmpty ? widget.accounts : _defaultAccounts;
    final selectedAccount = sourceAccounts
        .where((a) => a.id == widget.selectedAccountId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الحساب *',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: widget.enabled ? _showAccountBottomSheet : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.enabled ? AppColors.surface : AppColors.disabled.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.errorText != null ? AppColors.danger : AppColors.border,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectedAccount != null
                      ? _getAccountIcon(selectedAccount.type)
                      : Icons.account_balance,
                  size: 20,
                  color: selectedAccount != null
                      ? _getAccountTypeColor(selectedAccount.type)
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedAccount?.name ?? 'اختر الحساب',
                        style: AppTextStyles.bodyMedium,
                      ),
                      if (selectedAccount != null)
                        Text(
                          selectedAccount.type,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.errorText!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}
