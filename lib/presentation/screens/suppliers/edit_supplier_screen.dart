import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/suppliers_tutorial_service.dart';
import '../../../domain/entities/supplier.dart';
import '../../blocs/suppliers/suppliers_bloc.dart';
import '../../blocs/suppliers/suppliers_event.dart';
import '../../blocs/suppliers/suppliers_state.dart';
import '../../widgets/common/app_text_field.dart';

class EditSupplierScreen extends StatefulWidget {
  final Supplier supplier;

  const EditSupplierScreen({super.key, required this.supplier});

  @override
  State<EditSupplierScreen> createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _phoneFieldKey = GlobalKey();
  final GlobalKey _areaFieldKey = GlobalKey();
  final GlobalKey _ratingSectionKey = GlobalKey();
  final GlobalKey _trustLevelKey = GlobalKey();
  final GlobalKey _notesFieldKey = GlobalKey();
  final GlobalKey _saveButtonKey = GlobalKey();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _areaController;
  late TextEditingController _notesController;

  late int _qualityRating;
  late String _trustLevel;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.supplier.name);
    _phoneController = TextEditingController(text: widget.supplier.phone ?? '');
    _areaController = TextEditingController(text: widget.supplier.area ?? '');
    _notesController = TextEditingController(text: widget.supplier.notes ?? '');
    _qualityRating = widget.supplier.qualityRating;
    _trustLevel = widget.supplier.trustLevel;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال اسم المورد';
    }
    if (value.trim().length < 2) {
      return 'اسم المورد يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty && value.length < 9) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  void _handleSubmit() {
    HapticFeedback.mediumImpact();

    if (_formKey.currentState?.validate() ?? false) {
      final updated = widget.supplier.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        area: _areaController.text.trim().isEmpty
            ? null
            : _areaController.text.trim(),
        qualityRating: _qualityRating,
        trustLevel: _trustLevel,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      context.read<SuppliersBloc>().add(UpdateSupplierEvent(updated));
    }
  }

  void _handleDelete() {
    HapticFeedback.mediumImpact();
    _showDeleteConfirmation();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: BlocListener<SuppliersBloc, SuppliersState>(
          listener: (context, state) {
            if (state is SupplierOperationSuccess) {
              setState(() => _isLoading = false);
              _showSuccessSnackBar(state.message);
              Navigator.of(context).pop();
            } else if (state is SuppliersError) {
              setState(() => _isLoading = false);
              _showErrorSnackBar(state.message);
            } else if (state is SuppliersLoading) {
              setState(() => _isLoading = true);
            }
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildStatsRow(),
                        const SizedBox(height: 20),
                        _buildInfoSection(),
                        const SizedBox(height: 20),
                        _buildRatingSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: _buildBackButton(),
      title: Column(
        children: [
          const Text(
            'تعديل المورد',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          Text(
            widget.supplier.name,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.help_outline,
            color: Color(0xFF6B7280),
            size: 22,
          ),
          onPressed: _showTutorial,
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Material(
        color: const Color(0xFFF3F4F6),
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
              color: Color(0xFF374151),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'التقييم',
            '$_qualityRating/5',
            Icons.star_outline,
            const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'الثقة',
            _trustLevel,
            Icons.verified_outlined,
            _getTrustColor(_trustLevel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'الحالة',
            'نشط',
            Icons.check_circle_outline,
            const Color(0xFF16A34A),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Color _getTrustColor(String trustLevel) {
    switch (trustLevel) {
      case 'ممتاز':
        return const Color(0xFF16A34A);
      case 'جيد':
        return const Color(0xFF0EA5E9);
      case 'متوسط':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildInfoSection() {
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
          _buildSectionHeader('معلومات المورد', Icons.edit_outlined),
          const SizedBox(height: 20),
          _buildTextField(
            key: _nameFieldKey,
            controller: _nameController,
            label: 'اسم المورد',
            hint: 'أدخل اسم المورد',
            icon: Icons.person_outline,
            validator: _validateName,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            key: _phoneFieldKey,
            controller: _phoneController,
            label: 'رقم الهاتف',
            hint: 'أدخل رقم الهاتف',
            icon: Icons.phone_outlined,
            validator: _validatePhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            key: _areaFieldKey,
            controller: _areaController,
            label: 'المنطقة',
            hint: 'أدخل المنطقة',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            key: _notesFieldKey,
            controller: _notesController,
            label: 'ملاحظات',
            hint: 'أدخل ملاحظات',
            icon: Icons.notes_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF6366F1)),
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

  Widget _buildTextField({
    GlobalKey? key,
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
          key: key,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Container(
      key: _ratingSectionKey,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('التقييم والثقة', Icons.star_outline),
          const SizedBox(height: 20),

          // Rating
          const Text(
            'تقييم الجودة',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _qualityRating = index + 1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      index < _qualityRating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: index < _qualityRating
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFD1D5DB),
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Trust level
          const Text(
            'مستوى الثقة',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            key: _trustLevelKey,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _trustLevel,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF6B7280),
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A2E),
                ),
                items: const [
                  DropdownMenuItem(value: 'جديد', child: Text('جديد')),
                  DropdownMenuItem(value: 'جيد', child: Text('جيد')),
                  DropdownMenuItem(value: 'ممتاز', child: Text('ممتاز')),
                  DropdownMenuItem(value: 'متوسط', child: Text('متوسط')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    HapticFeedback.selectionClick();
                    setState(() => _trustLevel = value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // Delete button
          Material(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: _handleDelete,
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
          ),
          const SizedBox(width: 12),
          // Save button
          Expanded(
            child: Material(
              key: _saveButtonKey,
              color: _isLoading
                  ? const Color(0xFFD1D5DB)
                  : const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _isLoading ? null : _handleSubmit,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'حفظ التغييرات',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DeleteConfirmationSheet(
        supplierName: widget.supplier.name,
        onConfirm: () {
          HapticFeedback.heavyImpact();
          context.read<SuppliersBloc>().add(
            DeleteSupplierEvent(widget.supplier.id!),
          );
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showTutorial() {
    HapticFeedback.lightImpact();
    SuppliersTutorialService.showFormTutorial(
      context: context,
      nameFieldKey: _nameFieldKey,
      phoneFieldKey: _phoneFieldKey,
      areaFieldKey: _areaFieldKey,
      ratingSectionKey: _ratingSectionKey,
      trustLevelKey: _trustLevelKey,
      notesFieldKey: _notesFieldKey,
      saveButtonKey: _saveButtonKey,
      scrollController: _scrollController,
      onFinish: () => _showSuccessSnackBar('تمت التعليمات بنجاح'),
    );
  }

  void _showSuccessSnackBar(String message) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _DeleteConfirmationSheet extends StatelessWidget {
  final String supplierName;
  final VoidCallback onConfirm;

  const _DeleteConfirmationSheet({
    required this.supplierName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).padding.bottom,
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
          const SizedBox(height: 24),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Color(0xFFDC2626),
              size: 28,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'تأكيد الحذف',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'هل أنت متأكد من حذف المورد "$supplierName"؟',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onConfirm,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      child: const Text(
                        'حذف',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
