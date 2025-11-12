import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/damaged_item.dart';
import '../../../blocs/inventory/inventory_bloc.dart';

/// نافذة إضافة بضاعة تالفة
class AddDamagedItemDialog extends StatefulWidget {
  const AddDamagedItemDialog({super.key});

  @override
  State<AddDamagedItemDialog> createState() => _AddDamagedItemDialogState();
}

class _AddDamagedItemDialogState extends State<AddDamagedItemDialog> {
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

  final List<String> _units = ['ربطة', 'كيس', 'كرتون', 'قطعة'];
  final List<String> _damageTypes = [
    'تلف_طبيعي',
    'تلف_بشري', 
    'تلف_خارجي',
    'انتهاء_صلاحية'
  ];
  final List<String> _severityLevels = ['طفيف', 'متوسط', 'كبير', 'كارثي'];

  @override
  void dispose() {
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
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.broken_image,
            color: _getSeverityColor(_selectedSeverityLevel),
          ),
          const SizedBox(width: 8),
          const Text('تسجيل بضاعة تالفة'),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // معلومات الصنف
                _buildProductInfoCard(),
                const SizedBox(height: 16),
                
                // نوع ومستوى التلف
                _buildDamageTypeCard(),
                const SizedBox(height: 16),
                
                // سبب التلف
                _buildDamageReasonCard(),
                const SizedBox(height: 16),
                
                // معلومات إضافية
                _buildAdditionalInfoCard(),
                const SizedBox(height: 16),
                
                // معلومات التأمين
                _buildInsuranceCard(),
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
          onPressed: _submitDamagedItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getSeverityColor(_selectedSeverityLevel),
          ),
          child: const Text('تسجيل التلف'),
        ),
      ],
    );
  }

  Widget _buildProductInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات الصنف',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _qatTypeNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الصنف التالف',
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
                      labelText: 'الكمية التالفة',
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
              controller: _unitCostController,
              decoration: const InputDecoration(
                labelText: 'تكلفة الوحدة',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'ريال',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'التكلفة مطلوبة';
                }
                final cost = double.tryParse(value!);
                if (cost == null || cost < 0) {
                  return 'التكلفة يجب أن تكون رقماً موجباً';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDamageTypeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نوع ومستوى التلف',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDamageType,
              decoration: const InputDecoration(
                labelText: 'نوع التلف',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _damageTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getDamageTypeDisplay(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDamageType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSeverityLevel,
              decoration: InputDecoration(
                labelText: 'مستوى الخطورة',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  _getSeverityIcon(_selectedSeverityLevel),
                  color: _getSeverityColor(_selectedSeverityLevel),
                ),
              ),
              items: _severityLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Row(
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
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSeverityLevel = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDamageReasonCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'سبب التلف',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _damageReasonController,
              decoration: const InputDecoration(
                labelText: 'سبب التلف',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
                hintText: 'مثال: رطوبة، كسر، انتهاء صلاحية، إلخ',
              ),
              maxLines: 2,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'سبب التلف مطلوب';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات إضافية',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _responsiblePersonController,
              decoration: const InputDecoration(
                labelText: 'الشخص المسؤول (اختياري)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _batchNumberController,
              decoration: const InputDecoration(
                labelText: 'رقم الدفعة (اختياري)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.batch_prediction),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _expiryDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() {
                    _expiryDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'تاريخ الانتهاء (اختياري)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event_busy),
                ),
                child: Text(
                  _expiryDate?.toString().split(' ')[0] ?? 'اختر التاريخ',
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'ملاحظات إضافية',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات التأمين',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('مشمول بالتأمين'),
              subtitle: const Text('هل هذا التلف مشمول بوثيقة التأمين؟'),
              value: _isInsuranceCovered,
              onChanged: (value) {
                setState(() {
                  _isInsuranceCovered = value;
                  if (!value) {
                    _insuranceAmountController.clear();
                  }
                });
              },
            ),
            if (_isInsuranceCovered) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _insuranceAmountController,
                decoration: const InputDecoration(
                  labelText: 'مبلغ التأمين المتوقع',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shield),
                  suffixText: 'ريال',
                ),
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
        content: Text('تم تسجيل البضاعة التالفة بنجاح (مستوى: $_selectedSeverityLevel)'),
        backgroundColor: _getSeverityColor(_selectedSeverityLevel),
      ),
    );
  }
}
