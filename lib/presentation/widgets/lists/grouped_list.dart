import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// قائمة مجمعة حسب فئات
class GroupedList<T> extends StatelessWidget {
  final Map<String, List<T>> groupedData;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget Function(BuildContext context, String groupKey)? groupHeaderBuilder;

  const GroupedList({
    super.key,
    required this.groupedData,
    required this.itemBuilder,
    this.groupHeaderBuilder,
  });

  Widget _defaultGroupHeader(String groupKey) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.backgroundSecondary,
      child: Text(groupKey, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (groupedData.isEmpty) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return ListView.builder(
      itemCount: groupedData.length,
      itemBuilder: (context, groupIndex) {
        final groupKey = groupedData.keys.elementAt(groupIndex);
        final items = groupedData[groupKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            groupHeaderBuilder?.call(context, groupKey) ?? _defaultGroupHeader(groupKey),
            ...items.map((item) => itemBuilder(context, item)),
          ],
        );
      },
    );
  }
}
