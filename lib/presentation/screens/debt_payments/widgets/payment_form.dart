import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../domain/entities/debt_payment.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';
import '../../../widgets/common/app_date_picker.dart';
import 'payment_method_selector.dart';

/// نموذج إضافة أو تعديل دفعة
/// يحتوي على جميع الحقول المطلوبة لإدخال بيانات الدفعة
class PaymentForm extends StatefulWidget {
  /// معرف الدين المراد الدفع له
  final int debtId;
  
  /// بيانات الدفعة للتعديل (null في حالة إضافة جديدة)
  final DebtPayment? initialPayment;
  
  /// دالة استدعاء عند الحفظ
  final Function(DebtPayment payment) onSave;
  
  /// دالة استدعاء عند الإلغاء
  final VoidCallback? onCancel;

  const PaymentForm({
    super.key,
    required this.debtId,
    this.initialPayment,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  /// مفتاح النموذج للتحقق من الصحة
  final _formKey = GlobalKey<FormState>();
  
  /// متحكمات الحقول
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  /// طريقة الدفع المختارة
  String _selectedPaymentMethod = 'نقد';
  
  /// تاريخ الدفع المختار
  DateTime _selectedDate = DateTime.now();
  
  /// وقت الدفع المختار
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// تهيئة النموذج بالبيانات الأولية
  void _initializeForm() {
    if (widget.initialPayment != null) {
      final payment = widget.initialPayment!;
      _amountController.text = payment.amount.toString();
      _notesController.text = payment.notes ?? '';
      _selectedPaymentMethod = payment.paymentMethod;
      _selectedDate = DateTime.parse(payment.paymentDate);
      
      // تحويل وقت النص إلى TimeOfDay
      final timeParts = payment.paymentTime.split(':');
      if (timeParts.length >= 2) {
        _selectedTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 0,
          minute: int.tryParse(timeParts[1]) ?? 0,
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// معالج الحفظ
  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final payment = DebtPayment(
        id: widget.initialPayment?.id,
        debtId: widget.debtId,
        amount: double.parse(_amountController.text),
        paymentDate: _selectedDate.toIso8601String().split('T')[0],
        paymentTime: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      
      widget.onSave(payment);
    }
  }

  /// عرض منتقي التاريخ
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// عرض منتقي الوقت
  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // العنوان
              Text(
                widget.initialPayment == null ? 'إضافة دفعة جديدة' : 'تعديل الدفعة',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // حقل المبلغ
              AppTextField(
                controller: _amountController,
                label: 'المبلغ المدفوع',
                hint: 'أدخل المبلغ',
                prefixIcon: Icons.money,
                keyboardType: TextInputType.number,
                validator: Validators.validateAmount,
              ),
              
              const SizedBox(height: 20),
              
              // اختيار طريقة الدفع
              PaymentMethodSelector(
                selectedMethod: _selectedPaymentMethod,
                onMethodChanged: (method) {
                  setState(() {
                    _selectedPaymentMethod = method;
                  });
                },
              ),
              
              const SizedBox(height: 20),
              
              // اختيار التاريخ والوقت
              Row(
                children: [
                  // التاريخ
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'التاريخ',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // الوقت
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الوقت',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // حقل الملاحظات
              AppTextField(
                controller: _notesController,
                label: 'ملاحظات (اختياري)',
                hint: 'أضف أي ملاحظات إضافية',
                prefixIcon: Icons.note_outlined,
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // أزرار الإجراءات
              Row(
                children: [
                  // زر الإلغاء
                  if (widget.onCancel != null)
                    Expanded(
                      child: AppButton.secondary(
                        text: 'إلغاء',
                        onPressed: widget.onCancel!,
                        fullWidth: true,
                      ),
                    ),
                  
                  if (widget.onCancel != null) const SizedBox(width: 12),
                  
                  // زر الحفظ
                  Expanded(
                    flex: 2,
                    child: AppButton.primary(
                      text: widget.initialPayment == null ? 'إضافة الدفعة' : 'حفظ التعديلات',
                      onPressed: _handleSave,
                      fullWidth: true,
                      icon: Icons.check,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
