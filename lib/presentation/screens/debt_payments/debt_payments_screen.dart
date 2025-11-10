import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/debt_payment.dart';
import '../../blocs/debts/payment_bloc.dart';
import '../../blocs/debts/payment_event.dart';
import '../../blocs/debts/payment_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart' as custom;
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/payment_list_item.dart';
import 'widgets/payment_form.dart';
import 'widgets/payment_filters.dart';

/// شاشة عرض وإدارة دفعات الديون
/// تعرض قائمة بجميع دفعات دين معين مع إمكانية الإضافة والتعديل والحذف والتصفية
class DebtPaymentsScreen extends StatefulWidget {
  /// معرف الدين المراد عرض دفعاته
  final int? debtId;

  const DebtPaymentsScreen({
    super.key,
    this.debtId,
  });

  @override
  State<DebtPaymentsScreen> createState() => _DebtPaymentsScreenState();
}

class _DebtPaymentsScreenState extends State<DebtPaymentsScreen> {
  /// قائمة جميع الدفعات
  List<DebtPayment> _allPayments = [];
  
  /// قائمة الدفعات المفلترة
  List<DebtPayment> _filteredPayments = [];
  
  /// طريقة الدفع المختارة للتصفية
  String? _selectedPaymentMethod;
  
  /// تاريخ البداية للتصفية
  DateTime? _startDate;
  
  /// تاريخ النهاية للتصفية
  DateTime? _endDate;
  
  /// إظهار الفلاتر
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  /// تحميل الدفعات
  void _loadPayments() {
    if (widget.debtId != null) {
      context.read<PaymentBloc>().add(LoadPaymentsByDebtEvent(widget.debtId!));
    }
  }

  /// تطبيق الفلاتر
  void _applyFilters() {
    setState(() {
      _filteredPayments = _allPayments.where((payment) {
        // فلتر طريقة الدفع
        if (_selectedPaymentMethod != null &&
            payment.paymentMethod != _selectedPaymentMethod) {
          return false;
        }
        
        // فلتر التاريخ
        final paymentDate = DateTime.parse(payment.paymentDate);
        if (_startDate != null && paymentDate.isBefore(_startDate!)) {
          return false;
        }
        if (_endDate != null && paymentDate.isAfter(_endDate!)) {
          return false;
        }
        
        return true;
      }).toList();
    });
  }

  /// إعادة تعيين الفلاتر
  void _resetFilters() {
    setState(() {
      _selectedPaymentMethod = null;
      _startDate = null;
      _endDate = null;
      _filteredPayments = List.from(_allPayments);
    });
  }

  /// عرض نموذج إضافة دفعة
  void _showAddPaymentForm() {
    if (widget.debtId == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: PaymentForm(
            debtId: widget.debtId!,
            onSave: (payment) {
              context.read<PaymentBloc>().add(AddPaymentEvent(payment));
              Navigator.pop(context);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  /// عرض نموذج تعديل دفعة
  void _showEditPaymentForm(DebtPayment payment) {
    if (widget.debtId == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: PaymentForm(
            debtId: widget.debtId!,
            initialPayment: payment,
            onSave: (updatedPayment) {
              context.read<PaymentBloc>().add(UpdatePaymentEvent(updatedPayment));
              Navigator.pop(context);
            },
            onCancel: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  /// حذف دفعة مع تأكيد
  Future<void> _deletePayment(DebtPayment payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: 'حذف الدفعة',
        message: 'هل أنت متأكد من حذف هذه الدفعة؟\nالمبلغ: ${Formatters.formatCurrency(payment.amount)}',
        confirmText: 'حذف',
        cancelText: 'إلغاء',
        isDestructive: true,
      ),
    );

    if (confirmed == true && payment.id != null) {
      context.read<PaymentBloc>().add(DeletePaymentEvent(payment.id!));
    }
  }

  /// حساب إجمالي الدفعات
  double _calculateTotal() {
    return _filteredPayments.fold(
      0.0,
      (sum, payment) => sum + payment.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text(
            'دفعات الدين',
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // زر إظهار/إخفاء الفلاتر
            IconButton(
              icon: Icon(
                _showFilters ? Icons.filter_list_off : Icons.filter_list,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
            
            // زر تحديث
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadPayments,
            ),
          ],
        ),
        body: BlocConsumer<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              _loadPayments();
            } else if (state is PaymentUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              _loadPayments();
            } else if (state is PaymentDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              _loadPayments();
            } else if (state is PaymentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
            } else if (state is PaymentsLoaded) {
              setState(() {
                _allPayments = state.payments;
                _applyFilters();
              });
            }
          },
          builder: (context, state) {
            if (state is PaymentLoading) {
              return const Center(child: LoadingWidget());
            }

            if (state is PaymentError && _allPayments.isEmpty) {
              return custom.ErrorWidget(
                message: state.message,
                onRetry: _loadPayments,
              );
            }

            return Column(
              children: [
                // الفلاتر
                if (_showFilters)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: PaymentFilters(
                      selectedPaymentMethod: _selectedPaymentMethod,
                      startDate: _startDate,
                      endDate: _endDate,
                      onPaymentMethodChanged: (method) {
                        setState(() {
                          _selectedPaymentMethod = method;
                        });
                        _applyFilters();
                      },
                      onDateRangeChanged: (start, end) {
                        setState(() {
                          _startDate = start;
                          _endDate = end;
                        });
                        _applyFilters();
                      },
                      onReset: _resetFilters,
                    ),
                  ),

                // بطاقة الإحصائيات
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.payments,
                        label: 'عدد الدفعات',
                        value: '${_filteredPayments.length}',
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _StatItem(
                        icon: Icons.attach_money,
                        label: 'إجمالي المدفوع',
                        value: Formatters.formatCurrency(_calculateTotal()),
                      ),
                    ],
                  ),
                ),

                // قائمة الدفعات
                Expanded(
                  child: _filteredPayments.isEmpty
                      ? EmptyWidget(
                          icon: Icons.payment,
                          title: 'لا توجد دفعات',
                          message: _allPayments.isEmpty
                              ? 'لم يتم إضافة أي دفعات بعد'
                              : 'لا توجد دفعات تطابق الفلاتر المحددة',
                          actionText: _allPayments.isEmpty ? 'إضافة دفعة' : 'إعادة تعيين الفلاتر',
                          onAction: _allPayments.isEmpty ? _showAddPaymentForm : _resetFilters,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: _filteredPayments.length,
                          itemBuilder: (context, index) {
                            final payment = _filteredPayments[index];
                            return PaymentListItem(
                              payment: payment,
                              onEdit: () => _showEditPaymentForm(payment),
                              onDelete: () => _deletePayment(payment),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
        
        // زر إضافة دفعة عائم
        floatingActionButton: widget.debtId != null
            ? FloatingActionButton.extended(
                onPressed: _showAddPaymentForm,
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'إضافة دفعة',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// ويدجت عرض عنصر إحصائي
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
