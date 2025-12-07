import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/qat_type.dart';

/// محدد نوع القات (Grid View) - تصميم احترافي راقي
class QatTypeGridSelector extends StatelessWidget {
  final List<QatType> qatTypes;
  final int? selectedQatTypeId;
  final Function(QatType) onQatTypeSelected;

  const QatTypeGridSelector({
    super.key,
    required this.qatTypes,
    this.selectedQatTypeId,
    required this.onQatTypeSelected,
  });

  Color _getQualityColor(String? quality) {
    switch (quality?.toLowerCase()) {
      case 'ممتاز':
        return const Color(0xFF16A34A);
      case 'جيد جداً':
        return const Color(0xFF0EA5E9);
      case 'جيد':
        return const Color(0xFF6366F1);
      case 'متوسط':
      case 'عادي':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (qatTypes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  size: 48,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'لا توجد أنواع قات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'أضف نوع قات جديد لبدء الاستخدام',
                style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: qatTypes.length,
      itemBuilder: (context, index) => _buildGridItem(qatTypes[index]),
    );
  }

  Widget _buildGridItem(QatType qatType) {
    final isSelected = qatType.id == selectedQatTypeId;
    final qualityColor = _getQualityColor(qatType.qualityGrade);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onQatTypeSelected(qatType);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? qualityColor : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: qualityColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: qualityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        qatType.icon ?? '🌿',
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(
                    qatType.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isSelected
                          ? qualityColor
                          : const Color(0xFF1A1A2E),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Quality badge
                  if (qatType.qualityGrade != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: qualityColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        qatType.qualityGrade!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // Price
                  if (qatType.defaultSellPrice != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${qatType.defaultSellPrice!.toStringAsFixed(0)} ر.ي',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: qualityColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
