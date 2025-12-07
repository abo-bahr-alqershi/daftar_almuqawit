import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SupplierSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function(String)? onSearch;
  final VoidCallback? onClear;
  final String? hintText;

  const SupplierSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onSearch,
    this.onClear,
    this.hintText,
  });

  @override
  State<SupplierSearchBar> createState() => _SupplierSearchBarState();
}

class _SupplierSearchBarState extends State<SupplierSearchBar> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
          width: _isFocused ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          setState(() {});
          widget.onChanged?.call(value);
          widget.onSearch?.call(value);
        },
        onSubmitted: (value) {
          widget.onSubmitted?.call(value);
          widget.onSearch?.call(value);
        },
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _isFocused = true);
        },
        onTapOutside: (_) {
          setState(() => _isFocused = false);
          FocusScope.of(context).unfocus();
        },
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1A2E),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'البحث عن مورد...',
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF6B7280),
                      size: 12,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _controller.clear();
                    setState(() {});
                    widget.onClear?.call();
                    widget.onChanged?.call('');
                    widget.onSearch?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
