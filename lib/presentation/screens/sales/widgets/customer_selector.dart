import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../domain/entities/customer.dart';

/// محدد العميل - تصميم Tesla/iOS متطور
class CustomerSelector extends StatefulWidget {
  final String? selectedCustomerId;
  final ValueChanged<String?> onChanged;
  final List<Customer> customers;
  final bool enabled;
  final String? errorText;
  final bool allowAnonymous;
  final VoidCallback? onAddNewCustomer;

  const CustomerSelector({
    super.key,
    this.selectedCustomerId,
    required this.onChanged,
    required this.customers,
    this.enabled = true,
    this.errorText,
    this.allowAnonymous = true,
    this.onAddNewCustomer,
  });

  @override
  State<CustomerSelector> createState() => _CustomerSelectorState();
}

class _CustomerSelectorState extends State<CustomerSelector>
    with TickerProviderStateMixin {
  late AnimationController _buttonAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _searchSlideAnimation;

  final TextEditingController _searchController = TextEditingController();
  List<Customer> _filteredCustomers = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredCustomers = widget.customers;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _searchSlideAnimation = Tween<double>(begin: -50, end: 0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    _searchAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = widget.customers;
      } else {
        _filteredCustomers = widget.customers.where((customer) {
          return customer.name.toLowerCase().contains(query.toLowerCase()) ||
              (customer.phone?.contains(query) ?? false);
        }).toList();
      }
    });
  }

  void _showCustomerBottomSheet() {
    HapticFeedback.mediumImpact();
    setState(() => _isSearching = false);
    _searchController.clear();
    _filteredCustomers = widget.customers;
    _searchAnimationController.forward();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildModernBottomSheet(),
    );
  }

  Widget _buildModernBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          _buildSheetHeader(),

          // Search Bar
          _buildAnimatedSearchBar(),

          // Content
          Expanded(child: _buildCustomersList()),

          // Add New Customer Button
          if (widget.onAddNewCustomer != null) _buildAddNewCustomerButton(),
        ],
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.05), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.people_alt, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اختر العميل',
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.customers.length} عميل متاح',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSearchBar() {
    return AnimatedBuilder(
      animation: _searchSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _searchSlideAnimation.value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isSearching
                    ? AppColors.primary
                    : AppColors.border.withOpacity(0.2),
                width: _isSearching ? 2 : 1,
              ),
              boxShadow: _isSearching
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: _isSearching ? AppColors.primary : AppColors.textHint,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم أو رقم الهاتف...',
                      hintStyle: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: _filterCustomers,
                    onTap: () {
                      setState(() => _isSearching = true);
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, color: AppColors.textSecondary),
                    onPressed: () {
                      _searchController.clear();
                      _filterCustomers('');
                      setState(() => _isSearching = false);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomersList() {
    if (widget.allowAnonymous || _filteredCustomers.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          if (widget.allowAnonymous) _buildAnonymousOption(),

          if (widget.allowAnonymous && _filteredCustomers.isNotEmpty)
            _buildSectionDivider('العملاء المسجلين'),

          ..._filteredCustomers.asMap().entries.map((entry) {
            final index = entry.key;
            final customer = entry.value;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (index * 50)),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(50 * (1 - value), 0),
                  child: Opacity(
                    opacity: value,
                    child: _buildCustomerTile(customer),
                  ),
                );
              },
            );
          }),
        ],
      );
    }

    return _buildEmptyState();
  }

  Widget _buildAnonymousOption() {
    final isSelected = widget.selectedCustomerId == null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.05),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.success
              : AppColors.border.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onChanged(null);
          Navigator.pop(context);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.store, color: Colors.white, size: 24),
        ),
        title: Text(
          'بيع مباشر',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'بدون تسجيل عميل',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        trailing: isSelected
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              )
            : null,
      ),
    );
  }

  Widget _buildCustomerTile(Customer customer) {
    final isSelected = widget.selectedCustomerId == customer.id?.toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.border.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ListTile(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onChanged(customer.id?.toString());
          Navigator.pop(context);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildCustomerAvatar(customer),
        title: Text(
          customer.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phone != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 13, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    Text(
                      customer.phone!,
                      style: TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
              ),
            if (customer.totalDebt != null && customer.totalDebt! > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'دين: ${customer.totalDebt!.toStringAsFixed(0)} ريال',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        trailing: isSelected
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              )
            : Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textHint,
              ),
      ),
    );
  }

  Widget _buildCustomerAvatar(Customer customer) {
    return Hero(
      tag: 'customer-avatar-${customer.id}',
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.accent.withOpacity(0.6),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            customer.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDivider(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.border.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.accent.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_search,
                    size: 60,
                    color: AppColors.textHint,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'لا يوجد عملاء',
            style: AppTextStyles.h3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على أي عميل',
            style: TextStyle(color: AppColors.textHint, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewCustomerButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          Navigator.pop(context);
          widget.onAddNewCustomer?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.person_add),
        label: const Text(
          'إضافة عميل جديد',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCustomer = widget.customers
        .where((c) => c.id?.toString() == widget.selectedCustomerId)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'العميل',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _buttonScaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _buttonScaleAnimation.value,
              child: GestureDetector(
                onTapDown: (_) => _buttonAnimationController.forward(),
                onTapUp: (_) {
                  _buttonAnimationController.reverse();
                  if (widget.enabled) _showCustomerBottomSheet();
                },
                onTapCancel: () => _buttonAnimationController.reverse(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.enabled
                          ? [
                              AppColors.surface,
                              AppColors.surface.withOpacity(0.95),
                            ]
                          : [
                              AppColors.disabled.withOpacity(0.1),
                              AppColors.disabled.withOpacity(0.05),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.errorText != null
                          ? AppColors.danger
                          : AppColors.border.withOpacity(0.2),
                      width: widget.errorText != null ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.errorText != null
                            ? AppColors.danger.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildSelectedIcon(selectedCustomer != null),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedCustomer?.name ??
                                  (widget.selectedCustomerId == null &&
                                          widget.allowAnonymous
                                      ? 'بيع مباشر'
                                      : 'اختر العميل'),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color:
                                    selectedCustomer != null ||
                                        (widget.selectedCustomerId == null &&
                                            widget.allowAnonymous)
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (selectedCustomer?.phone != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  selectedCustomer!.phone!,
                                  style: TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: AppColors.danger),
              const SizedBox(width: 4),
              Text(
                widget.errorText!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedIcon(bool hasCustomer) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasCustomer
              ? [AppColors.primary, AppColors.primaryDark]
              : [AppColors.success, AppColors.success.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        hasCustomer ? Icons.person : Icons.store,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
