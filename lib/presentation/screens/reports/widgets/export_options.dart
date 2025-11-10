/// خيارات التصدير
/// ويدجت لعرض خيارات تصدير التقرير

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// نوع التصدير
enum ExportType {
  /// PDF
  pdf,
  
  /// Excel
  excel,
  
  /// صورة
  image,
  
  /// طباعة
  print,
  
  /// مشاركة
  share,
}

/// خيارات التصدير
class ExportOptions extends StatelessWidget {
  /// دالة عند اختيار نوع التصدير
  final Function(ExportType type) onExport;
  
  /// هل يعرض كأيقونات فقط
  final bool iconsOnly;

  const ExportOptions({
    super.key,
    required this.onExport,
    this.iconsOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (iconsOnly) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ExportIconButton(
            icon: Icons.print,
            tooltip: 'طباعة',
            onTap: () => onExport(ExportType.print),
          ),
          
          const SizedBox(width: 8),
          
          _ExportIconButton(
            icon: Icons.share,
            tooltip: 'مشاركة',
            onTap: () => onExport(ExportType.share),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'خيارات التصدير',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ExportCard(
              icon: Icons.picture_as_pdf,
              label: 'PDF',
              color: AppColors.danger,
              onTap: () => onExport(ExportType.pdf),
            ),
            
            _ExportCard(
              icon: Icons.table_chart,
              label: 'Excel',
              color: AppColors.success,
              onTap: () => onExport(ExportType.excel),
            ),
            
            _ExportCard(
              icon: Icons.image,
              label: 'صورة',
              color: AppColors.info,
              onTap: () => onExport(ExportType.image),
            ),
            
            _ExportCard(
              icon: Icons.print,
              label: 'طباعة',
              color: AppColors.textSecondary,
              onTap: () => onExport(ExportType.print),
            ),
            
            _ExportCard(
              icon: Icons.share,
              label: 'مشاركة',
              color: AppColors.primary,
              onTap: () => onExport(ExportType.share),
            ),
          ],
        ),
      ],
    );
  }
}

/// بطاقة التصدير
class _ExportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// زر أيقونة التصدير
class _ExportIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ExportIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: AppColors.textPrimary,
      tooltip: tooltip,
      onPressed: onTap,
    );
  }
}
