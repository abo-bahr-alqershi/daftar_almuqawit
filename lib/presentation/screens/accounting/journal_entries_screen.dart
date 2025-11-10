import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../domain/entities/journal_entry.dart';
import '../../blocs/accounting/accounting_bloc.dart';
import '../../blocs/accounting/accounting_event.dart';
import '../../blocs/accounting/accounting_state.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart' as app_error;
import '../../widgets/common/empty_widget.dart';
import 'widgets/journal_entry_card.dart';
import 'add_journal_entry_screen.dart';

/// شاشة قيود اليومية
class JournalEntriesScreen extends StatefulWidget {
  const JournalEntriesScreen({super.key});

  @override
  State<JournalEntriesScreen> createState() => _JournalEntriesScreenState();
}

class _JournalEntriesScreenState extends State<JournalEntriesScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _filterType = 'الكل';

  final List<String> _filterTypes = ['الكل', 'مبيعات', 'مشتريات', 'مصروفات', 'أخرى'];

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  void _loadJournalEntries() {
    context.read<AccountingBloc>().add(LoadTransactions());
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadJournalEntries();
    }
  }

  void _showAddJournalEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddJournalEntryScreen(),
      ),
    ).then((_) => _loadJournalEntries());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('قيود اليومية', style: AppTextStyles.headlineMedium),
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _selectDateRange,
              tooltip: 'اختر فترة',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadJournalEntries,
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              color: AppColors.surface,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                        vertical: AppDimensions.paddingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_startDate.toIso8601String().split('T')[0]} - ${_endDate.toIso8601String().split('T')[0]}',
                              style: AppTextStyles.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              height: 50,
              color: AppColors.surface,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                ),
                itemCount: _filterTypes.length,
                itemBuilder: (context, index) {
                  final type = _filterTypes[index];
                  final isSelected = _filterType == type;
                  
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.spaceS,
                    ),
                    child: FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _filterType = type);
                      },
                      backgroundColor: AppColors.surface,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: BlocConsumer<AccountingBloc, AccountingState>(
                listener: (context, state) {
                  if (state is AccountingError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.danger,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is AccountingLoading) {
                    return const LoadingWidget(message: 'جاري تحميل القيود...');
                  }

                  if (state is AccountingError) {
                    return app_error.ErrorWidget(
                      message: state.message,
                      onRetry: _loadJournalEntries,
                    );
                  }

                  if (state is AccountingLoaded) {
                    // TODO: Filter transactions based on filterType
                    final entries = <JournalEntry>[]; // state.transactions

                    if (entries.isEmpty) {
                      return EmptyWidget(
                        title: 'لا توجد قيود يومية',
                        message: 'لم يتم تسجيل أي قيد محاسبي بعد',
                        icon: Icons.description_outlined,
                        actionLabel: 'إضافة قيد جديد',
                        onAction: _showAddJournalEntry,
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _loadJournalEntries(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        itemCount: entries.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppDimensions.spaceM),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return JournalEntryCard(
                            entry: entry,
                            onTap: () {
                              // TODO: Navigate to entry details
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const EmptyWidget(
                    title: 'لا توجد بيانات',
                    message: 'لم يتم تحميل بيانات القيود اليومية',
                    icon: Icons.description_outlined,
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddJournalEntry,
          icon: const Icon(Icons.add),
          label: const Text('إضافة قيد'),
          backgroundColor: AppColors.primary,
        ),
      ),
    );
  }
}
