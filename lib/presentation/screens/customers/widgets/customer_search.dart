import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomerSearch extends StatefulWidget {
  final String? initialQuery;
  final void Function(String query)? onSearch;

  const CustomerSearch({super.key, this.initialQuery, this.onSearch});

  @override
  State<CustomerSearch> createState() => _CustomerSearchState();
}

class _CustomerSearchState extends State<CustomerSearch> {
  late final TextEditingController _searchController;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    widget.onSearch?.call(query);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? const Color(0xFF6366F1).withOpacity(0.08)
                : Colors.black.withOpacity(0.02),
            blurRadius: _isFocused ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {});
          _handleSearch(value);
        },
        onSubmitted: _handleSearch,
        onTap: () {
          HapticFeedback.lightImpact();
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
          hintText: 'ابحث عن عميل بالاسم، الهاتف أو الكنية...',
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.search_outlined,
              color: Color(0xFF6366F1),
              size: 18,
            ),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFFDC2626),
                      size: 14,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _searchController.clear();
                    setState(() {});
                    _handleSearch('');
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
