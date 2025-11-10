/// ويدجت ترتيب العملاء
/// يعرض قائمة بالعملاء الأكثر شراءً أو الأكثر ديوناً

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// عنصر ترتيب العميل
class CustomerRankingItem {
  /// اسم العميل
  final String name;
  
  /// رقم الهاتف
  final String? phone;
  
  /// إجمالي المشتريات
  final double totalPurchases;
  
  /// عدد المعاملات
  final int transactionCount;
  
  /// الرصيد/الديون
  final double balance;
  
  /// الترتيب
  final int rank;
  
  /// هل العميل محظور
  final bool isBlocked;

  const CustomerRankingItem({
    required this.name,
    this.phone,
    required this.totalPurchases,
    required this.transactionCount,
    required this.balance,
    required this.rank,
    this.isBlocked = false,
  });
}

/// ويدجت ترتيب العملاء
class CustomerRankingWidget extends StatelessWidget {
  /// قائمة العملاء
  final List<CustomerRankingItem> customers;
  
  /// عنوان الويدجت
  final String title;
  
  /// عدد العناصر المعروضة
  final int maxItems;
  
  /// نوع الترتيب
  final RankingType rankingType;

  const CustomerRankingWidget({
    super.key,
    required this.customers,
    this.title = 'ترتيب العملاء',
    this.maxItems = 5,
    this.rankingType = RankingType.topBuyers,
  });

  @override
  Widget build(BuildContext context) {
    final displayCustomers = customers.take(maxItems).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    _getRankingTypeLabel(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getRankingTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'أفضل $maxItems',
                  style: AppTextStyles.caption.copyWith(
                    color: _getRankingTypeColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // القائمة
          if (displayCustomers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'لا توجد بيانات',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayCustomers.length,
              separatorBuilder: (context, index) => const Divider(
                height: 20,
                color: AppColors.border,
              ),
              itemBuilder: (context, index) {
                final customer = displayCustomers[index];
                return _CustomerRankingTile(
                  customer: customer,
                  rankingType: rankingType,
                );
              },
            ),
        ],
      ),
    );
  }

  String _getRankingTypeLabel() {
    switch (rankingType) {
      case RankingType.topBuyers:
        return 'حسب المشتريات';
      case RankingType.topDebtors:
        return 'حسب الديون';
      case RankingType.mostFrequent:
        return 'حسب عدد المعاملات';
    }
  }

  Color _getRankingTypeColor() {
    switch (rankingType) {
      case RankingType.topBuyers:
        return AppColors.success;
      case RankingType.topDebtors:
        return AppColors.error;
      case RankingType.mostFrequent:
        return AppColors.info;
    }
  }
}

/// نوع الترتيب
enum RankingType {
  /// أكثر شراءً
  topBuyers,
  
  /// أكثر ديوناً
  topDebtors,
  
  /// الأكثر تكراراً
  mostFrequent,
}

/// بلاطة ترتيب العميل
class _CustomerRankingTile extends StatelessWidget {
  final CustomerRankingItem customer;
  final RankingType rankingType;

  const _CustomerRankingTile({
    required this.customer,
    required this.rankingType,
  });

  @override
  Widget build(BuildContext context) {
    // لون الميدالية حسب الترتيب
    Color getRankColor() {
      switch (customer.rank) {
        case 1:
          return const Color(0xFFFFD700); // ذهبي
        case 2:
          return const Color(0xFFC0C0C0); // فضي
        case 3:
          return const Color(0xFFCD7F32); // برونزي
        default:
          return AppColors.primary;
      }
    }

    return Opacity(
      opacity: customer.isBlocked ? 0.5 : 1.0,
      child: Row(
        children: [
          // الترتيب
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: getRankColor().withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: customer.rank <= 3
                  ? Icon(
                      Icons.emoji_events,
                      color: getRankColor(),
                      size: 20,
                    )
                  : Text(
                      '${customer.rank}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: getRankColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // المعلومات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    if (customer.isBlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'محظور',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.error,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    if (customer.phone != null) ...[
                      Icon(
                        Icons.phone_outlined,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        customer.phone!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    
                    Icon(
                      Icons.receipt_outlined,
                      size: 12,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${customer.transactionCount} معاملة',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 12),
          
          // القيمة الرئيسية
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getMainValue(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: _getMainValueColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                _getMainValueLabel(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMainValue() {
    switch (rankingType) {
      case RankingType.topBuyers:
        return '${customer.totalPurchases.toStringAsFixed(0)} ر.ي';
      case RankingType.topDebtors:
        return '${customer.balance.toStringAsFixed(0)} ر.ي';
      case RankingType.mostFrequent:
        return '${customer.transactionCount}';
    }
  }

  String _getMainValueLabel() {
    switch (rankingType) {
      case RankingType.topBuyers:
        return 'إجمالي المشتريات';
      case RankingType.topDebtors:
        return 'إجمالي الديون';
      case RankingType.mostFrequent:
        return 'معاملة';
    }
  }

  Color _getMainValueColor() {
    switch (rankingType) {
      case RankingType.topBuyers:
        return AppColors.success;
      case RankingType.topDebtors:
        return AppColors.error;
      case RankingType.mostFrequent:
        return AppColors.info;
    }
  }
}
