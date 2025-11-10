import 'package:flutter/material.dart';

/// قائمة مع تمرير لا نهائي
class InfiniteScrollList<T> extends StatefulWidget {
  final Future<List<T>> Function() onLoadMore;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? emptyWidget;
  final Widget? loadingWidget;

  const InfiniteScrollList({
    super.key,
    required this.onLoadMore,
    required this.itemBuilder,
    this.emptyWidget,
    this.loadingWidget,
  });

  @override
  State<InfiniteScrollList<T>> createState() => _InfiniteScrollListState<T>();
}

class _InfiniteScrollListState<T> extends State<InfiniteScrollList<T>> {
  final List<T> _items = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newItems = await widget.onLoadMore();
      setState(() {
        _items.addAll(newItems);
        _hasMore = newItems.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && !_isLoading) {
      return widget.emptyWidget ?? const Center(child: Text('لا توجد بيانات'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return widget.loadingWidget ?? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
        }
        return widget.itemBuilder(context, _items[index], index);
      },
    );
  }
}
