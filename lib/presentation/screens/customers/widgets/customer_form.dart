import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../domain/entities/customer.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_button.dart';
import '../../../../core/utils/validators.dart';

class CustomerForm extends StatefulWidget {
  final Customer? customer;
  final void Function(Customer) onSubmit;
  final VoidCallback? onCancel;

  const CustomerForm({
    super.key,
    this.customer,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _creditLimitController;
  late final TextEditingController _notesController;

  String _customerType = 'عادي';
  bool _isBlocked = false;
  bool _isSubmitting = false;

  final List<String> _customerTypes = ['عادي', 'VIP', 'جديد'];

  late AnimationController _mainController;
  late AnimationController _blockToggleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.customer?.phone ?? '');
    _nicknameController =
        TextEditingController(text: widget.customer?.nickname ?? '');
    _creditLimitController = TextEditingController(
      text: widget.customer?.creditLimit.toString() ?? '0',
    );
    _notesController =
        TextEditingController(text: widget.customer?.notes ?? '');
    _customerType = widget.customer?.customerType ?? 'عادي';
    _isBlocked = widget.customer?.isBlocked ?? false;

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _blockToggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nicknameController.dispose();
    _creditLimitController.dispose();
    _notesController.dispose();
    _mainController.dispose();
    _blockToggleController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      setState(() => _isSubmitting = true);

      final customer = Customer(
        id: widget.customer?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        nickname: _nicknameController.text.trim().isEmpty
            ? null
            : _nicknameController.text.trim(),
        customerType: _customerType,
        creditLimit: double.tryParse(_creditLimitController.text) ?? 0,
        totalPurchases: widget.customer?.totalPurchases ?? 0,
        currentDebt: widget.customer?.currentDebt ?? 0,
        isBlocked: _isBlocked,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.customer?.createdAt ?? DateTime.now().toIso8601String(),
      );

      widget.onSubmit(customer);

      setState(() => _isSubmitting = false);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: child,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.03),
              AppColors.accent.withOpacity(0.02),
              Colors.transparent,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 32),
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildCustomerTypeSection(),
                const SizedBox(height: 24),
                _buildCreditLimitSection(),
                const SizedBox(height: 24),
                _buildBlockStatusSection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customer == null ? 'إضافة عميل جديد' : 'تعديل بيانات العميل',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.customer == null
                      ? 'املأ البيانات التالية لإضافة عميل'
                      : 'قم بتعديل البيانات المطلوبة',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'المعلومات الأساسية',
            Icons.info_outline_rounded,
            AppColors.primary,
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _nameController,
            label: 'اسم العميل *',
            hint: 'أدخل اسم العميل',
            prefixIcon: Icons.person_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'اسم العميل مطلوب';
              }
              if (value.trim().length < 3) {
                return 'اسم العميل يجب أن يكون 3 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _nicknameController,
            label: 'الكنية (اختياري)',
            hint: 'أدخل الكنية',
            prefixIcon: Icons.badge_rounded,
          ),
          const SizedBox(height: 16),
          AppTextField.phone(
            controller: _phoneController,
            label: 'رقم الهاتف (اختياري)',
            hint: 'أدخل رقم الهاتف',
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!Validators.isValidPhone(value)) {
                  return 'رقم الهاتف غير صحيح';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerTypeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'نوع العميل',
            Icons.category_rounded,
            AppColors.accent,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _customerTypes.map((type) {
              final isSelected = _customerType == type;
              final color = _getTypeColor(type);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _customerType = type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [color, color.withOpacity(0.8)],
                          )
                        : null,
                    color: isSelected ? null : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : color.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(type),
                        size: 20,
                        color: isSelected ? Colors.white : color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : color,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditLimitSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'حد الائتمان',
            Icons.account_balance_wallet_rounded,
            AppColors.success,
          ),
          const SizedBox(height: 20),
          AppTextField.currency(
            controller: _creditLimitController,
            label: 'حد الائتمان',
            hint: '0.00',
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final amount = double.tryParse(value);
                if (amount == null || amount < 0) {
                  return 'حد الائتمان يجب أن يكون رقم صحيح';
                }
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBlockStatusSection() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _isBlocked = !_isBlocked);
        _blockToggleController.forward(from: 0);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isBlocked
                ? [
                    AppColors.danger.withOpacity(0.15),
                    AppColors.danger.withOpacity(0.05),
                  ]
                : [
                    AppColors.success.withOpacity(0.15),
                    AppColors.success.withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isBlocked
                ? AppColors.danger.withOpacity(0.3)
                : AppColors.success.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isBlocked
                  ? AppColors.danger.withOpacity(0.15)
                  : AppColors.success.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isBlocked
                      ? [AppColors.danger, AppColors.danger.withOpacity(0.8)]
                      : [AppColors.success, AppColors.success.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _isBlocked
                        ? AppColors.danger.withOpacity(0.3)
                        : AppColors.success.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                _isBlocked ? Icons.block_rounded : Icons.check_circle_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حالة العميل',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isBlocked ? 'محظور' : 'نشط',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _isBlocked ? AppColors.danger : AppColors.success,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: _isBlocked
                    ? AppColors.danger.withOpacity(0.2)
                    : AppColors.success.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment:
                        _isBlocked ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isBlocked
                              ? [AppColors.danger, AppColors.danger.withOpacity(0.9)]
                              : [AppColors.success, AppColors.success.withOpacity(0.9)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _isBlocked
                                ? AppColors.danger.withOpacity(0.5)
                                : AppColors.success.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'ملاحظات إضافية',
            Icons.note_alt_rounded,
            AppColors.warning,
          ),
          const SizedBox(height: 20),
          AppTextField.multiline(
            controller: _notesController,
            label: 'ملاحظات (اختياري)',
            hint: 'أدخل ملاحظات إضافية',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.onCancel != null) ...[
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AppButton.secondary(
                text: 'إلغاء',
                onPressed: _isSubmitting ? null : widget.onCancel,
                fullWidth: true,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          flex: 2,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: AppButton.primary(
              text: widget.customer == null ? 'إضافة العميل' : 'حفظ التعديلات',
              onPressed: _isSubmitting ? null : _handleSubmit,
              isLoading: _isSubmitting,
              icon: widget.customer == null ? Icons.add_rounded : Icons.save_rounded,
              fullWidth: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'VIP':
        return AppColors.warning;
      case 'جديد':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'VIP':
        return Icons.star_rounded;
      case 'جديد':
        return Icons.fiber_new_rounded;
      default:
        return Icons.person_rounded;
    }
  }
}
