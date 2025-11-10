import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/purchase.dart';
import '../../blocs/purchases/purchases_bloc.dart';
import '../../blocs/purchases/purchases_event.dart';
import '../../blocs/purchases/purchases_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as app_error;
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/confirm_dialog.dart';
import 'widgets/purchase_item_card.dart';
import 'widgets/purchase_summary.dart';
import 'add_purchase_screen.dart';
import 'purchase_details_screen.dart';

/// الشاشة الرئيسية لإدارة المشتريات
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  String _filterType = 'الكل';
  DateTime _selectedDate = DateTime.now();
  
  final List<String> _filterTypes = [
    'الكل',
    'اليوم',
    'الأسبوع',
    'الشهر',
    'مدفوع',
    'غير مدفوع',
  ];

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  void _loadPurchases() {
    if (_filterType == 'اليوم') {
      context.read<PurchasesBloc>().add(
        LoadTodayPurchases(_selectedDate.toIso8601String().split('T')[0]),
      );
    } else {
      context.read<PurchasesBloc>().add(LoadPurchases());
    }
  }

  void _showAddPurchaseScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPurchaseScreen(),
      ),
    ).then((_) => _loadPurchases());
  }

  void _showPurchaseDetails(Purchase purchase) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseDetailsScreen(purchase: purchase),
      ),
    ).then((_) => _loadPurchases());
  }

  Future<void> _deletePurchase(Purchase purchase) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'حذف المشترى',
      message: 'هل أنت متأكد من حذف هذا المشترى؟\nسيتم حذف جميع البيانات المرتبطة به.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      isDangerous: true,
    );

    if (confirmed == true && purchase.id != null) {
      context.read<PurchasesBloc>().add(DeletePurchaseEvent(purchase.id!));
    }
  }

  Future<void> _cancelPurchase(Purchase purchase) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'إلغاء المشترى',
      message: 'هل أنت متأكد من إلغاء هذا المشترى؟',
      confirmText: 'إلغاء المشترى',
      cancelText: 'رجوع',
      isDangerous: true,
    );

    if (confirmed == true && purchase.id != null) {
      context.read<PurchasesBloc>().add(CancelPurchaseEvent(purchase.id!));
    }
  }

  List<Purchase> _filterPurchases(List<Purchase> purchases) {
    var filtered = purchases;

    if (_filterType != 'الكل' && _filterType != 'اليوم') {
      final now = DateTime.now();
      
      filtered = filtered.where((purchase) {
        final purchaseDate = DateTime.parse(purchase.date);
        
        switch (_filterType) {
          case 'الأسبوع':
            return now.difference(purchaseDate).inDays <= 7;
          case 'الشهر':
            return purchaseDate.year == now.year && 
                   purchaseDate.month == now.month;
          case 'مدفوع':
            return purchase.paymentStatus == 'مدفوع';
          case 'غير مدفوع':
            return purchase.paymentStatus == 'غير مدفوع' ||
                   purchase.paymentStatus == 'مدفوع جزئياً';
          default:
            return true;
        }
      }).toList();
    }

    filtered.sort((a, b) {
      final dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) return dateComparison;
      return b.time.compareTo(a.time);
    });

    return filtered;
  }

  double _calculateTotalAmount(List<Purchase> purchases) {
    return purchases.fold(0, (sum, purchase) => sum + purchase.totalAmount);
  }

  double _calculateTotalPaid(List<Purchase> purchases) {
    return purchases.fold(0, (sum, purchase) => sum + purchase.paidAmount);
  }

  double _calculateTotalRemaining(List<Purchase> purchases) {
    return purchases.fold(0, (sum, purchase) => sum + purchase.remainingAmount);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('المشتريات', style: AppTextStyles.headlineMedium),
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                    _filterType = 'اليوم';
                  });
                  _loadPurchases();
                }
              },
              tooltip: 'اختر تاريخ',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPurchases,
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              color: AppColors.surface,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                ),
                itemCount: _filterTypes.length,
                itemBuilder: (context, index) {
                  final type = _filterTypes[index];
                  final isSelected = _filterType == type;
                  
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.spaceS,
                    ),
                    child: FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _filterType = type);
                        _loadPurchases();
                      },
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: BlocConsumer<PurchasesBloc, PurchasesState>(
                listener: (context, state) {
                  if (state is PurchasesError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  } else if (state is PurchaseOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is PurchasesLoading) {
                    return const LoadingWidget(message: 'جاري تحميل المشتريات...');
                  }

                  if (state is PurchasesError) {
                    return app_error.ErrorWidget(
                      message: state.message,
                      onRetry: _loadPurchases,
                    );
                  }

                  if (state is PurchasesLoaded) {
                    final filteredPurchases = _filterPurchases(state.purchases);

                    if (filteredPurchases.isEmpty) {
                      return EmptyWidget(
                        title: 'لا توجد مشتريات',
                        message: 'لم يتم تسجيل أي عملية شراء بعد',
                        icon: Icons.shopping_cart_outlined,
                        actionLabel: 'إضافة مشترى',
                        onAction: _showAddPurchaseScreen,
                      );
                    }

                    final totalAmount = _calculateTotalAmount(filteredPurchases);
                    final totalPaid = _calculateTotalPaid(filteredPurchases);
                    final totalRemaining = _calculateTotalRemaining(filteredPurchases);

                    return Column(
                      children: [
                        PurchaseSummary(
                          totalAmount: totalAmount,
                          paidAmount: totalPaid,
                          remainingAmount: totalRemaining,
                          purchaseCount: filteredPurchases.length,
                        ),
                        
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async => _loadPurchases(),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(AppDimensions.paddingM),
                              itemCount: filteredPurchases.length,
                              separatorBuilder: (context, index) => 
                                  const SizedBox(height: AppDimensions.spaceM),
                              itemBuilder: (context, index) {
                                final purchase = filteredPurchases[index];
                                return PurchaseItemCard(
                                  purchase: purchase,
                                  onTap: () => _showPurchaseDetails(purchase),
                                  onDelete: () => _deletePurchase(purchase),
                                  onCancel: purchase.status == 'نشط'
                                      ? () => _cancelPurchase(purchase)
                                      : null,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const EmptyWidget(
                    title: 'لا يوجد بيانات',
                    message: 'لم يتم تحميل بيانات المشتريات',
                    icon: Icons.shopping_cart_outlined,
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddPurchaseScreen,
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('إضافة مشترى'),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }
}
