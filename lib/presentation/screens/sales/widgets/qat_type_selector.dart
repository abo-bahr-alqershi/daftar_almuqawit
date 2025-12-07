import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// محدد نوع القات - تصميم راقي واحترافي
class QatTypeSelector extends StatefulWidget {
  final String? selectedQatTypeId;
  final ValueChanged<String?> onChanged;
  final List<QatTypeOption> qatTypes;
  final bool enabled;
  final String? errorText;

  const QatTypeSelector({
    super.key,
    this.selectedQatTypeId,
    required this.onChanged,
    required this.qatTypes,
    this.enabled = true,
    this.errorText,
  });

  @override
  State<QatTypeSelector> createState() => _QatTypeSelectorState();
}

class _QatTypeSelectorState extends State<QatTypeSelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.grass_rounded,
                color: Color(0xFF10B981),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'نوع القات',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${widget.qatTypes.length} نوع',
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        // Error Message
        if (widget.errorText != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFDC2626).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Grid of Qat Types
        if (widget.qatTypes.isEmpty)
          _buildEmptyState()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.15,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: widget.qatTypes.length,
            itemBuilder: (context, index) {
              final qatType = widget.qatTypes[index];
              final isSelected = widget.selectedQatTypeId == qatType.id;
              return _buildQatTypeCard(qatType, isSelected);
            },
          ),
      ],
    );
  }

  Widget _buildQatTypeCard(QatTypeOption qatType, bool isSelected) {
    return GestureDetector(
      onTap: widget.enabled
          ? () {
              HapticFeedback.selectionClick();
              widget.onChanged(qatType.id);
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF10B981).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF10B981).withOpacity(0.3)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.grass_rounded,
                    color: isSelected ? Colors.white : const Color(0xFF10B981),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),

                // Name
                Text(
                  qatType.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : const Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Description
                if (qatType.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    qatType.description!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9CA3AF),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Price
                if (qatType.price != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${qatType.price!.toStringAsFixed(0)} ر.ي',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6366F1),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Selection Indicator
            if (isSelected)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.grass_rounded,
              size: 32,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد أنواع متاحة',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'أضف أنواع القات من الإعدادات',
            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

/// خيار نوع القات
class QatTypeOption {
  final String id;
  final String name;
  final double? price;
  final String? description;

  const QatTypeOption({
    required this.id,
    required this.name,
    this.price,
    this.description,
  });
}
