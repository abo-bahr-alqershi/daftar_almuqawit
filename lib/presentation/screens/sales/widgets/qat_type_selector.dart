import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// محدد نوع القات - تصميم Tesla/iOS متطور
class QatTypeSelector extends StatefulWidget {
  final String? selectedQatTypeId;
  final ValueChanged<String?> onChanged;
  final List<QatTypeOption> qatTypes;
  final bool enabled;
  final String? errorText;

  const QatTypeSelector({
    super.key,
    this.selectedQatTypeId,
    required this.onChanged,
    required this.qatTypes,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<QatTypeSelector> createState() => _QatTypeSelectorState();
}

class _QatTypeSelectorState extends State<QatTypeSelector>
    with TickerProviderStateMixin {
  late AnimationController _carouselController;
  late AnimationController _selectionController;
  late Animation<double> _carouselAnimation;
  late Animation<double> _selectionScaleAnimation;

  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _findSelectedPage();
  }

  void _initializeAnimations() {
    _carouselController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _carouselAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _carouselController, curve: Curves.easeInOut),
    );

    _selectionScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _selectionController, curve: Curves.elasticOut),
    );

    _carouselController.forward();
  }

  void _findSelectedPage() {
    if (widget.selectedQatTypeId != null) {
      final index = widget.qatTypes.indexWhere(
        (qt) => qt.id == widget.selectedQatTypeId,
      );
      if (index != -1) {
        _currentPage = index;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(index);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _selectionController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        _buildHeader(),

        if (widget.errorText != null) _buildErrorMessage(),

        const SizedBox(height: 16),

        // Qat Types Carousel
        _buildQatTypesCarousel(),

        const SizedBox(height: 16),

        // Page Indicators
        _buildPageIndicators(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.grass, color: AppColors.success, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نوع القات',
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'اسحب لاستعراض الأنواع',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.qatTypes.length} أنواع',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.danger, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.errorText!,
              style: TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQatTypesCarousel() {
    return AnimatedBuilder(
      animation: _carouselAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _carouselAnimation.value,
          child: SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: widget.qatTypes.length,
              itemBuilder: (context, index) {
                final qatType = widget.qatTypes[index];
                final isSelected = widget.selectedQatTypeId == qatType.id;

                return AnimatedScale(
                  scale: _currentPage == index ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 300),
                  child: _ModernQatTypeCard(
                    qatType: qatType,
                    isSelected: isSelected,
                    onTap: () => _selectQatType(qatType.id),
                    enabled: widget.enabled,
                    index: index,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.qatTypes.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.primary
                : AppColors.border.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  void _selectQatType(String id) {
    if (!widget.enabled) return;

    HapticFeedback.mediumImpact();
    widget.onChanged(id);
    _selectionController.forward(from: 0);
  }
}

// بطاقة نوع القات المحسنة
class _ModernQatTypeCard extends StatefulWidget {
  final QatTypeOption qatType;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;
  final int index;

  const _ModernQatTypeCard({
    required this.qatType,
    required this.isSelected,
    required this.onTap,
    required this.enabled,
    required this.index,
  });

  @override
  State<_ModernQatTypeCard> createState() => _ModernQatTypeCardState();
}

class _ModernQatTypeCardState extends State<_ModernQatTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: Duration(seconds: 3 + widget.index),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: GestureDetector(
            onTap: widget.enabled ? widget.onTap : null,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.success,
                          AppColors.success.withOpacity(0.8),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          AppColors.surface,
                          AppColors.surface.withOpacity(0.95),
                        ],
                      ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.success
                      : AppColors.border.withOpacity(0.2),
                  width: widget.isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.isSelected
                        ? AppColors.success.withOpacity(0.4)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: widget.isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background Pattern
                  if (widget.isSelected)
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with Animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0,
                            end: widget.isSelected ? 1 : 0,
                          ),
                          duration: const Duration(milliseconds: 300),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 1.0 + (value * 0.2),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: widget.isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.grass,
                                  color: widget.isSelected
                                      ? Colors.white
                                      : AppColors.success,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Name
                        Text(
                          widget.qatType.name,
                          style: TextStyle(
                            color: widget.isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        if (widget.qatType.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.qatType.description!,
                            style: TextStyle(
                              color: widget.isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        if (widget.qatType.price != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${widget.qatType.price!.toStringAsFixed(0)} ريال',
                              style: TextStyle(
                                color: widget.isSelected
                                    ? Colors.white
                                    : AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Selected Badge
                  if (widget.isSelected)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// خيار نوع القات
class QatTypeOption {
  final String id;
  final String name;
  final double? price;
  final String? description;

  const QatTypeOption({
    required this.id,
    required this.name,
    this.price,
    this.description,
  });
}
