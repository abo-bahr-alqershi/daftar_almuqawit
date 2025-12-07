import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ExportType {
  pdf,
  excel,
  image,
  print,
  share,
}

class ExportOptions extends StatelessWidget {
  const ExportOptions({
    super.key,
    required this.onExport,
    this.iconsOnly = false,
  });

  final Function(ExportType type) onExport;
  final bool iconsOnly;

  @override
  Widget build(BuildContext context) {
    if (iconsOnly) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ExportIconButton(
            icon: Icons.print_rounded,
            tooltip: 'طباعة',
            color: const Color(0xFF6B7280),
            onTap: () => onExport(ExportType.print),
          ),
          const SizedBox(width: 8),
          _ExportIconButton(
            icon: Icons.ios_share_rounded,
            tooltip: 'مشاركة',
            color: const Color(0xFF6366F1),
            onTap: () => onExport(ExportType.share),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'خيارات التصدير',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ExportCard(
              icon: Icons.picture_as_pdf_rounded,
              label: 'PDF',
              color: const Color(0xFFEF4444),
              onTap: () => onExport(ExportType.pdf),
            ),
            _ExportCard(
              icon: Icons.table_chart_rounded,
              label: 'Excel',
              color: const Color(0xFF10B981),
              onTap: () => onExport(ExportType.excel),
            ),
            _ExportCard(
              icon: Icons.image_rounded,
              label: 'صورة',
              color: const Color(0xFF3B82F6),
              onTap: () => onExport(ExportType.image),
            ),
            _ExportCard(
              icon: Icons.print_rounded,
              label: 'طباعة',
              color: const Color(0xFF6B7280),
              onTap: () => onExport(ExportType.print),
            ),
            _ExportCard(
              icon: Icons.ios_share_rounded,
              label: 'مشاركة',
              color: const Color(0xFF6366F1),
              onTap: () => onExport(ExportType.share),
            ),
          ],
        ),
      ],
    );
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 100,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.15),
                      color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportIconButton extends StatelessWidget {
  const _ExportIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
