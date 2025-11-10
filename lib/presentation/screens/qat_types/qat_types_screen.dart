import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;
import './widgets/qat_type_card.dart';
import './widgets/qat_type_filters.dart';

/// شاشة أنواع القات الرئيسية
/// 
/// تعرض قائمة بجميع أنواع القات مع إمكانية الفلترة والبحث
class QatTypesScreen extends StatefulWidget {
  const QatTypesScreen({super.key});

  @override
  State<QatTypesScreen> createState() => _QatTypesScreenState();
}

class _QatTypesScreenState extends State<QatTypesScreen> {
  String _selectedFilter = 'الكل';
  String _selectedSortBy = 'الاسم';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadQatTypes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadQatTypes() {
    if (_selectedFilter == 'الكل') {
      context.read<QatTypesBloc>().add(LoadQatTypes());
    } else {
      context.read<QatTypesBloc>().add(FilterQatTypesByQuality(_selectedFilter));
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _loadQatTypes();
    } else {
      context.read<QatTypesBloc>().add(SearchQatTypes(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('أنواع القات', style: AppTextStyles.title),
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilters,
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textOnDark,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن نوع القات...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnDark.withOpacity(0.7),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textOnDark,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppColors.textOnDark,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.textOnDark.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _performSearch,
              ),
            ),
            Expanded(
              child: BlocBuilder<QatTypesBloc, QatTypesState>(
                builder: (context, state) {
                  if (state is QatTypesLoading) {
                    return const LoadingWidget(message: 'جاري تحميل أنواع القات...');
                  }

                  if (state is QatTypesError) {
                    return custom_error.ErrorWidget(
                      message: state.message,
                      onRetry: _loadQatTypes,
                    );
                  }

                  if (state is QatTypesLoaded || state is QatTypesSearchResults) {
                    final qatTypes = state is QatTypesLoaded
                        ? state.qatTypes
                        : (state as QatTypesSearchResults).results;

                    if (qatTypes.isEmpty) {
                      return EmptyWidget(
                        title: _searchController.text.isEmpty
                            ? 'لا توجد أنواع قات'
                            : 'لا توجد نتائج',
                        message: _searchController.text.isEmpty
                            ? 'لم يتم إضافة أي أنواع قات بعد'
                            : 'لم يتم العثور على نتائج للبحث',
                        icon: Icons.grid_view_outlined,
                      );
                    }

                    return Column(
                      children: [
                        _buildStatisticsCard(qatTypes),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              _loadQatTypes();
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: qatTypes.length,
                              itemBuilder: (context, index) {
                                final qatType = qatTypes[index];
                                return QatTypeCard(
                                  qatType: qatType,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/qat-type-details',
                                      arguments: qatType.id,
                                    );
                                  },
                                  onEdit: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/edit-qat-type',
                                      arguments: qatType,
                                    );
                                  },
                                  onDelete: () {
                                    _showDeleteConfirmation(qatType);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(child: Text('حدث خطأ في تحميل البيانات'));
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.pushNamed(context, '/add-qat-type');
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add),
          label: const Text('إضافة نوع'),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(List qatTypes) {
    final totalTypes = qatTypes.length;
    final withPrices = qatTypes.where((qt) {
      return qt.defaultBuyPrice != null && qt.defaultSellPrice != null;
    }).length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'إجمالي الأنواع',
            '$totalTypes',
            Icons.grid_view,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.textOnDark.withOpacity(0.3),
          ),
          _buildStatItem(
            'بأسعار محددة',
            '$withPrices',
            Icons.price_check,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textOnDark, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.textOnDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textOnDark.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  void _showFilters() {
    showQatTypeFilters(
      context: context,
      selectedFilter: _selectedFilter,
      selectedSortBy: _selectedSortBy,
      onFilterChanged: (filter) {
        setState(() {
          _selectedFilter = filter;
        });
        _loadQatTypes();
      },
      onSortChanged: (sortBy) {
        setState(() {
          _selectedSortBy = sortBy;
        });
      },
    );
  }

  void _showDeleteConfirmation(dynamic qatType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف نوع القات'),
        content: Text('هل أنت متأكد من حذف "${qatType.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<QatTypesBloc>().add(DeleteQatTypeEvent(qatType.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف نوع القات'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
