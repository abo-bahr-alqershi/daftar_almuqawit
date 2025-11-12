import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/inventory.dart';

/// شاشة تفاصيل عنصر المخزون - تصميم راقي هادئ
class InventoryDetailsScreen extends StatefulWidget {
  final Inventory item;

  const InventoryDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  State<InventoryDetailsScreen> createState() => _InventoryDetailsScreenState();
}

class _InventoryDetailsScreenState extends State<InventoryDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _getStatusColor() {
    if (widget.item.isEmpty) return AppColors.danger;
    if (widget.item.isLowStock) return AppColors.warning;
    if (widget.item.isOverStock) return AppColors.purchases;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            _buildGradientBackground(),
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainCard(),
                        const SizedBox(height: 20),
                        _buildQuantitiesCard(),
                        const SizedBox(height: 20),
                        _buildCostCard(),
                        const SizedBox(height: 20),
                        _buildDatesCard(),
                        if (widget.item.notes?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 20),
                          _buildNotesCard(),
                        ],
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _buildFloatingActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBackground() => Container(
    height: 400,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _getStatusColor().withOpacity(0.08),
          AppColors.info.withOpacity(0.05),
          Colors.transparent,
        ],
      ),
    ),
  );

  Widget _buildAppBar() {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: AppColors.surface.withOpacity(opacity),
      elevation: opacity * 2,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.surface, AppColors.surface.withOpacity(0.95)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(60, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getStatusColor(),
                              _getStatusColor().withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor().withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'تفاصيل الصنف',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.item.qatTypeName ?? 'غير محدد',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(),
            _getStatusColor().withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الكمية الحالية',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.item.currentQuantity.toStringAsFixed(1),
                        style: AppTextStyles.numberLarge.copyWith(
                          color: Colors.white,
                          fontSize: 36,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          widget.item.unit,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      widget.item.isEmpty
                          ? Icons.remove_circle_rounded
                          : widget.item.isLowStock
                              ? Icons.warning_rounded
                              : Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.item.isEmpty
                          ? 'نفذت'
                          : widget.item.isLowStock
                              ? 'منخفض'
                              : 'متوفر',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المتاحة للبيع',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
                Text(
                  '${widget.item.availableQuantity.toStringAsFixed(1)} ${widget.item.unit}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitiesCard() {
    return _SectionCard(
      title: 'الحدود والكميات',
      icon: Icons.analytics_rounded,
      color: AppColors.info,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.arrow_downward_rounded,
            label: 'الحد الأدنى',
            value: '${widget.item.minimumQuantity.toStringAsFixed(1)} ${widget.item.unit}',
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.arrow_upward_rounded,
            label: 'الحد الأقصى',
            value: widget.item.maximumQuantity != null
                ? '${widget.item.maximumQuantity!.toStringAsFixed(1)} ${widget.item.unit}'
                : 'غير محدد',
            color: AppColors.purchases,
          ),
          if (widget.item.maximumQuantity != null && widget.item.maximumQuantity! > 0) ...[
            const SizedBox(height: 16),
            _buildProgressIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final percentage = (widget.item.currentQuantity / widget.item.maximumQuantity!).clamp(0.0, 1.0);
    Color barColor;
    if (percentage >= 0.8) {
      barColor = AppColors.danger;
    } else if (percentage >= 0.5) {
      barColor = AppColors.warning;
    } else {
      barColor = AppColors.success;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'نسبة الامتلاء',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                color: barColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: AppColors.border.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCostCard() {
    return _SectionCard(
      title: 'التكلفة والأسعار',
      icon: Icons.attach_money_rounded,
      color: AppColors.primary,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.trending_up_rounded,
            label: 'متوسط التكلفة',
            value: widget.item.averageCost != null
                ? '${widget.item.averageCost!.toStringAsFixed(2)} ريال'
                : 'غير محدد',
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calculate_rounded,
            label: 'القيمة الإجمالية',
            value: widget.item.averageCost != null
                ? '${(widget.item.currentQuantity * widget.item.averageCost!).toStringAsFixed(2)} ريال'
                : 'غير محدد',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildDatesCard() {
    return _SectionCard(
      title: 'التواريخ',
      icon: Icons.calendar_today_rounded,
      color: AppColors.info,
      child: Column(
        children: [
          if (widget.item.lastPurchaseDate != null)
            _InfoRow(
              icon: Icons.shopping_cart_rounded,
              label: 'آخر شراء',
              value: widget.item.lastPurchaseDate!,
              color: AppColors.purchases,
            ),
          if (widget.item.lastPurchaseDate != null && widget.item.lastSaleDate != null)
            const SizedBox(height: 12),
          if (widget.item.lastSaleDate != null)
            _InfoRow(
              icon: Icons.sell_rounded,
              label: 'آخر بيع',
              value: widget.item.lastSaleDate!,
              color: AppColors.sales,
            ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return _SectionCard(
      title: 'الملاحظات',
      icon: Icons.note_rounded,
      color: AppColors.warning,
      child: Text(
        widget.item.notes!,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFloatingActions() {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.edit_rounded,
              label: 'تعديل',
              color: AppColors.info,
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionButton(
              icon: Icons.tune_rounded,
              label: 'تعديل الكمية',
              color: AppColors.primary,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.12),
                  color.withOpacity(0.06),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
