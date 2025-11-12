import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/supplier_model.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

/// نموذج بيانات المورد
class SupplierForm extends StatefulWidget {
  final SupplierModel? supplier;
  final void Function(SupplierModel supplier) onSubmit;
  final VoidCallback? onCancel;

  const SupplierForm({
    super.key,
    this.supplier,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends State<SupplierForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _areaController;
  late final TextEditingController _notesController;

  int _qualityRating = 3;
  String _trustLevel = 'جديد';
  bool _isSubmitting = false;

  final List<String> _trustLevels = [
    'جديد',
    'موثوق',
    'متوسط',
    'غير موثوق',
  ];

  late AnimationController _mainController;
  late AnimationController _sliderController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.supplier?.phone ?? '');
    _areaController = TextEditingController(text: widget.supplier?.area ?? '');
    _notesController =
        TextEditingController(text: widget.supplier?.notes ?? '');

    if (widget.supplier != null) {
      _qualityRating = widget.supplier!.qualityRating;
      _trustLevel = widget.supplier!.trustLevel;
    }

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _sliderController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    _mainController.dispose();
    _sliderController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      setState(() => _isSubmitting = true);

      final supplier = SupplierModel(
        id: widget.supplier?.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        area: _areaController.text.trim().isEmpty
            ? null
            : _areaController.text.trim(),
        qualityRating: _qualityRating,
        trustLevel: _trustLevel,
        totalPurchases: widget.supplier?.totalPurchases ?? 0,
        totalDebtToHim: widget.supplier?.totalDebtToHim ?? 0,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: widget.supplier?.createdAt,
        updatedAt: DateTime.now(),
        firebaseId: widget.supplier?.firebaseId,
        syncStatus: widget.supplier?.syncStatus,
      );

      widget.onSubmit(supplier);

      setState(() => _isSubmitting = false);
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: child,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.03),
              AppColors.accent.withOpacity(0.02),
              Colors.transparent,
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 32),
                _buildBasicInfoSection(),
                const SizedBox(height: 24),
                _buildQualityRatingSection(),
                const SizedBox(height: 24),
                _buildTrustLevelSection(),
                const SizedBox(height: 24),
                _buildNotesSection(),
                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.business_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.supplier == null
                      ? 'إضافة مورد جديد'
                      : 'تعديل بيانات المورد',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.supplier == null
                      ? 'املأ البيانات التالية لإضافة مورد'
                      : 'قم بتعديل البيانات المطلوبة',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'المعلومات الأساسية',
            Icons.info_outline_rounded,
            AppColors.primary,
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _nameController,
            label: 'اسم المورد *',
            hint: 'أدخل اسم المورد',
            prefixIcon: Icons.business_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'اسم المورد مطلوب';
              }
              if (value.trim().length < 3) {
                return 'اسم المورد يجب أن يكون 3 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField.phone(
            controller: _phoneController,
            label: 'رقم الهاتف (اختياري)',
            hint: 'أدخل رقم الهاتف',
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _areaController,
            label: 'المنطقة (اختياري)',
            hint: 'أدخل المنطقة',
            prefixIcon: Icons.location_on_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildQualityRatingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'تقييم الجودة',
            Icons.star_rounded,
            AppColors.warning,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getRatingColor(_qualityRating).withOpacity(0.1),
                  _getRatingColor(_qualityRating).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getRatingColor(_qualityRating).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getRatingColor(_qualityRating).withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
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
                          'التقييم الحالي',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_qualityRating من 5',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: _getRatingColor(_qualityRating),
                            letterSpacing: -0.8,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            index < _qualityRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: _getRatingColor(_qualityRating),
                            size: 28,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 8,
                    activeTrackColor: _getRatingColor(_qualityRating),
                    inactiveTrackColor:
                        _getRatingColor(_qualityRating).withOpacity(0.2),
                    thumbColor: Colors.white,
                    overlayColor:
                        _getRatingColor(_qualityRating).withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 16,
                      elevation: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 28,
                    ),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: _qualityRating.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _qualityRating = value.toInt();
                      });
                      _sliderController.forward(from: 0);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustLevelSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'مستوى الثقة',
            Icons.verified_user_rounded,
            AppColors.accent,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _trustLevels.map((level) {
              final isSelected = _trustLevel == level;
              final color = _getTrustLevelColor(level);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _trustLevel = level);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [color, color.withOpacity(0.8)],
                          )
                        : null,
                    color: isSelected ? null : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTrustLevelIcon(level),
                        size: 20,
                        color: isSelected ? Colors.white : color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        level,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : color,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surface.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'ملاحظات إضافية',
            Icons.note_alt_rounded,
            AppColors.info,
          ),
          const SizedBox(height: 20),
          AppTextField.multiline(
            controller: _notesController,
            label: 'ملاحظات (اختياري)',
            hint: 'أدخل ملاحظات إضافية',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.onCancel != null) ...[
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AppButton.secondary(
                text: 'إلغاء',
                onPressed: _isSubmitting ? null : widget.onCancel,
                fullWidth: true,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          flex: 2,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: AppButton.primary(
              text: widget.supplier == null ? 'إضافة المورد' : 'حفظ التعديلات',
              onPressed: _isSubmitting ? null : _handleSubmit,
              isLoading: _isSubmitting,
              icon: widget.supplier == null
                  ? Icons.add_rounded
                  : Icons.save_rounded,
              fullWidth: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return AppColors.success;
    if (rating >= 3) return AppColors.warning;
    return AppColors.danger;
  }

  Color _getTrustLevelColor(String trustLevel) {
    switch (trustLevel) {
      case 'موثوق':
        return AppColors.success;
      case 'متوسط':
        return AppColors.warning;
      case 'غير موثوق':
        return AppColors.danger;
      default:
        return AppColors.info;
    }
  }

  IconData _getTrustLevelIcon(String trustLevel) {
    switch (trustLevel) {
      case 'موثوق':
        return Icons.check_circle_rounded;
      case 'متوسط':
        return Icons.remove_circle_rounded;
      case 'غير موثوق':
        return Icons.cancel_rounded;
      default:
        return Icons.new_releases_rounded;
    }
  }
}
