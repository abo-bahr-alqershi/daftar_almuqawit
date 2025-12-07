import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/sale.dart';
import '../../../../domain/entities/debt_payment.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart' as app_date;

class CustomerHistoryTab extends StatelessWidget {
  final List<Sale>? sales;
  final List<DebtPayment>? payments;
  final bool isLoading;
  final String? errorMessage;

  const CustomerHistoryTab({
    super.key,
    this.sales,
    this.payments,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    final hasData =
        (sales?.isNotEmpty ?? false) || (payments?.isNotEmpty ?? false);

    if (!hasData) {
      return _buildEmptyState();
    }

    final allItems = _buildHistoryItems();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: item.type == _HistoryItemType.sale
              ? _SaleHistoryCard(sale: item.sale!)
              : _PaymentHistoryCard(payment: item.payment!),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'جاري تحميل السجل...',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFFDC2626),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMessage ?? 'فشل تحميل البيانات',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.history_outlined,
                color: Color(0xFF9CA3AF),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا يوجد سجل نشاط',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'لم يتم تسجيل أي عمليات بعد',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<_HistoryItem> _buildHistoryItems() {
    final allItems = <_HistoryItem>[];

    if (sales != null) {
      for (var sale in sales!) {
        allItems.add(
          _HistoryItem(
            type: _HistoryItemType.sale,
            date: sale.date,
            sale: sale,
          ),
        );
      }
    }

    if (payments != null) {
      for (var payment in payments!) {
        allItems.add(
          _HistoryItem(
            type: _HistoryItemType.payment,
            date: payment.paymentDate,
            payment: payment,
          ),
        );
      }
    }

    allItems.sort((a, b) => b.date.compareTo(a.date));
    return allItems;
  }
}

class _SaleHistoryCard extends StatefulWidget {
  final Sale sale;

  const _SaleHistoryCard({required this.sale});

  @override
  State<_SaleHistoryCard> createState() => _SaleHistoryCardState();
}

class _SaleHistoryCardState extends State<_SaleHistoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF6366F1);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.02 : 0.04),
              blurRadius: _isPressed ? 4 : 8,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(height: 3, color: color),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(color),
                    const SizedBox(height: 14),
                    _buildDetailsSection(),
                    if (widget.sale.notes?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 12),
                      _buildNotesSection(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.shopping_bag_outlined, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'عملية بيع',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    size: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    app_date.DateUtils.formatDate(widget.sale.date),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(
          CurrencyUtils.format(widget.sale.totalAmount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildDetailRow('الكمية', widget.sale.quantity.toString()),
          const SizedBox(height: 8),
          Container(height: 1, color: const Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          _buildDetailRow('السعر', CurrencyUtils.format(widget.sale.unitPrice)),
          if (widget.sale.discount > 0) ...[
            const SizedBox(height: 8),
            Container(height: 1, color: const Color(0xFFE5E7EB)),
            const SizedBox(height: 8),
            _buildDetailRow(
              'الخصم',
              CurrencyUtils.format(widget.sale.discount),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0EA5E9).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notes_outlined, size: 14, color: Color(0xFF0EA5E9)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.sale.notes!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentHistoryCard extends StatefulWidget {
  final DebtPayment payment;

  const _PaymentHistoryCard({required this.payment});

  @override
  State<_PaymentHistoryCard> createState() => _PaymentHistoryCardState();
}

class _PaymentHistoryCardState extends State<_PaymentHistoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF16A34A);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.02 : 0.04),
              blurRadius: _isPressed ? 4 : 8,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Container(height: 3, color: color),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildHeader(color),
                    const SizedBox(height: 14),
                    _buildPaymentMethodSection(),
                    if (widget.payment.notes?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 12),
                      _buildNotesSection(),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color color) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.payment_outlined, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تسديد دفعة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    size: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    app_date.DateUtils.formatDate(widget.payment.paymentDate),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(
          CurrencyUtils.format(widget.payment.amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card_outlined,
                  size: 14,
                  color: Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'طريقة الدفع',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          Text(
            widget.payment.paymentMethod,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF16A34A).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF16A34A).withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notes_outlined, size: 14, color: Color(0xFF16A34A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.payment.notes!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _HistoryItemType { sale, payment }

class _HistoryItem {
  final _HistoryItemType type;
  final String date;
  final Sale? sale;
  final DebtPayment? payment;

  _HistoryItem({
    required this.type,
    required this.date,
    this.sale,
    this.payment,
  });
}
