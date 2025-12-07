import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/return_item.dart';
import '../../../domain/entities/damaged_item.dart';

class ReturnDamageDetailsScreen extends StatefulWidget {
  final dynamic item;

  const ReturnDamageDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  State<ReturnDamageDetailsScreen> createState() =>
      _ReturnDamageDetailsScreenState();
}

class _ReturnDamageDetailsScreenState extends State<ReturnDamageDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  bool get isReturn => widget.item is ReturnItem;
  bool get isDamage => widget.item is DamagedItem;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();

    _scrollController.addListener(() {
      setState(() => _scrollOffset = _scrollController.offset);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color get primaryColor {
    if (isReturn) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  IconData get primaryIcon {
    if (isReturn) return Icons.keyboard_return_rounded;
    return Icons.broken_image_rounded;
  }

  String get title {
    if (isReturn) return 'تفاصيل المردود';
    return 'تفاصيل التلف';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final opacity = (_scrollOffset / 60).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 16,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.05),
                const Color(0xFFF8F9FA),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(60, 8, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      primaryIcon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isReturn ? 'معلومات المردود الكاملة' : 'تفاصيل البضاعة التالفة',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
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
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMainCard(),
          const SizedBox(height: 20),
          _buildDetailsCard(),
          const SizedBox(height: 20),
          _buildAmountCard(),
          if (isReturn && (widget.item as ReturnItem).notes?.isNotEmpty == true) ...[
            const SizedBox(height: 20),
            _buildNotesCard(),
          ],
          if (isDamage && (widget.item as DamagedItem).notes?.isNotEmpty == true) ...[
            const SizedBox(height: 20),
            _buildNotesCard(),
          ],
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMainCard() {
    final itemName = isReturn
        ? (widget.item as ReturnItem).qatTypeName
        : (widget.item as DamagedItem).qatTypeName;
    
    final status = isReturn
        ? (widget.item as ReturnItem).status
        : (widget.item as DamagedItem).status;
    
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اسم الصنف',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      itemName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(status),
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'الكمية',
                    value: isReturn
                        ? '${(widget.item as ReturnItem).quantity.toStringAsFixed(1)} ${(widget.item as ReturnItem).unit}'
                        : '${(widget.item as DamagedItem).quantity.toStringAsFixed(1)} ${(widget.item as DamagedItem).unit}',
                    icon: Icons.inventory_2_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: _buildInfoItem(
                    label: 'التاريخ',
                    value: isReturn
                        ? (widget.item as ReturnItem).returnDate
                        : (widget.item as DamagedItem).damageDate,
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'التفاصيل',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isReturn) ..._buildReturnDetails() else ..._buildDamageDetails(),
        ],
      ),
    );
  }

  List<Widget> _buildReturnDetails() {
    final returnItem = widget.item as ReturnItem;
    
    return [
      _buildDetailRow(
        label: 'رقم المردود',
        value: returnItem.returnNumber,
      ),
      const Divider(height: 24),
      _buildDetailRow(
        label: 'نوع المردود',
        value: returnItem.displayReturnType,
      ),
      const Divider(height: 24),
      _buildDetailRow(
        label: returnItem.isSalesReturn ? 'العميل' : 'المورد',
        value: returnItem.relatedPersonName,
      ),
      const Divider(height: 24),
      _buildDetailRow(
        label: 'السبب',
        value: returnItem.returnReason,
      ),
      const Divider(height: 24),
      _buildDetailRow(
        label: 'الوقت',
        value: returnItem.returnTime,
      ),
    ];
  }

  List<Widget> _buildDamageDetails() {
    final damageItem = widget.item as DamagedItem;
    
    return [
      _buildDetailRow(
        label: 'رقم التلف',
        value: damageItem.damageNumber,
      ),
      const Divider(height: 24),
      _buildDetailRow(
        label: 'مستوى الخطورة',
        value: damageItem.severityLevel,
      ),
      const Divider(height: 24),
      _buildDetailRow(
        label: 'السبب',
        value: damageItem.damageReason,
      ),
      if (damageItem.responsiblePerson != null) ...[
        const Divider(height: 24),
        _buildDetailRow(
          label: 'الشخص المسؤول',
          value: damageItem.responsiblePerson!,
        ),
      ],
      const Divider(height: 24),
      _buildDetailRow(
        label: 'الوقت',
        value: damageItem.damageTime,
      ),
    ];
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountCard() {
    final totalAmount = isReturn
        ? (widget.item as ReturnItem).totalAmount
        : (widget.item as DamagedItem).totalCost;
    
    final unitPrice = isReturn
        ? (widget.item as ReturnItem).unitPrice
        : (widget.item as DamagedItem).unitCost;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.12),
            primaryColor.withOpacity(0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.attach_money_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isReturn ? 'المبالغ المالية' : 'التكلفة المالية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAmountRow(
            label: isReturn ? 'سعر الوحدة' : 'تكلفة الوحدة',
            value: '${unitPrice.toStringAsFixed(2)} ريال',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: _buildAmountRow(
              label: isReturn ? 'الإجمالي' : 'إجمالي الخسارة',
              value: '${totalAmount.toStringAsFixed(2)} ريال',
              isTotal: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow({
    required String label,
    required String value,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? primaryColor : const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal ? primaryColor : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard() {
    final notes = isReturn
        ? (widget.item as ReturnItem).notes
        : (widget.item as DamagedItem).notes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.note_rounded,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ملاحظات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            notes ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'طباعة',
            icon: Icons.print_rounded,
            color: const Color(0xFF3B82F6),
            onTap: () {
              HapticFeedback.mediumImpact();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            label: 'مشاركة',
            icon: Icons.share_rounded,
            color: const Color(0xFF10B981),
            onTap: () {
              HapticFeedback.mediumImpact();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مؤكد':
        return const Color(0xFF10B981);
      case 'معلق':
      case 'تحت_المراجعة':
        return const Color(0xFFF59E0B);
      case 'ملغي':
        return const Color(0xFFDC2626);
      case 'تم_التعامل_معه':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'مؤكد':
        return Icons.check_circle_rounded;
      case 'معلق':
      case 'تحت_المراجعة':
        return Icons.pending_rounded;
      case 'ملغي':
        return Icons.cancel_rounded;
      case 'تم_التعامل_معه':
        return Icons.task_alt_rounded;
      default:
        return Icons.help_rounded;
    }
  }
}
