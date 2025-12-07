import 'package:flutter/material.dart';

class BestSellerItem {
  const BestSellerItem({
    required this.name,
    required this.quantity,
    required this.totalSales,
    required this.percentage,
    required this.rank,
  });

  final String name;
  final double quantity;
  final double totalSales;
  final double percentage;
  final int rank;
}

class BestSellersWidget extends StatelessWidget {
  const BestSellersWidget({
    super.key,
    required this.items,
    this.title = 'الأكثر مبيعاً',
    this.maxItems = 5,
  });

  final List<BestSellerItem> items;
  final String title;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final displayItems = items.take(maxItems).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.whatshot_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'أفضل $maxItems',
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (displayItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد بيانات',
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayItems.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  height: 1,
                  color: const Color(0xFFE5E7EB),
                ),
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

class _BestSellerTile extends StatelessWidget {
  const _BestSellerTile({required this.item});

  final BestSellerItem item;

  @override
  Widget build(BuildContext context) {
    Color getRankColor() {
      switch (item.rank) {
        case 1:
          return const Color(0xFFFFD700);
        case 2:
          return const Color(0xFFC0C0C0);
        case 3:
          return const Color(0xFFCD7F32);
        default:
          return const Color(0xFF6366F1);
      }
    }

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: item.rank <= 3
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      getRankColor(),
                      getRankColor().withOpacity(0.7),
                    ],
                  )
                : null,
            color: item.rank > 3 ? getRankColor().withOpacity(0.1) : null,
            shape: BoxShape.circle,
            boxShadow: item.rank <= 3
                ? [
                    BoxShadow(
                      color: getRankColor().withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: item.rank <= 3
                ? Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 22,
                  )
                : Text(
                    '${item.rank}',
                    style: TextStyle(
                      color: getRankColor(),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_rounded,
                    size: 13,
                    color: const Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${item.quantity.toStringAsFixed(0)} قطعة',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.totalSales.toStringAsFixed(0)} ريال',
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    size: 10,
                    color: const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '%${item.percentage.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
