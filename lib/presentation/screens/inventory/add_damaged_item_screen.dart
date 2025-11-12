import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/damaged_item.dart';
import '../../blocs/inventory/inventory_bloc.dart';

/// صفحة إضافة بضاعة تالفة - تصميم راقي
class AddDamagedItemScreen extends StatefulWidget {
  const AddDamagedItemScreen({super.key});

  @override
  State<AddDamagedItemScreen> createState() => _AddDamagedItemScreenState();
}

class _AddDamagedItemScreenState extends State<AddDamagedItemScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _qatTypeNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _damageReasonController = TextEditingController();
  final _responsiblePersonController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _notesController = TextEditingController();
  final _insuranceAmountController = TextEditingController();

  String _selectedDamageType = 'تلف_طبيعي';
  String _selectedSeverityLevel = 'متوسط';
  String _selectedUnit = 'ربطة';
  bool _isInsuranceCovered = false;
  DateTime? _expiryDate;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _units = ['ربطة', 'كيس', 'كرتون', 'قطعة'];
  final List<String> _damageTypes = [
    'تلف_طبيعي',
    'تلف_بشري',
    'تلف_خارجي',
    'انتهاء_صلاحية'
  ];
  final List<String> _severityLevels = ['طفيف', 'متوسط', 'كبير', 'كارثي'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _qatTypeNameController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    _damageReasonController.dispose();
    _responsiblePersonController.dispose();
    _batchNumberController.dispose();
    _notesController.dispose();
    _insuranceAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  _buildProductInfoCard(),
                  const SizedBox(height: 24),
                  _buildDamageTypeCard(),
                  const SizedBox(height: 24),
                  _buildDamageReasonCard(),
                  const SizedBox(height: 24),
                  _buildAdditionalInfoCard(),
                  const SizedBox(height: 24),
                  _buildInsuranceCard(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 20),
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
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSeverityColor(_selectedSeverityLevel).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.broken_image,
              color: _getSeverityColor(_selectedSeverityLevel),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'تسجيل بضاعة تالفة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getSeverityColor(_selectedSeverityLevel).withOpacity(0.8),
            _getSeverityColor(_selectedSeverityLevel),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getSeverityColor(_selectedSeverityLevel).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getSeverityIcon(_selectedSeverityLevel),
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'تسجيل بضاعة تالفة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل تفاصيل البضاعة التالفة بدقة لضمان المتابعة الصحيحة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.inventory_2, color: Colors.blue[700]),
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات الصنف',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStyledTextField(
            controller: _qatTypeNameController,
            label: 'اسم الصنف التالف',
            icon: Icons.inventory_2,
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'اسم الصنف مطلوب' : null,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildStyledTextField(
                  controller: _quantityController,
                  label: 'الكمية التالفة',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) return 'الكمية مطلوبة';
                    final quantity = double.tryParse(value!);
                    if (quantity == null || quantity <= 0) {
                      return 'الكمية يجب أن تكون رقماً موجباً';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStyledDropdown(
                  value: _selectedUnit,
                  label: 'الوحدة',
                  icon: Icons.straighten,
                  items: _units,
                  onChanged: (value) => setState(() => _selectedUnit = value!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStyledTextField(
            controller: _unitCostController,
            label: 'تكلفة الوحدة',
            icon: Icons.attach_money,
            suffix: 'ريال',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) return 'التكلفة مطلوبة';
              final cost = double.tryParse(value!);
              if (cost == null || cost < 0) {
                return 'التكلفة يجب أن تكون رقماً موجباً';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDamageTypeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.category, color: Colors.orange[700]),
              ),
              const SizedBox(width: 12),
              const Text(
                'نوع ومستوى التلف',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStyledDropdown(
            value: _selectedDamageType,
            label: 'نوع التلف',
            icon: Icons.category,
            items: _damageTypes,
            displayMapper: _getDamageTypeDisplay,
            onChanged: (value) =>
                setState(() => _selectedDamageType = value!),
          ),
          const SizedBox(height: 20),
          _buildStyledDropdown(
            value: _selectedSeverityLevel,
            label: 'مستوى الخطورة',
            icon: _getSeverityIcon(_selectedSeverityLevel),
            iconColor: _getSeverityColor(_selectedSeverityLevel),
            items: _severityLevels,
            onChanged: (value) =>
                setState(() => _selectedSeverityLevel = value!),
            itemBuilder: (level) => Row(
              children: [
                Icon(
                  _getSeverityIcon(level),
                  color: _getSeverityColor(level),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(level),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageReasonCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.edit, color: Colors.red[700]),
              ),
              const SizedBox(width: 12),
              const Text(
                'سبب التلف',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStyledTextField(
            controller: _damageReasonController,
            label: 'سبب التلف',
            icon: Icons.edit,
            hint: 'مثال: رطوبة، كسر، انتهاء صلاحية، إلخ',
            maxLines: 3,
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'سبب التلف مطلوب' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.info, color: Colors.purple[700]),
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات إضافية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStyledTextField(
            controller: _responsiblePersonController,
            label: 'الشخص المسؤول (اختياري)',
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
          _buildStyledTextField(
            controller: _batchNumberController,
            label: 'رقم الدفعة (اختياري)',
            icon: Icons.batch_prediction,
          ),
          const SizedBox(height: 20),
          _buildDatePicker(),
          const SizedBox(height: 20),
          _buildStyledTextField(
            controller: _notesController,
            label: 'ملاحظات إضافية',
            icon: Icons.note,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shield, color: Colors.green[700]),
              ),
              const SizedBox(width: 12),
              const Text(
                'معلومات التأمين',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
            ),
            child: SwitchListTile(
              title: const Text(
                'مشمول بالتأمين',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('هل هذا التلف مشمول بوثيقة التأمين؟'),
              value: _isInsuranceCovered,
              activeColor: Colors.green,
              onChanged: (value) {
                setState(() {
                  _isInsuranceCovered = value;
                  if (!value) _insuranceAmountController.clear();
                });
              },
            ),
          ),
          if (_isInsuranceCovered) ...[
            const SizedBox(height: 20),
            _buildStyledTextField(
              controller: _insuranceAmountController,
              label: 'مبلغ التأمين المتوقع',
              icon: Icons.shield,
              suffix: 'ريال',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (_isInsuranceCovered && (value?.trim().isEmpty ?? true)) {
                  return 'مبلغ التأمين مطلوب';
                }
                if (_isInsuranceCovered) {
                  final amount = double.tryParse(value!);
                  if (amount == null || amount <= 0) {
                    return 'المبلغ يجب أن يكون رقماً موجباً';
                  }
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? suffix,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildStyledDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    Color? iconColor,
    required List<T> items,
    String Function(T)? displayMapper,
    Widget Function(T)? itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: itemBuilder?.call(item) ??
              Text(displayMapper?.call(item) ?? item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _expiryDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) setState(() => _expiryDate = date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'تاريخ الانتهاء (اختياري)',
          prefixIcon: const Icon(Icons.event_busy),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        child: Text(
          _expiryDate?.toString().split(' ')[0] ?? 'اختر التاريخ',
          style: TextStyle(
            color: _expiryDate != null ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getSeverityColor(_selectedSeverityLevel),
            _getSeverityColor(_selectedSeverityLevel).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: _getSeverityColor(_selectedSeverityLevel).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _submitDamagedItem,
        icon: const Icon(Icons.save, color: Colors.white),
        label: const Text(
          'تسجيل التلف',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  String _getDamageTypeDisplay(String type) {
    switch (type) {
      case 'تلف_طبيعي':
        return 'تلف طبيعي';
      case 'تلف_بشري':
        return 'تلف بشري';
      case 'تلف_خارجي':
        return 'تلف خارجي';
      case 'انتهاء_صلاحية':
        return 'انتهاء صلاحية';
      default:
        return type;
    }
  }

  Color _getSeverityColor(String level) {
    switch (level) {
      case 'طفيف':
        return Colors.green;
      case 'متوسط':
        return Colors.orange;
      case 'كبير':
        return Colors.red;
      case 'كارثي':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String level) {
    switch (level) {
      case 'طفيف':
        return Icons.info;
      case 'متوسط':
        return Icons.warning;
      case 'كبير':
        return Icons.error;
      case 'كارثي':
        return Icons.dangerous;
      default:
        return Icons.broken_image;
    }
  }

  void _submitDamagedItem() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.parse(_quantityController.text);
    final unitCost = double.parse(_unitCostController.text);
    final insuranceAmount = _isInsuranceCovered
        ? double.tryParse(_insuranceAmountController.text)
        : null;

    context.read<InventoryBloc>().add(
          AddDamagedItemEvent(
            qatTypeId: 1, // سيتم تحديدها لاحقاً
            qatTypeName: _qatTypeNameController.text.trim(),
            unit: _selectedUnit,
            quantity: quantity,
            unitCost: unitCost,
            damageReason: _damageReasonController.text.trim(),
            damageType: _selectedDamageType,
            severityLevel: _selectedSeverityLevel,
            isInsuranceCovered: _isInsuranceCovered,
            insuranceAmount: insuranceAmount,
            responsiblePerson: _responsiblePersonController.text.trim().isNotEmpty
                ? _responsiblePersonController.text.trim()
                : null,
            batchNumber: _batchNumberController.text.trim().isNotEmpty
                ? _batchNumberController.text.trim()
                : null,
            expiryDate: _expiryDate?.toIso8601String().split('T')[0],
          ),
        );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تم تسجيل البضاعة التالفة بنجاح (مستوى: $_selectedSeverityLevel)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: _getSeverityColor(_selectedSeverityLevel),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
