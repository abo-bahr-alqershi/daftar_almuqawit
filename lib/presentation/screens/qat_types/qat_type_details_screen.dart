import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/qat_types/qat_types_bloc.dart';
import '../../blocs/qat_types/qat_types_event.dart';
import '../../blocs/qat_types/qat_types_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as custom_error;

/// شاشة تفاصيل نوع القات
/// 
/// تعرض تفاصيل كاملة عن نوع قات معين
class QatTypeDetailsScreen extends StatefulWidget {
  final int qatTypeId;

  const QatTypeDetailsScreen({
    super.key,
    required this.qatTypeId,
  });

  @override
  State<QatTypeDetailsScreen> createState() => _QatTypeDetailsScreenState();
}

class _QatTypeDetailsScreenState extends State<QatTypeDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadQatTypeDetails();
  }

  void _loadQatTypeDetails() {
    context.read<QatTypesBloc>().add(LoadQatTypeById(widget.qatTypeId));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل نوع القات'),
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit screen
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Show delete confirmation
              },
            ),
          ],
        ),
        body: BlocBuilder<QatTypesBloc, QatTypesState>(
          builder: (context, state) {
            if (state is QatTypesLoading) {
              return const LoadingWidget(message: 'جاري تحميل التفاصيل...');
            }

            if (state is QatTypesError) {
              return custom_error.ErrorWidget(
                message: state.message,
                onRetry: _loadQatTypeDetails,
              );
            }

            if (state is QatTypeDetailsLoaded) {
              final qatType = state.qatType;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
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
                    ),
                    child: Column(
                      children: [
                        Text(
                          qatType.icon ?? '🌿',
                          style: const TextStyle(fontSize: 72),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          qatType.name,
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.textOnDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (qatType.qualityGrade != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textOnDark.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              qatType.qualityGrade!,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textOnDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(
                    'معلومات الأسعار',
                    [
                      if (qatType.defaultBuyPrice != null)
                        _buildInfoRow(
                          'سعر الشراء الافتراضي',
                          '${qatType.defaultBuyPrice!.toStringAsFixed(0)} ريال',
                          Icons.shopping_cart,
                          valueColor: AppColors.info,
                        ),
                      if (qatType.defaultSellPrice != null)
                        _buildInfoRow(
                          'سعر البيع الافتراضي',
                          '${qatType.defaultSellPrice!.toStringAsFixed(0)} ريال',
                          Icons.sell,
                          valueColor: AppColors.success,
                        ),
                      if (qatType.defaultBuyPrice != null &&
                          qatType.defaultSellPrice != null)
                        _buildInfoRow(
                          'هامش الربح المتوقع',
                          '${(qatType.defaultSellPrice! - qatType.defaultBuyPrice!).toStringAsFixed(0)} ريال',
                          Icons.trending_up,
                          valueColor: AppColors.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'معلومات إضافية',
                    [
                      _buildInfoRow(
                        'درجة الجودة',
                        qatType.qualityGrade ?? 'غير محدد',
                        Icons.grade,
                      ),
                      _buildInfoRow(
                        'الرمز',
                        qatType.icon ?? '🌿',
                        Icons.emoji_emotions,
                      ),
                    ],
                  ),
                ],
              );
            }

            return const Center(child: Text('لا توجد بيانات'));
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
