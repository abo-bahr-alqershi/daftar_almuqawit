import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/sale.dart';
import '../../blocs/sales/sales_bloc.dart';
import '../../blocs/sales/sales_event.dart';
import '../../blocs/sales/sales_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as app_error;
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../navigation/route_names.dart';
import 'widgets/sale_item_card.dart';
import 'widgets/sale_summary.dart';
import 'widgets/sale_filters.dart';

/// الشاشة الرئيسية لإدارة المبيعات
class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  String _filterType = 'الكل';
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = '';
  
  final List<String> _filterTypes = [
    'الكل',
    'اليوم',
    'الأسبوع',
    'الشهر',
    'مدفوع',
    'غير مدفوع',
    'بيع سريع',
  ];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  void _loadSales() {
    if (_filterType == 'اليوم') {
      context.read<SalesBloc>().add(
        LoadTodaySales(_selectedDate.toIso8601String().split('T')[0]),
      );
    } else {
      context.read<SalesBloc>().add(LoadSales());
    }
  }

  void _showAddSaleScreen() {
    Navigator.pushNamed(context, RouteNames.addSale).then((_) => _loadSales());
  }

  void _showQuickSaleScreen() {
    Navigator.pushNamed(context, RouteNames.quickSale).then((_) => _loadSales());
  }

  void _showSaleDetails(Sale sale) {
    Navigator.pushNamed(
      context,
      RouteNames.saleDetails,
      arguments: sale,
    ).then((_) => _loadSales());
  }

  Future<void> _deleteSale(Sale sale) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'حذف البيع',
      message: 'هل أنت متأكد من حذف هذا البيع؟\nسيتم حذف جميع البيانات المرتبطة به.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && sale.id != null) {
      context.read<SalesBloc>().add(DeleteSaleEvent(sale.id!));
    }
  }

  Future<void> _cancelSale(Sale sale) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'إلغاء البيع',
      message: 'هل أنت متأكد من إلغاء هذا البيع؟\nسيتم تحديث حالته إلى "ملغي".',
      confirmText: 'إلغاء البيع',
      cancelText: 'رجوع',
      isDangerous: true,
    );

    if (confirmed == true && sale.id != null) {
      context.read<SalesBloc>().add(CancelSaleEvent(sale.id!));
    }
  }

  List<Sale> _filterSales(List<Sale> sales) {
    var filtered = sales;

    // تصفية حسب البحث
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((sale) {
        final customerName = sale.customerName?.toLowerCase() ?? '';
        final qatTypeName = sale.qatTypeName?.toLowerCase() ?? '';
        final invoiceNumber = sale.invoiceNumber?.toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();
        
        return customerName.contains(query) ||
               qatTypeName.contains(query) ||
               invoiceNumber.contains(query);
      }).toList();
    }

    // تصفية حسب النوع
    if (_filterType != 'الكل' && _filterType != 'اليوم') {
      final now = DateTime.now();
      
      filtered = filtered.where((sale) {
        final saleDate = DateTime.parse(sale.date);
        
        switch (_filterType) {
          case 'الأسبوع':
            return now.difference(saleDate).inDays <= 7;
          case 'الشهر':
            return saleDate.year == now.year && 
                   saleDate.month == now.month;
          case 'مدفوع':
            return sale.paymentStatus == 'مدفوع';
          case 'غير مدفوع':
            return sale.paymentStatus == 'غير مدفوع' ||
                   sale.paymentStatus == 'مدفوع جزئياً';
          case 'بيع سريع':
            return sale.isQuickSale;
          default:
            return true;
        }
      }).toList();
    }

    // الترتيب حسب التاريخ والوقت
    filtered.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.time.compareTo(a.time);
    });

    return filtered;
  }

  double _calculateTotalAmount(List<Sale> sales) {
    return sales.fold(0, (sum, sale) => sum + sale.totalAmount);
  }

  double _calculateTotalProfit(List<Sale> sales) {
    return sales.fold(0, (sum, sale) => sum + sale.profit);
  }

  double _calculateTotalPaid(List<Sale> sales) {
    return sales.fold(0, (sum, sale) => sum + sale.paidAmount);
  }

  double _calculateTotalRemaining(List<Sale> sales) {
    return sales.fold(0, (sum, sale) => sum + sale.remainingAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: Text(
            'المبيعات',
            style: AppTextStyles.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white),
              tooltip: 'بيع سريع',
              onPressed: _showQuickSaleScreen,
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadSales,
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => SaleFilters(
                    selectedFilter: _filterType,
                    searchQuery: _searchQuery,
                    onFilterChanged: (filter) {
                      setState(() {
                        _filterType = filter;
                      });
                      _loadSales();
                      Navigator.pop(context);
                    },
                    onSearchChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<SalesBloc, SalesState>(
          listener: (context, state) {
            if (state is SaleOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              _loadSales();
            } else if (state is SalesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SalesLoading) {
              return const Center(child: LoadingWidget());
            }

            if (state is SalesError && state is! SalesLoaded) {
              return app_error.ErrorWidget(
                message: state.message,
                onRetry: _loadSales,
              );
            }

            if (state is SalesLoaded) {
              final filteredSales = _filterSales(state.sales);

              if (state.sales.isEmpty) {
                return EmptyWidget(
                  icon: Icons.point_of_sale,
                  title: 'لا توجد مبيعات',
                  message: 'لم يتم تسجيل أي مبيعات بعد',
                  actionLabel: 'إضافة بيع جديد',
                  onAction: _showAddSaleScreen,
                );
              }

              if (filteredSales.isEmpty) {
                return EmptyWidget(
                  icon: Icons.search_off,
                  title: 'لا توجد نتائج',
                  message: 'لم يتم العثور على مبيعات تطابق الفلاتر المحددة',
                  actionLabel: 'إعادة تعيين الفلاتر',
                  onAction: () {
                    setState(() {
                      _filterType = 'الكل';
                      _searchQuery = '';
                      _selectedDate = DateTime.now();
                    });
                    _loadSales();
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadSales(),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // شريط البحث
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        color: AppColors.surface,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'البحث عن عميل، نوع قات، أو رقم فاتورة...',
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: AppColors.textSecondary),
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingS,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),

                      // ملخص المبيعات
                      SaleSummary(
                        totalAmount: _calculateTotalAmount(filteredSales),
                        totalProfit: _calculateTotalProfit(filteredSales),
                        totalPaid: _calculateTotalPaid(filteredSales),
                        totalRemaining: _calculateTotalRemaining(filteredSales),
                        salesCount: filteredSales.length,
                      ),

                      // عنوان القائمة
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.paddingL,
                          AppDimensions.paddingM,
                          AppDimensions.paddingL,
                          AppDimensions.paddingS,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'قائمة المبيعات',
                              style: AppTextStyles.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${filteredSales.length} عملية',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // قائمة المبيعات
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingL,
                          vertical: AppDimensions.paddingS,
                        ),
                        itemCount: filteredSales.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final sale = filteredSales[index];
                          return SaleItemCard(
                            sale: sale,
                            onTap: () => _showSaleDetails(sale),
                            onDelete: () => _deleteSale(sale),
                            onCancel: sale.status == 'نشط' 
                                ? () => _cancelSale(sale) 
                                : null,
                          );
                        },
                      ),
                      
                      // مساحة إضافية في الأسفل
                      const SizedBox(height: AppDimensions.paddingXL),
                    ],
                  ),
                ),
              );
            }

            return const EmptyWidget(
              icon: Icons.point_of_sale,
              title: 'لا توجد مبيعات',
              message: 'ابدأ بإضافة بيع جديد',
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'quick_sale',
              onPressed: _showQuickSaleScreen,
              backgroundColor: AppColors.accent,
              child: const Icon(Icons.flash_on, color: Colors.white),
            ),
            const SizedBox(height: AppDimensions.paddingS),
            FloatingActionButton.extended(
              heroTag: 'add_sale',
              onPressed: _showAddSaleScreen,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'إضافة بيع',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
