import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// نوع النسخة الاحتياطية
enum BackupType {
  local,
  googleDrive,
}

/// قائمة منسدلة أنيقة لاختيار نوع النسخة الاحتياطية
/// تظهر مباشرة تحت الزر عند الضغط عليه
class BackupTypeDropdownMenu {
  /// عرض القائمة المنسدلة تحت الزر
  static Future<BackupType?> show({
    required BuildContext context,
    required GlobalKey buttonKey,
    required bool isRestore,
  }) async {
    // الحصول على موقع وحجم الزر
    final RenderBox? renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;

    // عرض القائمة المنسدلة
    return await Navigator.of(context).push(
      _BackupTypeDropdownRoute(
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
        isRestore: isRestore,
      ),
    );
  }
}

/// Route مخصص للقائمة المنسدلة
class _BackupTypeDropdownRoute extends PopupRoute<BackupType> {
  final Offset buttonPosition;
  final Size buttonSize;
  final bool isRestore;

  _BackupTypeDropdownRoute({
    required this.buttonPosition,
    required this.buttonSize,
    required this.isRestore,
  });

  @override
  Color? get barrierColor => Colors.black.withAlpha(100);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'إغلاق';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: _BackupTypeDropdownContent(
        animation: animation,
        buttonPosition: buttonPosition,
        buttonSize: buttonSize,
        isRestore: isRestore,
        onSelected: (type) => Navigator.pop(context, type),
      ),
    );
  }
}

/// محتوى القائمة المنسدلة
class _BackupTypeDropdownContent extends StatefulWidget {
  final Animation<double> animation;
  final Offset buttonPosition;
  final Size buttonSize;
  final bool isRestore;
  final Function(BackupType) onSelected;

  const _BackupTypeDropdownContent({
    required this.animation,
    required this.buttonPosition,
    required this.buttonSize,
    required this.isRestore,
    required this.onSelected,
  });

  @override
  State<_BackupTypeDropdownContent> createState() =>
      _BackupTypeDropdownContentState();
}

class _BackupTypeDropdownContentState
    extends State<_BackupTypeDropdownContent> {
  BackupType? _hoveredType;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    // حساب موقع القائمة (تحت الزر مباشرة)
    double top = widget.buttonPosition.dy + widget.buttonSize.height + 8;
    double right = screenSize.width - widget.buttonPosition.dx - widget.buttonSize.width;

    // التأكد من أن القائمة لا تخرج عن حدود الشاشة
    const menuHeight = 200.0;
    if (top + menuHeight > screenSize.height - padding.bottom) {
      // إذا لم يكن هناك مساحة تحت الزر، اعرضها فوقه
      top = widget.buttonPosition.dy - menuHeight - 8;
    }

    return Stack(
      children: [
        // خلفية شفافة للإغلاق عند الضغط خارج القائمة
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.translucent,
          ),
        ),

        // القائمة المنسدلة
        Positioned(
          top: top,
          right: right,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: widget.animation,
              curve: Curves.easeOut,
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: widget.animation,
                curve: Curves.easeOutCubic,
              )),
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: widget.animation,
                  curve: Curves.easeOutBack,
                ),
                alignment: Alignment.topRight,
                child: Material(
                  elevation: 12,
                  borderRadius: BorderRadius.circular(20),
                  shadowColor: Colors.black.withAlpha(60),
                  color: Colors.transparent,
                  child: Container(
                    width: widget.buttonSize.width,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border.withAlpha(30),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuItem(
                            type: BackupType.local,
                            icon: Icons.phone_android_rounded,
                            title: 'نسخ محلي',
                            subtitle: widget.isRestore
                                ? 'من جهازك'
                                : 'على جهازك',
                            gradient: const LinearGradient(
                              colors: [AppColors.success, Color(0xFF059669)],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            height: 1,
                            color: AppColors.border.withAlpha(20),
                          ),
                          _buildMenuItem(
                            type: BackupType.googleDrive,
                            icon: Icons.cloud_rounded,
                            title: 'Google Drive',
                            subtitle: widget.isRestore
                                ? 'من السحابة'
                                : 'على السحابة',
                            gradient: const LinearGradient(
                              colors: [AppColors.info, Color(0xFF0284C7)],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BackupType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
  }) {
    final isHovered = _hoveredType == type;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredType = type),
      onExit: (_) => setState(() => _hoveredType = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isHovered
              ? AppColors.primary.withAlpha(15)
              : Colors.transparent,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onSelected(type);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // أيقونة
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isHovered
                          ? [
                              BoxShadow(
                                color: gradient.colors.first.withAlpha(60),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // النص
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // سهم
                  AnimatedRotation(
                    turns: isHovered ? -0.5 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 16,
                      color: AppColors.textSecondary.withAlpha(120),
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
}

