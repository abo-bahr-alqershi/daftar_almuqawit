import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// مدخل الكمية - تصميم راقي واحترافي
class QuantityInput extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double step;
  final String unit;
  final String? label;

  const QuantityInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1000,
    this.step = 1,
    this.unit = 'علاقية',
    this.label,
  });

  @override
  State<QuantityInput> createState() => _QuantityInputState();
}

class _QuantityInputState extends State<QuantityInput> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(1));
  }

  @override
  void didUpdateWidget(QuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditing) {
      _controller.text = widget.value.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    HapticFeedback.selectionClick();
    final newValue = (widget.value + widget.step).clamp(widget.min, widget.max);
    widget.onChanged(newValue);
    _controller.text = newValue.toStringAsFixed(1);
  }

  void _decrement() {
    HapticFeedback.selectionClick();
    final newValue = (widget.value - widget.step).clamp(widget.min, widget.max);
    widget.onChanged(newValue);
    _controller.text = newValue.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isEditing
                  ? const Color(0xFF6366F1).withOpacity(0.3)
                  : const Color(0xFFE5E7EB),
              width: _isEditing ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _buildControlButton(
                icon: Icons.remove_rounded,
                onTap: _decrement,
                enabled: widget.value > widget.min,
              ),
              Expanded(
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TextField(
                          controller: _controller,
                          textAlign: TextAlign.center,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6366F1),
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onTap: () => setState(() => _isEditing = true),
                          onChanged: (value) {
                            final number = double.tryParse(value);
                            if (number != null) {
                              widget.onChanged(
                                number.clamp(widget.min, widget.max),
                              );
                            }
                          },
                          onEditingComplete: () {
                            setState(() => _isEditing = false);
                            FocusScope.of(context).unfocus();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.unit,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildControlButton(
                icon: Icons.add_rounded,
                onTap: _increment,
                enabled: widget.value < widget.max,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickSelectionButtons(),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF6366F1).withOpacity(0.08)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF6366F1) : const Color(0xFFD1D5DB),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildQuickSelectionButtons() {
    final quickValues = [1.0, 5.0, 10.0, 20.0];

    return Row(
      children: quickValues.map((value) {
        final isSelected = widget.value == value;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onChanged(value);
              _controller.text = value.toStringAsFixed(1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(left: value == quickValues.last ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE5E7EB),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
