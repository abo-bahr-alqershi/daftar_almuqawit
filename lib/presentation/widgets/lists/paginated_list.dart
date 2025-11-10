import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// قائمة مع ترقيم صفحات
class PaginatedList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int pageSize) onFetchData;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final int pageSize;
  final Widget? emptyWidget;
  final Widget? errorWidget;

  const PaginatedList({
    super.key,
    required this.onFetchData,
    required this.itemBuilder,
    this.pageSize = 20,
    this.emptyWidget,
    this.errorWidget,
  });

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  final List<T> _items = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final newItems = await widget.onFetchData(_currentPage, widget.pageSize);
      setState(() {
        _items.addAll(newItems);
        _hasMore = newItems.length >= widget.pageSize;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _items.isEmpty) {
      return widget.errorWidget ?? Center(child: Text('خطأ: $_error'));
    }

    if (_items.isEmpty && !_isLoading) {
      return widget.emptyWidget ?? const Center(child: Text('لا توجد بيانات'));
    }

    return ListView.builder(
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          if (!_isLoading) _loadMore();
          return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
        }
        return widget.itemBuilder(context, _items[index], index);
      },
    );
  }
}
