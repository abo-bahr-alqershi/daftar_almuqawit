import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/dependency_injection.dart';
import '../../blocs/inventory/inventory_bloc.dart';
import '../../widgets/common/app_bar_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import 'widgets/inventory_list_widget.dart';
import 'widgets/inventory_filter_widget.dart';
import 'widgets/inventory_stats_card.dart';

/// شاشة المخزون الرئيسية
class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<InventoryBloc>()
        ..add(const LoadInventoryListEvent())
        ..add(const LoadInventoryStatisticsEvent()),
      child: const _InventoryScreenContent(),
    );
  }
}

class _InventoryScreenContent extends StatefulWidget {
  const _InventoryScreenContent();

  @override
  State<_InventoryScreenContent> createState() => _InventoryScreenContentState();
}

class _InventoryScreenContentState extends State<_InventoryScreenContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'المخزون',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<InventoryBloc>().add(const RefreshInventoryEvent());
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddInventoryDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث والتصفية
          _buildSearchAndFilterBar(),
          
          // إحصائيات المخزون
          BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              if (state is InventoryStatisticsLoaded) {
                return InventoryStatsCard(statistics: state.statistics);
              }
              return const SizedBox.shrink();
            },
          ),
          
          // التبويبات
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'جميع الأصناف', icon: Icon(Icons.inventory)),
              Tab(text: 'مخزون منخفض', icon: Icon(Icons.warning)),
              Tab(text: 'الحركات', icon: Icon(Icons.history)),
            ],
          ),
          
          // محتوى التبويبات
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // تبويب جميع الأصناف
                BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) => _buildInventoryContent(state),
                ),
                
                // تبويب المخزون المنخفض
                BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) => _buildLowStockContent(state),
                ),
                
                // تبويب الحركات
                BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) => _buildTransactionsContent(state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// شريط البحث والتصفية
  Widget _buildSearchAndFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // حقل البحث
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'بحث في المخزون...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (query) {
                context.read<InventoryBloc>().add(SearchInventoryEvent(query));
              },
            ),
          ),
          
          const SizedBox(width: 8),
          
          // زر التصفية
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
    );
  }

  /// محتوى تبويب جميع الأصناف
  Widget _buildInventoryContent(InventoryState state) {
    if (state is InventoryLoading) {
      return const LoadingWidget();
    } else if (state is InventoryListLoaded) {
      return InventoryListWidget(
        inventory: state.inventory,
        onItemTap: (item) => _showInventoryDetails(item),
        onItemEdit: (item) => _showEditInventoryDialog(item),
        onAdjustQuantity: (item) => _showAdjustQuantityDialog(item),
      );
    } else if (state is InventoryError) {
      return CustomErrorWidget(
        message: state.message,
        onRetry: () {
          context.read<InventoryBloc>().add(const LoadInventoryListEvent());
        },
      );
    }
    
    return const Center(
      child: Text('لا توجد بيانات'),
    );
  }

  /// محتوى تبويب المخزون المنخفض
  Widget _buildLowStockContent(InventoryState state) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        // تحميل المخزون المنخفض
        context.read<InventoryBloc>().add(
          const LoadInventoryListEvent(filterType: InventoryFilterType.lowStock)
        );
        
        if (state is InventoryLoading) {
          return const LoadingWidget();
        } else if (state is InventoryListLoaded) {
          if (state.inventory.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'ممتاز! لا يوجد مخزون منخفض',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }
          
          return InventoryListWidget(
            inventory: state.inventory,
            showLowStockWarning: true,
            onItemTap: (item) => _showInventoryDetails(item),
            onItemEdit: (item) => _showEditInventoryDialog(item),
            onAdjustQuantity: (item) => _showAdjustQuantityDialog(item),
          );
        } else if (state is InventoryError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<InventoryBloc>().add(
                const LoadInventoryListEvent(filterType: InventoryFilterType.lowStock)
              );
            },
          );
        }
        
        return const Center(child: Text('لا توجد بيانات'));
      },
    );
  }

  /// محتوى تبويب الحركات
  Widget _buildTransactionsContent(InventoryState state) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        // تحميل حركات المخزون
        context.read<InventoryBloc>().add(const LoadInventoryTransactionsEvent());
        
        if (state is InventoryLoading) {
          return const LoadingWidget();
        } else if (state is InventoryTransactionsLoaded) {
          return _buildTransactionsList(state.transactions);
        } else if (state is InventoryError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<InventoryBloc>().add(const LoadInventoryTransactionsEvent());
            },
          );
        }
        
        return const Center(child: Text('لا توجد حركات'));
      },
    );
  }

  /// قائمة حركات المخزون
  Widget _buildTransactionsList(List<InventoryTransaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('لا توجد حركات مخزون'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getTransactionColor(transaction.transactionType),
              child: Icon(
                _getTransactionIcon(transaction.transactionType),
                color: Colors.white,
              ),
            ),
            title: Text(transaction.qatTypeName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${transaction.transactionType} - ${transaction.unit}'),
                Text('${transaction.transactionDate} ${transaction.transactionTime}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.quantityChange > 0 ? '+' : ''}${transaction.quantityChange.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: transaction.quantityChange > 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'المتبقي: ${transaction.quantityAfter.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= Helper Methods =================

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'شراء':
      case 'مرتجع':
        return Colors.green;
      case 'بيع':
      case 'تالف':
        return Colors.red;
      case 'تعديل':
      case 'جرد':
        return Colors.blue;
      case 'تحويل':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'شراء':
        return Icons.add_shopping_cart;
      case 'بيع':
        return Icons.sell;
      case 'تعديل':
        return Icons.edit;
      case 'تحويل':
        return Icons.compare_arrows;
      case 'تالف':
        return Icons.broken_image;
      case 'مرتجع':
        return Icons.keyboard_return;
      case 'جرد':
        return Icons.inventory;
      default:
        return Icons.history;
    }
  }

  // ================= Dialog Methods =================

  void _showAddInventoryDialog(BuildContext context) {
    // TODO: تطبيق نافذة إضافة عنصر مخزون
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة عنصر مخزون'),
        content: const Text('سيتم تطبيق هذه الميزة قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showEditInventoryDialog(Inventory item) {
    // TODO: تطبيق نافذة تعديل عنصر المخزون
  }

  void _showAdjustQuantityDialog(Inventory item) {
    // TODO: تطبيق نافذة تعديل الكمية
  }

  void _showInventoryDetails(Inventory item) {
    // TODO: تطبيق شاشة تفاصيل المخزون
  }

  void _showFilterDialog(BuildContext context) {
    // TODO: تطبيق نافذة التصفية
  }
}
