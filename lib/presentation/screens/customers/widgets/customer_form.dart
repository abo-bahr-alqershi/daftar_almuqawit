import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../domain/entities/customer.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_button.dart';
import '../../../../core/utils/validators.dart';

/// نموذج إضافة أو تعديل عميل
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

class _CustomerFormState extends State<CustomerForm> {
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
    _phoneController = TextEditingController(text: widget.customer?.phone ?? '');
    _nicknameController = TextEditingController(text: widget.customer?.nickname ?? '');
    _creditLimitController = TextEditingController(
      text: widget.customer?.creditLimit.toString() ?? '0',
    );
    _notesController = TextEditingController(text: widget.customer?.notes ?? '');
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
      setState(() => _isSubmitting = true);

      final customer = Customer(
        id: widget.customer?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        nickname: _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
        customerType: _customerType,
        creditLimit: double.tryParse(_creditLimitController.text) ?? 0,
        totalPurchases: widget.customer?.totalPurchases ?? 0,
        currentDebt: widget.customer?.currentDebt ?? 0,
        isBlocked: _isBlocked,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: widget.customer?.createdAt ?? DateTime.now().toIso8601String(),
      );

      widget.onSubmit(customer);
      
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // العنوان
            Text(
              widget.customer == null ? 'إضافة عميل جديد' : 'تعديل بيانات العميل',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spaceL),
            
            // اسم العميل
            AppTextField(
              controller: _nameController,
              label: 'اسم العميل *',
              hint: 'أدخل اسم العميل',
              prefixIcon: Icons.person,
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
            const SizedBox(height: AppDimensions.spaceM),
            
            // الكنية
            AppTextField(
              controller: _nicknameController,
              label: 'الكنية (اختياري)',
              hint: 'أدخل الكنية',
              prefixIcon: Icons.badge,
            ),
            const SizedBox(height: AppDimensions.spaceM),
            
            // رقم الهاتف
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
            const SizedBox(height: AppDimensions.spaceM),
            
            // نوع العميل
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نوع العميل',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceS),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _customerType,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingM,
                      ),
                    ),
                    items: _customerTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type,
                          style: AppTextStyles.bodyMedium,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _customerType = value);
                      }
                    },
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    dropdownColor: AppColors.surface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spaceM),
            
            // حد الائتمان
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
            const SizedBox(height: AppDimensions.spaceM),
            
            // حظر العميل
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: _isBlocked ? AppColors.dangerLight : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                border: Border.all(
                  color: _isBlocked ? AppColors.danger : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isBlocked ? Icons.block : Icons.check_circle,
                    color: _isBlocked ? AppColors.danger : AppColors.success,
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حالة العميل',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          _isBlocked ? 'محظور' : 'نشط',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: _isBlocked ? AppColors.danger : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isBlocked,
                    onChanged: (value) {
                      setState(() => _isBlocked = value);
                    },
                    activeColor: AppColors.danger,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spaceM),
            
            // ملاحظات
            AppTextField.multiline(
              controller: _notesController,
              label: 'ملاحظات (اختياري)',
              hint: 'أدخل ملاحظات إضافية',
              maxLines: 3,
            ),
            const SizedBox(height: AppDimensions.spaceXL),
            
            // الأزرار
            Row(
              children: [
                if (widget.onCancel != null) ...[
                  Expanded(
                    child: AppButton.secondary(
                      text: 'إلغاء',
                      onPressed: _isSubmitting ? null : widget.onCancel,
                      fullWidth: true,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceM),
                ],
                Expanded(
                  flex: 2,
                  child: AppButton.primary(
                    text: widget.customer == null ? 'إضافة' : 'حفظ التعديلات',
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    isLoading: _isSubmitting,
                    icon: widget.customer == null ? Icons.add : Icons.save,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
