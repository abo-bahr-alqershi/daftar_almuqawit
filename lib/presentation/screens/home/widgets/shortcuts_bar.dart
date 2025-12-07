import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// شريط الاختصارات السريعة - تصميم راقي ونظيف
class ShortcutsBar extends StatefulWidget {
  const ShortcutsBar({
    super.key,
    this.onQuickSale,
    this.onAddSale,
    this.onAddPurchase,
    this.onAddDebtPayment,
    this.onAddExpense,
    this.onAddReturn,
    this.onAddDamaged,
  });

  final VoidCallback? onQuickSale;
  final VoidCallback? onAddSale;
  final VoidCallback? onAddPurchase;
  final VoidCallback? onAddDebtPayment;
  final VoidCallback? onAddExpense;
  final VoidCallback? onAddReturn;
  final VoidCallback? onAddDamaged;

  @override
  State<ShortcutsBar> createState() => _ShortcutsBarState();
}

class _ShortcutsBarState extends State<ShortcutsBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_ShortcutData> _shortcuts;
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _initShortcuts();
  }

  void _initShortcuts() {
    _shortcuts = [
      _ShortcutData(
        icon: Icons.flash_on_rounded,
        label: 'بيع سريع',
        color: const Color(0xFF16A34A),
        onTap: widget.onQuickSale,
      ),
      _ShortcutData(
        icon: Icons.shopping_bag_outlined,
        label: 'بيع لعميل',
        color: const Color(0xFF6366F1),
        onTap: widget.onAddSale,
      ),
      _ShortcutData(
        icon: Icons.shopping_cart_outlined,
        label: 'شراء',
        color: const Color(0xFF0EA5E9),
        onTap: widget.onAddPurchase,
      ),
      _ShortcutData(
        icon: Icons.payment_rounded,
        label: 'دفعة دين',
        color: const Color(0xFF22C55E),
        onTap: widget.onAddDebtPayment,
      ),
      _ShortcutData(
        icon: Icons.receipt_long_outlined,
        label: 'مصروف',
        color: const Color(0xFFF59E0B),
        onTap: widget.onAddExpense,
      ),
      _ShortcutData(
        icon: Icons.assignment_return_outlined,
        label: 'مردود',
        color: const Color(0xFFEAB308),
        onTap: widget.onAddReturn,
      ),
      _ShortcutData(
        icon: Icons.warning_amber_rounded,
        label: 'تالف',
        color: const Color(0xFFDC2626),
        onTap: widget.onAddDamaged,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildShortcutsRow(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'إجراءات سريعة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ],
        ),
        const Text(
          'اسحب لليسار',
          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }

  Widget _buildShortcutsRow() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _shortcuts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 80)),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: _ShortcutButton(
                    data: _shortcuts[index],
                    isSelected: _selectedIndex == index,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _selectedIndex = index);

                      Future.delayed(const Duration(milliseconds: 150), () {
                        _shortcuts[index].onTap?.call();
                        if (mounted) setState(() => _selectedIndex = null);
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  final _ShortcutData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShortcutButton({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? data.color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? data.color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: data.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : data.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                data.icon,
                color: isSelected ? Colors.white : data.color,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF374151),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  _ShortcutData({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
}
