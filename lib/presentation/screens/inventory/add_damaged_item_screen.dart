import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// شاشة إضافة بضاعة تالفة - تصميم احترافي راقي
class AddDamagedItemScreen extends StatefulWidget {
  const AddDamagedItemScreen({super.key});

  @override
  State<AddDamagedItemScreen> createState() => _AddDamagedItemScreenState();
}

class _AddDamagedItemScreenState extends State<AddDamagedItemScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  final _formKey = GlobalKey<FormState>();
  final _qatTypeNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _damageReasonController = TextEditingController();
  final _responsiblePersonController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedSeverityLevel = 'حارق';
  String _selectedUnit = 'ربطة';
  double _totalCost = 0;

  final List<String> _units = ['ربطة', 'علاقية', 'كيلو'];
  final List<String> _severityLevels = ['حارق'];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
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
    _qatTypeNameController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    _damageReasonController.dispose();
    _responsiblePersonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final cost = double.tryParse(_unitCostController.text) ?? 0;
    setState(() {
      _totalCost = quantity * cost;
    });
  }

  Color _getSeverityColor() {
    return const Color(0xFFDC2626);
  }

  void _submitDamage() {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    _showSnackBar('تم تسجيل البضاعة التالفة بنجاح', isError: false);
    Navigator.pop(context);
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
                const Color(0xFFDC2626).withOpacity(0.05),
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
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'تسجيل بضاعة تالفة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'موثق للخسائر والمحاسبة',
                          style: TextStyle(
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
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildSeveritySection(),
            const SizedBox(height: 24),
            _buildItemInfoSection(),
            const SizedBox(height: 24),
            _buildCostSection(),
            const SizedBox(height: 24),
            _buildDamageReasonSection(),
            const SizedBox(height: 24),
            _buildResponsibleSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 24),
            _buildSummaryCard(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFDC2626).withOpacity(0.08),
            const Color(0xFFDC2626).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDC2626).withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Color(0xFFDC2626),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'سجل البضاعة التالفة بدقة لتتبع الخسائر والمحاسبة',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeveritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مستوى الخطورة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        _SeverityButton(
          label: 'حارق',
          color: const Color(0xFFDC2626),
          isSelected: _selectedSeverityLevel == 'حارق',
          onTap: () {
            setState(() => _selectedSeverityLevel = 'حارق');
          },
        ),
      ],
    );
  }

  Widget _buildItemInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'معلومات الصنف',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _qatTypeNameController,
          label: 'اسم الصنف',
          hint: 'مثال: قات بلدي',
          prefixIcon: Icons.grass_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال اسم الصنف';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildTextField(
                controller: _quantityController,
                label: 'الكمية التالفة',
                hint: '0',
                prefixIcon: Icons.inventory_rounded,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotal(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'مطلوب';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'قيمة غير صحيحة';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                value: _selectedUnit,
                items: _units,
                label: 'الوحدة',
                onChanged: (value) {
                  setState(() => _selectedUnit = value!);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التكلفة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _unitCostController,
          label: 'تكلفة الوحدة',
          hint: '0.00',
          prefixIcon: Icons.attach_money_rounded,
          keyboardType: TextInputType.number,
          suffixText: 'ريال',
          onChanged: (_) => _calculateTotal(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال التكلفة';
            }
            if (double.tryParse(value) == null || double.parse(value) < 0) {
              return 'قيمة غير صحيحة';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDamageReasonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'سبب التلف',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _damageReasonController,
          label: 'السبب',
          hint: 'مثال: تعفن، كسر، تخزين سيء...',
          prefixIcon: Icons.comment_rounded,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال سبب التلف';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildResponsibleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المسؤول (اختياري)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _responsiblePersonController,
          label: 'الشخص المسؤول',
          hint: 'إن وُجد مسؤول عن التلف',
          prefixIcon: Icons.person_outline_rounded,
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ملاحظات إضافية (اختياري)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _notesController,
          label: 'ملاحظات',
          hint: 'أي ملاحظات إضافية',
          prefixIcon: Icons.note_add_rounded,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
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
                  color: const Color(0xFFDC2626).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'ملخص التلف',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            label: 'مستوى الخطورة',
            value: _selectedSeverityLevel,
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: 'الصنف',
            value: _qatTypeNameController.text.isEmpty
                ? '-'
                : _qatTypeNameController.text,
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: 'الكمية التالفة',
            value: _quantityController.text.isEmpty
                ? '-'
                : '${_quantityController.text} $_selectedUnit',
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: 'تكلفة الوحدة',
            value: _unitCostController.text.isEmpty
                ? '-'
                : '${_unitCostController.text} ريال',
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: 'إجمالي الخسارة',
            value: '${_totalCost.toStringAsFixed(2)} ريال',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitDamage,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 22),
            SizedBox(width: 8),
            Text(
              'حفظ التلف',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
    String? suffixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              prefixIcon: Icon(prefixIcon, size: 20, color: const Color(0xFF6B7280)),
              suffixText: suffixText,
              suffixStyle: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }
}

class _SeverityButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SeverityButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.dangerous_rounded,
              size: 24,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal ? const Color(0xFFDC2626) : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}
