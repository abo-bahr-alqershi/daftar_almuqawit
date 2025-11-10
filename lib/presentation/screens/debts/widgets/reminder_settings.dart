import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_date_picker.dart';

/// إعدادات التذكير بالديون
/// 
/// يوفر واجهة لإدارة تذكيرات الديون المتأخرة
class ReminderSettings extends StatefulWidget {
  final String debtId;
  final String customerName;
  final String? customerPhone;
  final double remainingAmount;
  final DateTime? dueDate;
  final VoidCallback? onSendReminder;

  const ReminderSettings({
    super.key,
    required this.debtId,
    required this.customerName,
    this.customerPhone,
    required this.remainingAmount,
    this.dueDate,
    this.onSendReminder,
  });

  @override
  State<ReminderSettings> createState() => _ReminderSettingsState();
}

class _ReminderSettingsState extends State<ReminderSettings> {
  String _reminderType = 'رسالة';
  DateTime? _reminderDate;
  String _reminderMessage = '';

  @override
  void initState() {
    super.initState();
    _reminderMessage = _getDefaultMessage();
  }

  String _getDefaultMessage() {
    return '''
السلام عليكم ${widget.customerName}،

هذا تذكير بأن لديك دين مستحق بقيمة ${widget.remainingAmount.toStringAsFixed(0)} ريال.

${widget.dueDate != null ? 'تاريخ الاستحقاق: ${_formatDate(widget.dueDate!)}' : ''}

نرجو منك التكرم بالسداد في أقرب وقت ممكن.

شكراً لتعاونكم.
''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إرسال تذكير',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.customerName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // معلومات الدين
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبلغ المتبقي',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.remainingAmount.toStringAsFixed(0)} ريال',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // نوع التذكير
          _buildSectionTitle('نوع التذكير'),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildReminderTypeChip('رسالة', Icons.message, AppColors.info),
              _buildReminderTypeChip('اتصال', Icons.phone, AppColors.success),
              _buildReminderTypeChip('واتساب', Icons.chat, AppColors.primary),
            ],
          ),
          const SizedBox(height: 24),

          // رسالة التذكير
          _buildSectionTitle('رسالة التذكير'),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              controller: TextEditingController(text: _reminderMessage),
              maxLines: 6,
              style: AppTextStyles.bodyMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'اكتب رسالة التذكير...',
              ),
              onChanged: (value) {
                _reminderMessage = value;
              },
            ),
          ),
          const SizedBox(height: 24),

          // جدولة التذكير
          _buildSectionTitle('جدولة التذكير (اختياري)'),
          const SizedBox(height: 12),

          AppDatePicker(
            label: 'تاريخ الإرسال',
            hint: 'إرسال فوري',
            selectedDate: _reminderDate,
            onDateSelected: (date) {
              setState(() {
                _reminderDate = date;
              });
            },
            prefixIcon: Icons.schedule,
            firstDate: DateTime.now(),
          ),
          const SizedBox(height: 24),

          // معلومات الاتصال
          if (widget.customerPhone != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.customerPhone!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (widget.customerPhone == null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.danger, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'لا يوجد رقم هاتف للعميل',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('إلغاء'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: widget.customerPhone != null
                      ? () {
                          widget.onSendReminder?.call();
                          Navigator.pop(context);
                        }
                      : null,
                  icon: const Icon(Icons.send),
                  label: Text(_reminderDate == null ? 'إرسال الآن' : 'جدولة التذكير'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.disabled,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildReminderTypeChip(String label, IconData icon, Color color) {
    final isSelected = _reminderType == label;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? AppColors.textOnDark : color,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _reminderType = label;
          });
        }
      },
      selectedColor: color,
      backgroundColor: AppColors.backgroundSecondary,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.textOnDark : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

/// عرض إعدادات التذكير كـ Bottom Sheet
Future<void> showReminderSettings({
  required BuildContext context,
  required String debtId,
  required String customerName,
  String? customerPhone,
  required double remainingAmount,
  DateTime? dueDate,
  VoidCallback? onSendReminder,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ReminderSettings(
      debtId: debtId,
      customerName: customerName,
      customerPhone: customerPhone,
      remainingAmount: remainingAmount,
      dueDate: dueDate,
      onSendReminder: onSendReminder,
    ),
  );
}
