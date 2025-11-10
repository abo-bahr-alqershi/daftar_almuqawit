/// ويدجت الأكثر مبيعاً
/// يعرض قائمة بالمنتجات أو الأصناف الأكثر مبيعاً

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// عنصر من الأكثر مبيعاً
class BestSellerItem {
  /// اسم المنتج/الصنف
  final String name;
  
  /// الكمية المباعة
  final double quantity;
  
  /// إجمالي المبيعات
  final double totalSales;
  
  /// نسبة من إجمالي المبيعات
  final double percentage;
  
  /// الترتيب
  final int rank;

  const BestSellerItem({
    required this.name,
    required this.quantity,
    required this.totalSales,
    required this.percentage,
    required this.rank,
  });
}

/// ويدجت الأكثر مبيعاً
class BestSellersWidget extends StatelessWidget {
  /// قائمة الأكثر مبيعاً
  final List<BestSellerItem> items;
  
  /// عنوان الويدجت
  final String title;
  
  /// عدد العناصر المعروضة
  final int maxItems;

  const BestSellersWidget({
    super.key,
    required this.items,
    this.title = 'الأكثر مبيعاً',
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = items.take(maxItems).toList();
    
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
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'أفضل $maxItems',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // القائمة
          if (displayItems.isEmpty)
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
              itemCount: displayItems.length,
              separatorBuilder: (context, index) => const Divider(
                height: 20,
                color: AppColors.border,
              ),
              itemBuilder: (context, index) {
                final item = displayItems[index];
                return _BestSellerTile(item: item);
              },
            ),
        ],
      ),
    );
  }
}

/// بلاطة عنصر من الأكثر مبيعاً
class _BestSellerTile extends StatelessWidget {
  final BestSellerItem item;

  const _BestSellerTile({required this.item});

  @override
  Widget build(BuildContext context) {
    // لون الميدالية حسب الترتيب
    Color getRankColor() {
      switch (item.rank) {
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

    return Row(
      children: [
        // الترتيب
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: getRankColor().withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${item.rank}',
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
              Text(
                item.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 14,
                    color: AppColors.textHint,
                  ),
                  
                  const SizedBox(width: 4),
                  
                  Text(
                    '${item.quantity.toStringAsFixed(0)} قطعة',
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
        
        // المبيعات والنسبة
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.totalSales.toStringAsFixed(0)} ر.ي',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '%${item.percentage.toStringAsFixed(1)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
