import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/return_item.dart';
import '../../blocs/inventory/inventory_bloc.dart';

/// صفحة إضافة مردود - تصميم راقي
class AddReturnScreen extends StatefulWidget {
  const AddReturnScreen({super.key});

  @override
  State<AddReturnScreen> createState() => _AddReturnScreenState();
}

class _AddReturnScreenState extends State<AddReturnScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _qatTypeNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _returnReasonController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _supplierNameController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedReturnType = 'مردود_مبيعات';
  String _selectedUnit = 'ربطة';

  late AnimationController _animationController;
  late AnimationController _typeAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final List<String> _units = ['ربطة', 'كيس', 'كرتون', 'قطعة'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _typeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _typeAnimationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _typeAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _typeAnimationController.dispose();
    _qatTypeNameController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _returnReasonController.dispose();
    _customerNameController.dispose();
    _supplierNameController.dispose();
    _notesController.dispose();
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
                  _buildReturnTypeCard(),
                  const SizedBox(height: 24),
                  _buildProductInfoCard(),
                  const SizedBox(height: 24),
                  _buildPersonInfoCard(),
                  const SizedBox(height: 24),
                  _buildReturnReasonCard(),
                  const SizedBox(height: 24),
                  _buildNotesCard(),
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
    final color = _selectedReturnType == 'مردود_مبيعات' ? Colors.orange : Colors.blue;
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _selectedReturnType == 'مردود_مبيعات'
                  ? Icons.keyboard_return
                  : Icons.undo,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'إضافة مردود',
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
    final color = _selectedReturnType == 'مردود_مبيعات' ? Colors.orange : Colors.blue;
    final icon = _selectedReturnType == 'مردود_مبيعات'
        ? Icons.keyboard_return
        : Icons.undo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          const Text(
            'إضافة مردود',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل تفاصيل المردود بدقة لضمان المتابعة الصحيحة',
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

  Widget _buildReturnTypeCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
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
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.category, color: Colors.indigo[700]),
                ),
                const SizedBox(width: 12),
                const Text(
                  'نوع المردود',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildReturnTypeOption(
                    'مردود_مبيعات',
                    'مردود مبيعات',
                    Icons.keyboard_return,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildReturnTypeOption(
                    'مردود_مشتريات',
                    'مردود مشتريات',
                    Icons.undo,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReturnTypeOption(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedReturnType == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReturnType = value;
        });
        _typeAnimationController.reset();
        _typeAnimationController.forward();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.inventory_2, color: Colors.teal[700]),
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
            label: 'اسم الصنف',
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
                  label: 'الكمية',
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
            controller: _unitPriceController,
            label: 'سعر الوحدة',
            icon: Icons.attach_money,
            suffix: 'ريال',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) return 'سعر الوحدة مطلوب';
              final price = double.tryParse(value!);
              if (price == null || price < 0) {
                return 'السعر يجب أن يكون رقماً موجباً';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonInfoCard() {
    final isCustomer = _selectedReturnType == 'مردود_مبيعات';
    final color = isCustomer ? Colors.orange : Colors.blue;
    final icon = isCustomer ? Icons.person : Icons.business;
    final title = isCustomer ? 'معلومات العميل' : 'معلومات المورد';
    final label = isCustomer ? 'اسم العميل' : 'اسم المورد';
    final controller = isCustomer ? _customerNameController : _supplierNameController;

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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStyledTextField(
            controller: controller,
            label: label,
            icon: icon,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return isCustomer ? 'اسم العميل مطلوب' : 'اسم المورد مطلوب';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReturnReasonCard() {
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
                'سبب المردود',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStyledTextField(
            controller: _returnReasonController,
            label: 'سبب المردود',
            icon: Icons.edit,
            hint: 'مثال: عيب في المنتج، تلف أثناء النقل، إلخ',
            maxLines: 3,
            validator: (value) =>
                (value?.trim().isEmpty ?? true) ? 'سبب المردود مطلوب' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
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
                child: Icon(Icons.note, color: Colors.purple[700]),
              ),
              const SizedBox(width: 12),
              const Text(
                'ملاحظات إضافية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildStyledTextField(
            controller: _notesController,
            label: 'ملاحظات (اختياري)',
            icon: Icons.note,
            maxLines: 3,
          ),
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
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
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
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSubmitButton() {
    final color = _selectedReturnType == 'مردود_مبيعات' ? Colors.orange : Colors.blue;
    final label = _selectedReturnType == 'مردود_مبيعات' 
        ? 'إضافة مردود المبيعات' 
        : 'إضافة مردود المشتريات';

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _submitReturn,
        icon: const Icon(Icons.save, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
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

  void _submitReturn() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.parse(_quantityController.text);
    final unitPrice = double.parse(_unitPriceController.text);

    context.read<InventoryBloc>().add(
          AddReturnEvent(
            qatTypeId: 1, // سيتم تحديدها لاحقاً عند ربطها بنظام إدارة الأصناف
            qatTypeName: _qatTypeNameController.text.trim(),
            unit: _selectedUnit,
            quantity: quantity,
            unitPrice: unitPrice,
            returnReason: _returnReasonController.text.trim(),
            returnType: _selectedReturnType,
            customerName: _selectedReturnType == 'مردود_مبيعات'
                ? _customerNameController.text.trim()
                : null,
            supplierName: _selectedReturnType == 'مردود_مشتريات'
                ? _supplierNameController.text.trim()
                : null,
          ),
        );

    Navigator.pop(context);

    final color = _selectedReturnType == 'مردود_مبيعات' ? Colors.orange : Colors.blue;
    final message = _selectedReturnType == 'مردود_مبيعات'
        ? 'تم إضافة مردود المبيعات بنجاح'
        : 'تم إضافة مردود المشتريات بنجاح';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
