import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/return_item.dart';
import '../../../blocs/inventory/inventory_bloc.dart';

/// نافذة إضافة مردود
class AddReturnDialog extends StatefulWidget {
  const AddReturnDialog({super.key});

  @override
  State<AddReturnDialog> createState() => _AddReturnDialogState();
}

class _AddReturnDialogState extends State<AddReturnDialog> {
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

  final List<String> _units = ['ربطة', 'كيس', 'كرتون', 'قطعة'];

  @override
  void dispose() {
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
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _selectedReturnType == 'مردود_مبيعات' 
                ? Icons.keyboard_return 
                : Icons.undo,
            color: _selectedReturnType == 'مردود_مبيعات' 
                ? Colors.orange 
                : Colors.blue,
          ),
          const SizedBox(width: 8),
          const Text('إضافة مردود'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // نوع المردود
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'نوع المردود',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('مردود مبيعات'),
                                value: 'مردود_مبيعات',
                                groupValue: _selectedReturnType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedReturnType = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('مردود مشتريات'),
                                value: 'مردود_مشتريات',
                                groupValue: _selectedReturnType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedReturnType = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // معلومات الصنف
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'معلومات الصنف',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _qatTypeNameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم الصنف',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory_2),
                          ),
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'اسم الصنف مطلوب';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _quantityController,
                                decoration: const InputDecoration(
                                  labelText: 'الكمية',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.numbers),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'الكمية مطلوبة';
                                  }
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
                              child: DropdownButtonFormField<String>(
                                value: _selectedUnit,
                                decoration: const InputDecoration(
                                  labelText: 'الوحدة',
                                  border: OutlineInputBorder(),
                                ),
                                items: _units.map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedUnit = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _unitPriceController,
                          decoration: const InputDecoration(
                            labelText: 'سعر الوحدة',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                            suffixText: 'ريال',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'سعر الوحدة مطلوب';
                            }
                            final price = double.tryParse(value!);
                            if (price == null || price < 0) {
                              return 'السعر يجب أن يكون رقماً موجباً';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // معلومات الشخص
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedReturnType == 'مردود_مبيعات' 
                              ? 'معلومات العميل' 
                              : 'معلومات المورد',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _selectedReturnType == 'مردود_مبيعات' 
                              ? _customerNameController 
                              : _supplierNameController,
                          decoration: InputDecoration(
                            labelText: _selectedReturnType == 'مردود_مبيعات' 
                                ? 'اسم العميل' 
                                : 'اسم المورد',
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(
                              _selectedReturnType == 'مردود_مبيعات' 
                                  ? Icons.person 
                                  : Icons.business,
                            ),
                          ),
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return _selectedReturnType == 'مردود_مبيعات' 
                                  ? 'اسم العميل مطلوب' 
                                  : 'اسم المورد مطلوب';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // سبب المردود
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'سبب المردود',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _returnReasonController,
                          decoration: const InputDecoration(
                            labelText: 'سبب المردود',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.edit),
                            hintText: 'مثال: عيب في المنتج، تلف أثناء النقل، إلخ',
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value?.trim().isEmpty ?? true) {
                              return 'سبب المردود مطلوب';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // ملاحظات إضافية
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ملاحظات إضافية (اختياري)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'ملاحظات',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.note),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _submitReturn,
          child: const Text('إضافة المردود'),
        ),
      ],
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${_selectedReturnType == 'مردود_مبيعات' ? 'مردود المبيعات' : 'مردود المشتريات'} بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
