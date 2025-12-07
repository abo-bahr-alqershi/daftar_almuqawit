import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/qat_type.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../navigation/route_names.dart';
import '../../widgets/common/confirm_dialog.dart';

/// شاشة تفاصيل نوع القات - تصميم احترافي راقي
class QatTypeDetailsScreen extends StatefulWidget {
  final int qatTypeId;

  const QatTypeDetailsScreen({super.key, required this.qatTypeId});

  @override
  State<QatTypeDetailsScreen> createState() => _QatTypeDetailsScreenState();
}

class _QatTypeDetailsScreenState extends State<QatTypeDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _contentController;
  late Animation<double> _headerFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scrollController.addListener(_onScroll);
    context.read<QatTypesBloc>().add(LoadQatTypeById(widget.qatTypeId));
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeOutCubic,
          ),
        );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Color _getQualityColor(String? quality) {
    switch (quality?.toLowerCase()) {
      case 'ممتاز':
        return const Color(0xFF16A34A);
      case 'جيد جداً':
        return const Color(0xFF0EA5E9);
      case 'جيد':
        return const Color(0xFF6366F1);
      case 'متوسط':
      case 'عادي':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: BlocConsumer<QatTypesBloc, QatTypesState>(
          listener: (context, state) {
            if (state is QatTypeOperationSuccess) {
              HapticFeedback.heavyImpact();
              Navigator.of(context).pop(true);
            }
          },
          builder: (context, state) {
            if (state is QatTypesLoading) {
              return _buildLoadingState();
            }
            if (state is QatTypesError) {
              return _buildErrorState(state.message);
            }
            if (state is QatTypeDetailsLoaded) {
              return _buildDetailsContent(state.qatType);
            }
            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildDetailsContent(QatType qatType) {
    final qualityColor = _getQualityColor(qatType.qualityGrade);

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(qatType, qualityColor),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    child: Column(
                      children: [
                        _buildHeaderCard(qatType, qualityColor),
                        const SizedBox(height: 16),
                        _buildPricesCard(qatType),
                        const SizedBox(height: 16),
                        if (qatType.availableUnits?.isNotEmpty ?? false) ...[
                          _buildUnitsCard(qatType),
                          const SizedBox(height: 16),
                        ],
                        _buildInfoCard(qatType),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        _buildBottomActions(qatType),
      ],
    );
  }

  Widget _buildSliverAppBar(QatType qatType, Color qualityColor) {
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);

    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white.withOpacity(opacity),
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(opacity),
      actions: [
        _buildActionButton(
          Icons.edit_outlined,
          () => Navigator.pushNamed(
            context,
            RouteNames.editQatType,
            arguments: qatType,
          ),
          opacity,
        ),
        _buildActionButton(
          Icons.more_horiz,
          () => _showMoreOptions(qatType),
          opacity,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _headerFade,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  qualityColor.withOpacity(0.08),
                  const Color(0xFFF8F9FA),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Hero(
                      tag: 'qat-type-icon-${qatType.id}',
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: qualityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            qatType.icon ?? '🌿',
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      qatType.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(double opacity) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: opacity < 0.5 ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1A1A2E),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap, double opacity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Material(
        color: opacity < 0.5 ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: Icon(icon, color: const Color(0xFF1A1A2E), size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(QatType qatType, Color qualityColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [qualityColor, qualityColor.withOpacity(0.85)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: qualityColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(qatType.icon ?? '🌿', style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 14),
          Text(
            qatType.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          if (qatType.qualityGrade != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                qatType.qualityGrade!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricesCard(QatType qatType) {
    final profitMargin =
        (qatType.defaultSellPrice ?? 0) - (qatType.defaultBuyPrice ?? 0);
    final hasProfit = profitMargin > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'معلومات الأسعار',
            Icons.payments_outlined,
            const Color(0xFF6366F1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildPriceItem(
                  'سعر الشراء',
                  qatType.defaultBuyPrice,
                  Icons.shopping_cart_outlined,
                  const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceItem(
                  'سعر البيع',
                  qatType.defaultSellPrice,
                  Icons.sell_outlined,
                  const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          if (hasProfit) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.trending_up,
                          color: Color(0xFF16A34A),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'هامش الربح',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${profitMargin.toStringAsFixed(0)} ر.ي',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceItem(
    String label,
    double? price,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 4),
          Text(
            price != null ? '${price.toStringAsFixed(0)}' : '-',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: price != null ? color : const Color(0xFF9CA3AF),
            ),
          ),
          if (price != null)
            Text(
              'ريال',
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
            ),
        ],
      ),
    );
  }

  Widget _buildUnitsCard(QatType qatType) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'الوحدات المتاحة',
            Icons.inventory_2_outlined,
            const Color(0xFF0EA5E9),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: qatType.availableUnits!.map((unit) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 14,
                      color: Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(QatType qatType) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'معلومات إضافية',
            Icons.info_outline,
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            Icons.emoji_emotions_outlined,
            'الرمز',
            qatType.icon ?? '🌿',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            Icons.grade_outlined,
            'درجة الجودة',
            qatType.qualityGrade ?? 'غير محدد',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
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
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(QatType qatType) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildPrimaryButton(
                'تعديل النوع',
                Icons.edit_outlined,
                const Color(0xFF6366F1),
                () => Navigator.pushNamed(
                  context,
                  RouteNames.editQatType,
                  arguments: qatType,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildDeleteButton(qatType),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(QatType qatType) {
    return Material(
      color: const Color(0xFFFEE2E2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _confirmDelete(qatType),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: const Icon(
            Icons.delete_outline,
            color: Color(0xFFDC2626),
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showMoreOptions(QatType qatType) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MoreOptionsSheet(
        qatType: qatType,
        onDelete: () => _confirmDelete(qatType),
      ),
    );
  }

  Future<void> _confirmDelete(QatType qatType) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'حذف النوع',
      message: 'هل أنت متأكد من حذف "${qatType.name}"؟',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && qatType.id != null) {
      HapticFeedback.heavyImpact();
      context.read<QatTypesBloc>().add(DeleteQatTypeEvent(qatType.id!));
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF6366F1)),
          SizedBox(height: 16),
          Text(
            'جاري التحميل...',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('لا توجد بيانات', style: TextStyle(color: Color(0xFF6B7280))),
    );
  }
}

class _MoreOptionsSheet extends StatelessWidget {
  final QatType qatType;
  final VoidCallback onDelete;

  const _MoreOptionsSheet({required this.qatType, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _buildOption(
            context,
            Icons.share_outlined,
            'مشاركة',
            () => Navigator.pop(context),
          ),
          _buildOption(
            context,
            Icons.copy_outlined,
            'نسخ المعلومات',
            () => Navigator.pop(context),
          ),
          _buildOption(context, Icons.delete_outline, 'حذف النوع', () {
            Navigator.pop(context);
            onDelete();
          }, isDestructive: true),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? const Color(0xFFDC2626)
        : const Color(0xFF374151);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Color(0xFFD1D5DB),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
