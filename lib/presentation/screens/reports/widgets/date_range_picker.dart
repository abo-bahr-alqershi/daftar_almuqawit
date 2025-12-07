import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DateRangePicker extends StatelessWidget {
  const DateRangePicker({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeChanged,
    this.title = 'اختر الفترة الزمنية',
    this.showIcon = true,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime startDate, DateTime endDate) onDateRangeChanged;
  final String title;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _selectDateRange(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
          child: Row(
            children: [
              if (showIcon)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.date_range_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              if (showIcon) const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getDateRangeText(dateFormat),
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDateRangeText(DateFormat dateFormat) {
    if (startDate == null || endDate == null) {
      return 'اختر تاريخ البداية والنهاية';
    }

    final start = dateFormat.format(startDate!);
    final end = dateFormat.format(endDate!);

    return '$start - $end';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeChanged(picked.start, picked.end);
    }
  }
}

class QuickDatePicker extends StatelessWidget {
  const QuickDatePicker({
    super.key,
    required this.onDateRangeSelected,
  });

  final Function(DateTime startDate, DateTime endDate) onDateRangeSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _QuickDateButton(
          label: 'اليوم',
          icon: Icons.today_rounded,
          onTap: () => _selectToday(),
        ),
        _QuickDateButton(
          label: 'أمس',
          icon: Icons.history_rounded,
          onTap: () => _selectYesterday(),
        ),
        _QuickDateButton(
          label: 'هذا الأسبوع',
          icon: Icons.view_week_rounded,
          onTap: () => _selectThisWeek(),
        ),
        _QuickDateButton(
          label: 'هذا الشهر',
          icon: Icons.calendar_month_rounded,
          onTap: () => _selectThisMonth(),
        ),
        _QuickDateButton(
          label: 'الشهر الماضي',
          icon: Icons.calendar_today_rounded,
          onTap: () => _selectLastMonth(),
        ),
      ],
    );
  }

  void _selectToday() {
    final today = DateTime.now();
    onDateRangeSelected(
      DateTime(today.year, today.month, today.day),
      DateTime(today.year, today.month, today.day, 23, 59, 59),
    );
  }

  void _selectYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    onDateRangeSelected(
      DateTime(yesterday.year, yesterday.month, yesterday.day),
      DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59),
    );
  }

  void _selectThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    onDateRangeSelected(
      DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  void _selectThisMonth() {
    final now = DateTime.now();
    onDateRangeSelected(
      DateTime(now.year, now.month, 1),
      DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  void _selectLastMonth() {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
    onDateRangeSelected(
      lastMonth,
      DateTime(
        lastDayOfLastMonth.year,
        lastDayOfLastMonth.month,
        lastDayOfLastMonth.day,
        23,
        59,
        59,
      ),
    );
  }
}

class _QuickDateButton extends StatelessWidget {
  const _QuickDateButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6366F1).withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: const Color(0xFF6366F1),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
