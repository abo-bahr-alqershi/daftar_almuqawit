import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/injection_container.dart';
import '../../blocs/inventory/inventory_bloc.dart';
import '../../../domain/entities/inventory.dart';
import '../../../domain/entities/inventory_transaction.dart';
import '../../../domain/usecases/inventory/get_inventory_list.dart';
import 'widgets/inventory_list_widget.dart';
import 'widgets/inventory_filter_widget.dart';
import 'widgets/inventory_stats_card.dart';
import 'widgets/add_return_dialog.dart';
import 'widgets/add_damaged_item_dialog.dart';

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
  State<_InventoryScreenContent> createState() =>
      _InventoryScreenContentState();
}

class _InventoryScreenContentState extends State<_InventoryScreenContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    // _searchController already initialized above

    // تحميل البيانات الأولية
    context.read<InventoryBloc>().add(const LoadInventoryListEvent());
    context.read<InventoryBloc>().add(const LoadInventoryStatisticsEvent());

    // إضافة listener للتبديل بين التبويبات
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _onTabChanged(_tabController.index);
      }
    });
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
      appBar: AppBar(
        title: const Text('المخزون'),
        actions: [
          // أزرار حسب التبويب النشط
          BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              return AnimatedBuilder(
                animation: _tabController,
                builder: (builderContext, child) {
                  final currentIndex = _tabController.index;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (currentIndex == 3) // تبويب المردودات
                        IconButton(
                          icon: const Icon(Icons.keyboard_return),
                          tooltip: 'إضافة مردود',
                          onPressed: () => _showAddReturnDialog(context),
                        ),
                      if (currentIndex == 4) // تبويب التالف
                        IconButton(
                          icon: const Icon(Icons.broken_image),
                          tooltip: 'تسجيل تلف',
                          onPressed: () => _showAddDamagedItemDialog(context),
                        ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          context.read<InventoryBloc>().add(
                            const RefreshInventoryEvent(),
                          );
                        },
                      ),
                      if (currentIndex == 0 ||
                          currentIndex == 1) // تبويبات المخزون
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'إضافة صنف للمخزون',
                          onPressed: () {
                            _showAddInventoryDialog(context);
                          },
                        ),
                    ],
                  );
                },
              );
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
            isScrollable: true,
            tabs: const [
              Tab(text: 'جميع الأصناف', icon: Icon(Icons.inventory)),
              Tab(text: 'مخزون منخفض', icon: Icon(Icons.warning)),
              Tab(text: 'الحركات', icon: Icon(Icons.history)),
              Tab(text: 'المردودات'),
              Tab(text: 'التالف'),
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

                // تبويب المردودات
                BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) => _buildReturnsContent(state),
                ),

                // تبويب التالف
                BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) => _buildDamagedItemsContent(state),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  /// الأزرار العائمة حسب التبويب الحالي
  Widget _buildFloatingActionButtons() {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: _tabController,
          builder: (builderContext, child) {
            final currentIndex = _tabController.index;

            switch (currentIndex) {
              case 0: // جميع الأصناف
              case 1: // مخزون منخفض
                return FloatingActionButton(
                  onPressed: () => _showAddInventoryDialog(context),
                  child: const Icon(Icons.add),
                  tooltip: 'إضافة صنف للمخزون',
                  heroTag: "inventory_fab",
                );

              case 3: // المردودات
                return FloatingActionButton.extended(
                  onPressed: () => _showAddReturnDialog(context),
                  icon: const Icon(Icons.keyboard_return),
                  label: const Text('إضافة مردود'),
                  backgroundColor: Colors.orange,
                  heroTag: "returns_fab",
                );

              case 4: // التالف
                return FloatingActionButton.extended(
                  onPressed: () => _showAddDamagedItemDialog(context),
                  icon: const Icon(Icons.broken_image),
                  label: const Text('تسجيل تلف'),
                  backgroundColor: Colors.red,
                  heroTag: "damages_fab",
                );

              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  /// عرض نافذة إضافة مردود
  void _showAddReturnDialog(BuildContext context) {
    // حفظ مرجع للـ bloc قبل فتح الـ dialog
    final inventoryBloc = context.read<InventoryBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: inventoryBloc,
        child: const AddReturnDialog(),
      ),
    );
  }

  /// عرض نافذة إضافة بضاعة تالفة
  void _showAddDamagedItemDialog(BuildContext context) {
    // حفظ مرجع للـ bloc قبل فتح الـ dialog
    final inventoryBloc = context.read<InventoryBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: inventoryBloc,
        child: const AddDamagedItemDialog(),
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
      return const Center(child: CircularProgressIndicator());
    } else if (state is InventoryListLoaded) {
      return InventoryListWidget(
        inventory: state.inventory,
        onItemTap: (item) => _showInventoryDetails(item),
        onItemEdit: (item) => _showEditInventoryDialog(item),
        onAdjustQuantity: (item) => _showAdjustQuantityDialog(item),
      );
    } else if (state is InventoryError) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'حدث خطأ في تحميل البيانات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'تحقق من اتصال قاعدة البيانات',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<InventoryBloc>().add(
                    const LoadInventoryListEvent(),
                  );
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return const Center(child: Text('لا توجد بيانات'));
  }

  /// محتوى تبويب المخزون المنخفض
  Widget _buildLowStockContent(InventoryState state) {
    return BlocBuilder<InventoryBloc, InventoryState>(
      builder: (context, state) {
        // تحميل المخزون المنخفض
        context.read<InventoryBloc>().add(
          const LoadInventoryListEvent(
            filterType: InventoryFilterType.lowStock,
          ),
        );

        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                const Text('خطأ في تحميل البيانات'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<InventoryBloc>().add(
                      const LoadInventoryListEvent(
                        filterType: InventoryFilterType.lowStock,
                      ),
                    );
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
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
        context.read<InventoryBloc>().add(
          const LoadInventoryTransactionsEvent(),
        );

        if (state is InventoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is InventoryTransactionsLoaded) {
          return _buildTransactionsList(state.transactions);
        } else if (state is InventoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                const Text('خطأ في تحميل الحركات'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<InventoryBloc>().add(
                      const LoadInventoryTransactionsEvent(),
                    );
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
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
              backgroundColor: _getTransactionColor(
                transaction.transactionType,
              ),
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
                Text(
                  '${transaction.transactionDate} ${transaction.transactionTime}',
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.quantityChange > 0 ? '+' : ''}${transaction.quantityChange.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: transaction.quantityChange > 0
                        ? Colors.green
                        : Colors.red,
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

  /// التبديل بين التبويبات
  void _onTabChanged(int index) {
    switch (index) {
      case 0: // جميع الأصناف
        context.read<InventoryBloc>().add(const LoadInventoryListEvent());
        break;
      case 1: // مخزون منخفض
        context.read<InventoryBloc>().add(
          const LoadInventoryListEvent(
            filterType: InventoryFilterType.lowStock,
          ),
        );
        break;
      case 2: // الحركات
        context.read<InventoryBloc>().add(
          const LoadInventoryTransactionsEvent(),
        );
        break;
      case 3: // المردودات
        context.read<InventoryBloc>().add(const LoadReturnsEvent());
        break;
      case 4: // التالف
        context.read<InventoryBloc>().add(const LoadDamagedItemsEvent());
        break;
    }
  }

  /// محتوى تبويب المردودات
  Widget _buildReturnsContent(InventoryState state) {
    if (state is InventoryLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ReturnsLoadedState) {
      if (state.returns.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.assignment_return, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'لا توجد مردودات',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'ستظهر المردودات هنا عند إضافتها',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddReturnDialog(context),
                icon: const Icon(Icons.keyboard_return),
                label: const Text('إضافة مردود جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.returns.length,
              itemBuilder: (context, index) {
                final returnItem = state.returns[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: returnItem.isSalesReturn
                          ? Colors.orange
                          : Colors.blue,
                      child: Icon(
                        returnItem.isSalesReturn
                            ? Icons.keyboard_return
                            : Icons.undo,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(returnItem.qatTypeName ?? 'صنف غير معروف'),
                    subtitle: Text(
                      'السبب: ${returnItem.returnReason}\n'
                      'الكمية: ${returnItem.quantity} ${returnItem.unit}\n'
                      'المبلغ: ${returnItem.totalAmount.toStringAsFixed(2)} ريال',
                    ),
                    trailing: Chip(
                      label: Text(returnItem.status),
                      backgroundColor: _getStatusColor(returnItem.status),
                    ),
                    onTap: () => _showReturnDetails(returnItem),
                  ),
                );
              },
            ),
          ),
          // زر إضافة مردود جديد في أسفل القائمة
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddReturnDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('إضافة مردود جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (state is InventoryError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            const Text('خطأ في تحميل المردودات'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<InventoryBloc>().add(const LoadReturnsEvent());
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return const Center(child: Text('لا توجد بيانات'));
  }

  /// محتوى تبويب التالف
  Widget _buildDamagedItemsContent(InventoryState state) {
    if (state is InventoryLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is DamagedItemsLoadedState) {
      if (state.damagedItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'لا توجد بضاعة تالفة',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'ستظهر البضاعة التالفة هنا عند تسجيلها',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAddDamagedItemDialog(context),
                icon: const Icon(Icons.broken_image),
                label: const Text('تسجيل بضاعة تالفة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.damagedItems.length,
              itemBuilder: (context, index) {
                final damagedItem = state.damagedItems[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getSeverityColor(
                        damagedItem.severityLevel,
                      ),
                      child: Icon(
                        _getDamageIcon(damagedItem.severityLevel),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(damagedItem.qatTypeName ?? 'صنف غير معروف'),
                    subtitle: Text(
                      'السبب: ${damagedItem.damageReason}\n'
                      'الكمية: ${damagedItem.quantity} ${damagedItem.unit}\n'
                      'التكلفة: ${damagedItem.totalCost.toStringAsFixed(2)} ريال\n'
                      'الخطورة: ${damagedItem.severityLevel}',
                    ),
                    trailing: Chip(
                      label: Text(damagedItem.displayStatus),
                      backgroundColor: _getStatusColor(damagedItem.status),
                    ),
                    onTap: () => _showDamageDetails(damagedItem),
                  ),
                );
              },
            ),
          ),
          // زر تسجيل بضاعة تالفة جديدة
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddDamagedItemDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('تسجيل بضاعة تالفة جديدة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (state is InventoryError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            const Text('خطأ في تحميل البضاعة التالفة'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<InventoryBloc>().add(
                  const LoadDamagedItemsEvent(),
                );
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return const Center(child: Text('لا توجد بيانات'));
  }

  /// لون الحالة
  Color _getStatusColor(String status) {
    switch (status) {
      case 'مؤكد':
        return Colors.green.shade100;
      case 'معلق':
        return Colors.orange.shade100;
      case 'ملغي':
        return Colors.red.shade100;
      case 'تحت_المراجعة':
        return Colors.blue.shade100;
      case 'تم_التعامل_معه':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  /// لون مستوى الخطورة
  Color _getSeverityColor(String severityLevel) {
    switch (severityLevel) {
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

  /// أيقونة التلف
  IconData _getDamageIcon(String severityLevel) {
    switch (severityLevel) {
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

  /// عرض تفاصيل المردود
  void _showReturnDetails(dynamic returnItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل المردود: ${returnItem.returnNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الصنف: ${returnItem.qatTypeName}'),
            Text('النوع: ${returnItem.displayReturnType}'),
            Text('الكمية: ${returnItem.quantity} ${returnItem.unit}'),
            Text('السعر: ${returnItem.unitPrice} ريال'),
            Text('المبلغ الإجمالي: ${returnItem.totalAmount} ريال'),
            Text('السبب: ${returnItem.returnReason}'),
            Text('الحالة: ${returnItem.status}'),
            if (returnItem.notes?.isNotEmpty == true)
              Text('الملاحظات: ${returnItem.notes}'),
          ],
        ),
        actions: [
          if (returnItem.isPending)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<InventoryBloc>().add(
                  ConfirmReturnEvent(returnItem.id),
                );
              },
              child: const Text('تأكيد المردود'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  /// عرض تفاصيل التلف
  void _showDamageDetails(dynamic damagedItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل التلف: ${damagedItem.damageNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الصنف: ${damagedItem.qatTypeName}'),
            Text('النوع: ${damagedItem.displayDamageType}'),
            Text('الكمية: ${damagedItem.quantity} ${damagedItem.unit}'),
            Text('التكلفة: ${damagedItem.totalCost} ريال'),
            Text('السبب: ${damagedItem.damageReason}'),
            Text('الخطورة: ${damagedItem.severityLevel}'),
            Text('الحالة: ${damagedItem.displayStatus}'),
            if (damagedItem.isInsuranceCovered)
              Text('مشمول بالتأمين: ${damagedItem.insuranceAmount} ريال'),
            if (damagedItem.responsiblePerson?.isNotEmpty == true)
              Text('المسؤول: ${damagedItem.responsiblePerson}'),
          ],
        ),
        actions: [
          if (damagedItem.isUnderReview)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<InventoryBloc>().add(
                  ConfirmDamageEvent(damagedItem.id),
                );
              },
              child: const Text('تأكيد التلف'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
