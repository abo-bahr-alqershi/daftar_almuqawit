import 'package:flutter/material.dart';

class CustomerRankingItem {
  const CustomerRankingItem({
    required this.name,
    this.phone,
    required this.totalPurchases,
    required this.transactionCount,
    required this.balance,
    required this.rank,
    this.isBlocked = false,
  });

  final String name;
  final String? phone;
  final double totalPurchases;
  final int transactionCount;
  final double balance;
  final int rank;
  final bool isBlocked;
}

enum RankingType {
  topBuyers,
  topDebtors,
  mostFrequent,
}

class CustomerRankingWidget extends StatelessWidget {
  const CustomerRankingWidget({
    super.key,
    required this.customers,
    this.title = 'ترتيب العملاء',
    this.maxItems = 5,
    this.rankingType = RankingType.topBuyers,
  });

  final List<CustomerRankingItem> customers;
  final String title;
  final int maxItems;
  final RankingType rankingType;

  @override
  Widget build(BuildContext context) {
    final displayCustomers = customers.take(maxItems).toList();

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
                  gradient: LinearGradient(
                    colors: [
                      _getRankingTypeColor().withOpacity(0.15),
                      _getRankingTypeColor().withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getRankingTypeIcon(),
                  color: _getRankingTypeColor(),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getRankingTypeLabel(),
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRankingTypeColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'أفضل $maxItems',
                  style: TextStyle(
                    color: _getRankingTypeColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (displayCustomers.isEmpty)
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
                        Icons.people_outline_rounded,
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
              itemCount: displayCustomers.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  height: 1,
                  color: const Color(0xFFE5E7EB),
                ),
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

  IconData _getRankingTypeIcon() {
    switch (rankingType) {
      case RankingType.topBuyers:
        return Icons.shopping_bag_rounded;
      case RankingType.topDebtors:
        return Icons.account_balance_wallet_rounded;
      case RankingType.mostFrequent:
        return Icons.repeat_rounded;
    }
  }

  Color _getRankingTypeColor() {
    switch (rankingType) {
      case RankingType.topBuyers:
        return const Color(0xFF10B981);
      case RankingType.topDebtors:
        return const Color(0xFFEF4444);
      case RankingType.mostFrequent:
        return const Color(0xFF3B82F6);
    }
  }
}

class _CustomerRankingTile extends StatelessWidget {
  const _CustomerRankingTile({
    required this.customer,
    required this.rankingType,
  });

  final CustomerRankingItem customer;
  final RankingType rankingType;

  @override
  Widget build(BuildContext context) {
    Color getRankColor() {
      switch (customer.rank) {
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

    return Opacity(
      opacity: customer.isBlocked ? 0.5 : 1.0,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: customer.rank <= 3
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        getRankColor(),
                        getRankColor().withOpacity(0.7),
                      ],
                    )
                  : null,
              color: customer.rank > 3 ? getRankColor().withOpacity(0.1) : null,
              shape: BoxShape.circle,
              boxShadow: customer.rank <= 3
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
              child: customer.rank <= 3
                  ? Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 22,
                    )
                  : Text(
                      '${customer.rank}',
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (customer.isBlocked)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'محظور',
                          style: TextStyle(
                            color: const Color(0xFFEF4444),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (customer.phone != null) ...[
                      Icon(
                        Icons.phone_rounded,
                        size: 13,
                        color: const Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          customer.phone!,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(
                      Icons.receipt_long_rounded,
                      size: 13,
                      color: const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '${customer.transactionCount} معاملة',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                _getMainValue(),
                style: TextStyle(
                  color: _getMainValueColor(),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _getMainValueLabel(),
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
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
        return '${customer.totalPurchases.toStringAsFixed(0)} ريال';
      case RankingType.topDebtors:
        return '${customer.balance.toStringAsFixed(0)} ريال';
      case RankingType.mostFrequent:
        return '${customer.transactionCount}';
    }
  }

  String _getMainValueLabel() {
    switch (rankingType) {
      case RankingType.topBuyers:
        return 'مشتريات';
      case RankingType.topDebtors:
        return 'ديون';
      case RankingType.mostFrequent:
        return 'معاملة';
    }
  }

  Color _getMainValueColor() {
    switch (rankingType) {
      case RankingType.topBuyers:
        return const Color(0xFF10B981);
      case RankingType.topDebtors:
        return const Color(0xFFEF4444);
      case RankingType.mostFrequent:
        return const Color(0xFF3B82F6);
    }
  }
}
