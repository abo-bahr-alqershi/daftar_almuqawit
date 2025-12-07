import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/customer.dart';
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
  State<CustomerForm> createState() => CustomerFormState();
}

class CustomerFormState extends State<CustomerForm> {
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.customer?.phone ?? '',
    );
    _nicknameController = TextEditingController(
      text: widget.customer?.nickname ?? '',
    );
    _creditLimitController = TextEditingController(
      text: widget.customer?.creditLimit.toString() ?? '0',
    );
    _notesController = TextEditingController(
      text: widget.customer?.notes ?? '',
    );
    _customerType = widget.customer?.customerType ?? 'عادي';
    _isBlocked = widget.customer?.isBlocked ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nicknameController.dispose();
    _creditLimitController.dispose();
    _notesController.dispose();
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
        createdAt:
            widget.customer?.createdAt ?? DateTime.now().toIso8601String(),
      );

      widget.onSubmit(customer);
      setState(() => _isSubmitting = false);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 20),
            _buildCustomerTypeSection(),
            const SizedBox(height: 20),
            _buildCreditLimitSection(),
            const SizedBox(height: 20),
            _buildBlockStatusSection(),
            const SizedBox(height: 20),
            _buildNotesSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_add_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.customer == null
                      ? 'إضافة عميل جديد'
                      : 'تعديل بيانات العميل',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.customer == null
                      ? 'املأ البيانات التالية'
                      : 'قم بتعديل البيانات المطلوبة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
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
    return _buildSection(
      title: 'المعلومات الأساسية',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'اسم العميل',
            hint: 'أدخل اسم العميل',
            icon: Icons.person_outline,
            isRequired: true,
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
          const SizedBox(height: 14),
          _buildTextField(
            controller: _nicknameController,
            label: 'الكنية',
            hint: 'أدخل الكنية (اختياري)',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            hint: 'أدخل رقم الهاتف (اختياري)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
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
    return _buildSection(
      title: 'نوع العميل',
      icon: Icons.category_outlined,
      iconColor: const Color(0xFF0EA5E9),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _customerTypes.map((type) {
          final isSelected = _customerType == type;
          final color = _getTypeColor(type);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _customerType = type);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTypeIcon(type),
                    size: 16,
                    color: isSelected ? Colors.white : color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCreditLimitSection() {
    return _buildSection(
      title: 'حد الائتمان',
      icon: Icons.account_balance_wallet_outlined,
      iconColor: const Color(0xFF16A34A),
      child: _buildTextField(
        controller: _creditLimitController,
        label: 'حد الائتمان',
        hint: '0.00',
        icon: Icons.attach_money_outlined,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
    );
  }

  Widget _buildBlockStatusSection() {
    final statusColor = _isBlocked
        ? const Color(0xFFDC2626)
        : const Color(0xFF16A34A);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() => _isBlocked = !_isBlocked);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _isBlocked ? Icons.lock_outline : Icons.lock_open_outlined,
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'حالة العميل',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isBlocked ? 'محظور' : 'نشط',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            // Toggle Switch
            Container(
              width: 52,
              height: 28,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    alignment: _isBlocked
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
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
    return _buildSection(
      title: 'ملاحظات إضافية',
      icon: Icons.notes_outlined,
      iconColor: const Color(0xFFF59E0B),
      child: _buildTextField(
        controller: _notesController,
        label: 'ملاحظات',
        hint: 'أدخل ملاحظات إضافية (اختياري)',
        icon: Icons.edit_note_outlined,
        maxLines: 3,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    Color iconColor = const Color(0xFF6366F1),
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.onCancel != null) ...[
          Expanded(
            child: _buildSecondaryButton(
              label: 'إلغاء',
              onTap: _isSubmitting ? null : widget.onCancel,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: widget.onCancel != null ? 2 : 1,
          child: _buildPrimaryButton(
            label: widget.customer == null ? 'إضافة العميل' : 'حفظ التعديلات',
            icon: widget.customer == null ? Icons.add : Icons.save_outlined,
            isLoading: _isSubmitting,
            onTap: _isSubmitting ? null : _handleSubmit,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    VoidCallback? onTap,
  }) {
    return Material(
      color: onTap == null ? const Color(0xFFD1D5DB) : const Color(0xFF6366F1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, VoidCallback? onTap}) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'VIP':
        return const Color(0xFFF59E0B);
      case 'جديد':
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFF6366F1);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'VIP':
        return Icons.star_outline;
      case 'جديد':
        return Icons.fiber_new_outlined;
      default:
        return Icons.person_outline;
    }
  }
}
