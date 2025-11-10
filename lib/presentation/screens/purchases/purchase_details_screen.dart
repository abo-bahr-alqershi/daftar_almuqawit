import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/purchase.dart';
import '../../blocs/purchases/purchases_bloc.dart';
import '../../blocs/purchases/purchases_event.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/purchase_item_card.dart';
import 'widgets/purchase_summary.dart';
import 'widgets/cost_calculator.dart';
import 'widgets/supplier_selector.dart';
import 'edit_purchase_screen.dart';

/// شاشة تفاصيل عملية الشراء الكاملة
class PurchaseDetailsScreen extends StatefulWidget {
  final Purchase purchase;

  const PurchaseDetailsScreen({
    super.key,
    required this.purchase,
  });

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen> {
  Future<void> _editPurchase() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPurchaseScreen(purchaseId: widget.purchase.id?.toString() ?? '0'),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deletePurchase() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'حذف المشترى',
      message: 'هل أنت متأكد من حذف هذا المشترى؟\nلن يمكن التراجع عن هذا الإجراء.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && widget.purchase.id != null) {
      if (mounted) {
        context.read<PurchasesBloc>().add(
          DeletePurchaseEvent(widget.purchase.id!),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _cancelPurchase() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'إلغاء المشترى',
      message: 'هل أنت متأكد من إلغاء هذا المشترى؟',
      confirmText: 'إلغاء المشترى',
      cancelText: 'رجوع',
      isDangerous: true,
    );

    if (confirmed == true && widget.purchase.id != null) {
      if (mounted) {
        context.read<PurchasesBloc>().add(
          CancelPurchaseEvent(widget.purchase.id!),
        );
        Navigator.of(context).pop(true);
      }
    }
  }

  void _printInvoice() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري طباعة الفاتورة...'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'تفاصيل المشترى',
            style: AppTextStyles.headlineMedium,
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            if (widget.purchase.status == 'نشط') ...[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _editPurchase,
                tooltip: 'تعديل',
              ),
            ],
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: _printInvoice,
              tooltip: 'طباعة',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'cancel':
                    _cancelPurchase();
                    break;
                  case 'delete':
                    _deletePurchase();
                    break;
                }
              },
              itemBuilder: (context) => [
                if (widget.purchase.status == 'نشط')
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: AppColors.warning),
                        SizedBox(width: 8),
                        Text('إلغاء المشترى'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: AppColors.danger),
                      SizedBox(width: 8),
                      Text('حذف المشترى'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.purchase.status != 'نشط')
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: AppColors.warning),
                      const SizedBox(width: AppDimensions.spaceM),
                      Expanded(
                        child: Text(
                          'هذا المشترى تم إلغاؤه',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (widget.purchase.status != 'نشط')
                const SizedBox(height: AppDimensions.spaceM),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'معلومات الشراء',
                            style: AppTextStyles.headlineSmall,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getPaymentStatusColor(widget.purchase.paymentStatus)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getPaymentStatusColor(widget.purchase.paymentStatus),
                              ),
                            ),
                            child: Text(
                              widget.purchase.paymentStatus,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: _getPaymentStatusColor(widget.purchase.paymentStatus),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.tag,
                        'رقم العملية',
                        '#${widget.purchase.id}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'التاريخ',
                        widget.purchase.date,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.access_time,
                        'الوقت',
                        widget.purchase.time,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.person,
                        'المورد',
                        widget.purchase.supplierName ?? 'غير محدد',
                      ),
                      if (widget.purchase.qatTypeName != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.category,
                          'نوع القات',
                          widget.purchase.qatTypeName!,
                        ),
                      ],
                      if (widget.purchase.invoiceNumber != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.receipt_long,
                          'رقم الفاتورة',
                          widget.purchase.invoiceNumber!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceM),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تفاصيل الكمية والسعر',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.inventory_2,
                        'الكمية',
                        '${widget.purchase.quantity} ${widget.purchase.unit}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.attach_money,
                        'سعر الوحدة',
                        '${widget.purchase.unitPrice.toStringAsFixed(2)} ريال',
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.calculate,
                        'الإجمالي',
                        '${widget.purchase.totalAmount.toStringAsFixed(2)} ريال',
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.spaceM),

              CostCalculator(
                totalAmount: widget.purchase.totalAmount,
                paidAmount: widget.purchase.paidAmount,
                remainingAmount: widget.purchase.remainingAmount,
              ),

              const SizedBox(height: AppDimensions.spaceM),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات الدفع',
                        style: AppTextStyles.headlineSmall,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.payment,
                        'طريقة الدفع',
                        widget.purchase.paymentMethod,
                      ),
                      if (widget.purchase.dueDate != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.event,
                          'تاريخ الاستحقاق',
                          widget.purchase.dueDate!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              if (widget.purchase.notes != null &&
                  widget.purchase.notes!.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spaceM),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notes, color: AppColors.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'ملاحظات',
                              style: AppTextStyles.headlineSmall,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          widget.purchase.notes!,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (widget.purchase.remainingAmount > 0 &&
                  widget.purchase.status == 'نشط') ...[
                const SizedBox(height: AppDimensions.spaceL),
                AppButton.primary(
                  text: 'سداد المبلغ المتبقي',
                  icon: Icons.payment,
                  onPressed: () {
                    // TODO: Navigate to payment screen
                  },
                  fullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: isHighlighted
                ? AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.primary,
                  )
                : AppTextStyles.bodyMedium,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'مدفوع':
        return AppColors.success;
      case 'مدفوع جزئياً':
        return AppColors.warning;
      case 'غير مدفوع':
        return AppColors.danger;
      default:
        return AppColors.textSecondary;
    }
  }
}
