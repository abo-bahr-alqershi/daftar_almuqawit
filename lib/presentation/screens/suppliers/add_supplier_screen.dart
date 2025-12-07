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

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _areaController = TextEditingController();
  final _notesController = TextEditingController();
  final _scrollController = ScrollController();

  final GlobalKey _nameFieldKey = GlobalKey();
  final GlobalKey _phoneFieldKey = GlobalKey();
  final GlobalKey _areaFieldKey = GlobalKey();
  final GlobalKey _notesFieldKey = GlobalKey();
  final GlobalKey _ratingSectionKey = GlobalKey();
  final GlobalKey _trustLevelKey = GlobalKey();
  final GlobalKey _saveButtonKey = GlobalKey();

  int _qualityRating = 3;
  String _trustLevel = 'جديد';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _areaController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
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

  void _saveSupplier() {
    HapticFeedback.mediumImpact();

    if (_formKey.currentState!.validate()) {
      final supplier = Supplier(
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

      context.read<SuppliersBloc>().add(AddSupplierEvent(supplier));
    }
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
              _showSuccessSnackBar(state.message);
              Navigator.of(context).pop();
            } else if (state is SuppliersError) {
              _showErrorSnackBar(state.message);
            }
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInfoSection(),
                  const SizedBox(height: 20),
                  _buildRatingSection(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
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
      title: const Text(
        'إضافة مورد جديد',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E),
        ),
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
          _buildSectionHeader('المعلومات الأساسية', Icons.info_outline),
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
            hint: 'أدخل رقم الهاتف (اختياري)',
            icon: Icons.phone_outlined,
            validator: _validatePhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            key: _areaFieldKey,
            controller: _areaController,
            label: 'المنطقة',
            hint: 'أدخل المنطقة (اختياري)',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            key: _notesFieldKey,
            controller: _notesController,
            label: 'ملاحظات',
            hint: 'أدخل ملاحظات إضافية (اختياري)',
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

  Widget _buildSaveButton() {
    return BlocBuilder<SuppliersBloc, SuppliersState>(
      builder: (context, state) {
        final isLoading = state is SuppliersLoading;

        return Material(
          key: _saveButtonKey,
          color: isLoading ? const Color(0xFFD1D5DB) : const Color(0xFF6366F1),
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: isLoading ? null : _saveSupplier,
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
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'حفظ المورد',
                          style: TextStyle(
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
      },
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
