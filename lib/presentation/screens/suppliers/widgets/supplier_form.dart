import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/supplier_model.dart';
import '../../../widgets/common/app_button.dart';
import '../../../widgets/common/app_text_field.dart';

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

class _SupplierFormState extends State<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _areaController;
  late final TextEditingController _notesController;

  int _qualityRating = 3;
  String _trustLevel = 'جديد';
  bool _isSubmitting = false;

  final List<String> _trustLevels = ['جديد', 'موثوق', 'متوسط', 'غير موثوق'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier?.name ?? '');
    _phoneController = TextEditingController(
      text: widget.supplier?.phone ?? '',
    );
    _areaController = TextEditingController(text: widget.supplier?.area ?? '');
    _notesController = TextEditingController(
      text: widget.supplier?.notes ?? '',
    );

    if (widget.supplier != null) {
      _qualityRating = widget.supplier!.qualityRating;
      _trustLevel = widget.supplier!.trustLevel;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _notesController.dispose();
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
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
            const SizedBox(height: 20),
            _buildRatingSection(),
            const SizedBox(height: 20),
            _buildTrustLevelSection(),
            const SizedBox(height: 20),
            _buildNotesSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.business_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.supplier == null
                      ? 'إضافة مورد جديد'
                      : 'تعديل بيانات المورد',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.supplier == null
                      ? 'املأ البيانات التالية'
                      : 'قم بتعديل البيانات المطلوبة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
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
    return _buildSection(
      title: 'المعلومات الأساسية',
      icon: Icons.info_outline,
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'اسم المورد',
            hint: 'أدخل اسم المورد',
            icon: Icons.person_outline,
            isRequired: true,
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
          const SizedBox(height: 14),
          _buildTextField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            hint: 'أدخل رقم الهاتف (اختياري)',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _areaController,
            label: 'المنطقة',
            hint: 'أدخل المنطقة (اختياري)',
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    final ratingColor = _getRatingColor(_qualityRating);

    return _buildSection(
      title: 'تقييم الجودة',
      icon: Icons.star_outline,
      iconColor: const Color(0xFFF59E0B),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ratingColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ratingColor.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            // Rating display
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التقييم الحالي',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_qualityRating من 5',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: ratingColor,
                      ),
                    ),
                  ],
                ),
                // Stars
                Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _qualityRating = index + 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          index < _qualityRating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: ratingColor,
                          size: 28,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Slider
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                activeTrackColor: ratingColor,
                inactiveTrackColor: ratingColor.withOpacity(0.2),
                thumbColor: Colors.white,
                overlayColor: ratingColor.withOpacity(0.1),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 10,
                  elevation: 4,
                ),
              ),
              child: Slider(
                value: _qualityRating.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  setState(() => _qualityRating = value.toInt());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustLevelSection() {
    return _buildSection(
      title: 'مستوى الثقة',
      icon: Icons.verified_user_outlined,
      iconColor: const Color(0xFF0EA5E9),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _trustLevels.map((level) {
          final isSelected = _trustLevel == level;
          final color = _getTrustLevelColor(level);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _trustLevel = level);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getTrustLevelIcon(level),
                    size: 16,
                    color: isSelected ? Colors.white : color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    level,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotesSection() {
    return _buildSection(
      title: 'ملاحظات إضافية',
      icon: Icons.notes_outlined,
      iconColor: const Color(0xFF3B82F6),
      child: _buildTextField(
        controller: _notesController,
        label: 'ملاحظات',
        hint: 'أدخل ملاحظات إضافية (اختياري)',
        icon: Icons.edit_note_outlined,
        maxLines: 3,
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    Color iconColor = const Color(0xFF6366F1),
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
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
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF6366F1),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.onCancel != null) ...[
          Expanded(
            child: _buildSecondaryButton(
              label: 'إلغاء',
              onTap: _isSubmitting ? null : widget.onCancel,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          flex: widget.onCancel != null ? 2 : 1,
          child: _buildPrimaryButton(
            label: widget.supplier == null ? 'إضافة المورد' : 'حفظ التعديلات',
            icon: widget.supplier == null ? Icons.add : Icons.save_outlined,
            isLoading: _isSubmitting,
            onTap: _isSubmitting ? null : _handleSubmit,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    VoidCallback? onTap,
  }) {
    return Material(
      color: onTap == null ? const Color(0xFFD1D5DB) : const Color(0xFF6366F1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({required String label, VoidCallback? onTap}) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 4) return const Color(0xFF16A34A);
    if (rating >= 3) return const Color(0xFFF59E0B);
    return const Color(0xFFDC2626);
  }

  Color _getTrustLevelColor(String trustLevel) {
    switch (trustLevel) {
      case 'موثوق':
        return const Color(0xFF16A34A);
      case 'متوسط':
        return const Color(0xFFF59E0B);
      case 'غير موثوق':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF0EA5E9);
    }
  }

  IconData _getTrustLevelIcon(String trustLevel) {
    switch (trustLevel) {
      case 'موثوق':
        return Icons.check_circle_outline;
      case 'متوسط':
        return Icons.remove_circle_outline;
      case 'غير موثوق':
        return Icons.cancel_outlined;
      default:
        return Icons.new_releases_outlined;
    }
  }
}
