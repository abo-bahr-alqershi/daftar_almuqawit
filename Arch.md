📦 daftar_almuqawit/
├── 📱 lib/
│   ├── 🎯 main.dart
│   ├── 📦 app.dart
│   ├── 🎨 core/
│   │   ├── 🎨 theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_theme.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_dimensions.dart
│   │   ├── 🌐 constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── database_constants.dart
│   │   │   └── storage_keys.dart
│   │   ├── 🛠️ utils/
│   │   │   ├── formatters.dart
│   │   │   ├── validators.dart
│   │   │   ├── helpers.dart
│   │   │   ├── date_utils.dart
│   │   │   ├── currency_utils.dart
│   │   │   └── arabic_numbers.dart
│   │   ├── 🌍 localization/
│   │   │   ├── app_localizations.dart
│   │   │   └── strings.dart
│   │   ├── ⚠️ errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   └── 🔌 services/
│   │       ├── database_service.dart
│   │       ├── backup_service.dart
│   │       ├── notification_service.dart
│   │       └── share_service.dart
│   │
│   ├── 💾 data/
│   │   ├── 📊 database/
│   │   │   ├── database_helper.dart
│   │   │   ├── tables/
│   │   │   │   ├── suppliers_table.dart
│   │   │   │   ├── customers_table.dart
│   │   │   │   ├── qat_types_table.dart
│   │   │   │   ├── purchases_table.dart
│   │   │   │   ├── sales_table.dart
│   │   │   │   ├── debts_table.dart
│   │   │   │   ├── expenses_table.dart
│   │   │   │   └── accounts_table.dart
│   │   │   └── migrations/
│   │   │       └── migration_v1.dart
│   │   ├── 🗄️ repositories/
│   │   │   ├── supplier_repository_impl.dart
│   │   │   ├── customer_repository_impl.dart
│   │   │   ├── sales_repository_impl.dart
│   │   │   ├── purchase_repository_impl.dart
│   │   │   ├── debt_repository_impl.dart
│   │   │   ├── expense_repository_impl.dart
│   │   │   ├── accounting_repository_impl.dart
│   │   │   └── statistics_repository_impl.dart
│   │   ├── 📦 models/
│   │   │   ├── supplier_model.dart
│   │   │   ├── customer_model.dart
│   │   │   ├── qat_type_model.dart
│   │   │   ├── purchase_model.dart
│   │   │   ├── sale_model.dart
│   │   │   ├── debt_model.dart
│   │   │   ├── expense_model.dart
│   │   │   ├── account_model.dart
│   │   │   └── statistics_model.dart
│   │   └── 📡 datasources/
│   │       ├── local/
│   │       │   ├── supplier_local_datasource.dart
│   │       │   ├── customer_local_datasource.dart
│   │       │   ├── sales_local_datasource.dart
│   │       │   └── purchase_local_datasource.dart
│   │       └── remote/
│   │           └── backup_remote_datasource.dart
│   │
│   ├── 🏢 domain/
│   │   ├── 📋 entities/
│   │   │   ├── supplier.dart
│   │   │   ├── customer.dart
│   │   │   ├── qat_type.dart
│   │   │   ├── purchase.dart
│   │   │   ├── sale.dart
│   │   │   ├── debt.dart
│   │   │   ├── expense.dart
│   │   │   ├── account.dart
│   │   │   └── daily_statistics.dart
│   │   ├── 🔗 repositories/
│   │   │   ├── supplier_repository.dart
│   │   │   ├── customer_repository.dart
│   │   │   ├── sales_repository.dart
│   │   │   ├── purchase_repository.dart
│   │   │   ├── debt_repository.dart
│   │   │   ├── expense_repository.dart
│   │   │   ├── accounting_repository.dart
│   │   │   └── statistics_repository.dart
│   │   └── 🎯 usecases/
│   │       ├── suppliers/
│   │       │   ├── add_supplier.dart
│   │       │   ├── get_suppliers.dart
│   │       │   ├── update_supplier.dart
│   │       │   └── delete_supplier.dart
│   │       ├── customers/
│   │       │   ├── add_customer.dart
│   │       │   ├── get_customers.dart
│   │       │   ├── update_customer.dart
│   │       │   ├── block_customer.dart
│   │       │   └── get_customer_debts.dart
│   │       ├── sales/
│   │       │   ├── add_sale.dart
│   │       │   ├── quick_sale.dart
│   │       │   ├── get_today_sales.dart
│   │       │   └── cancel_sale.dart
│   │       ├── purchases/
│   │       │   ├── add_purchase.dart
│   │       │   ├── get_today_purchases.dart
│   │       │   └── update_purchase.dart
│   │       ├── debts/
│   │       │   ├── add_debt.dart
│   │       │   ├── pay_debt.dart
│   │       │   ├── get_pending_debts.dart
│   │       │   └── get_overdue_debts.dart
│   │       ├── accounting/
│   │       │   ├── add_journal_entry.dart
│   │       │   ├── get_cash_balance.dart
│   │       │   └── close_daily_accounts.dart
│   │       └── statistics/
│   │           ├── get_daily_statistics.dart
│   │           ├── get_weekly_report.dart
│   │           ├── get_monthly_report.dart
│   │           └── get_profit_analysis.dart
│   │
│   └── 🎨 presentation/
│       ├── 🧩 blocs/
│       │   ├── app/
│       │   │   ├── app_bloc.dart
│       │   │   ├── app_event.dart
│       │   │   └── app_state.dart
│       │   ├── auth/
│       │   │   ├── auth_bloc.dart
│       │   │   ├── auth_event.dart
│       │   │   └── auth_state.dart
│       │   ├── home/
│       │   │   ├── home_bloc.dart
│       │   │   ├── home_event.dart
│       │   │   └── home_state.dart
│       │   ├── suppliers/
│       │   │   ├── suppliers_bloc.dart
│       │   │   ├── suppliers_event.dart
│       │   │   └── suppliers_state.dart
│       │   ├── customers/
│       │   │   ├── customers_bloc.dart
│       │   │   ├── customers_event.dart
│       │   │   └── customers_state.dart
│       │   ├── sales/
│       │   │   ├── sales_bloc.dart
│       │   │   ├── sales_event.dart
│       │   │   ├── sales_state.dart
│       │   │   └── quick_sale/
│       │   │       ├── quick_sale_bloc.dart
│       │   │       ├── quick_sale_event.dart
│       │   │       └── quick_sale_state.dart
│       │   ├── purchases/
│       │   │   ├── purchases_bloc.dart
│       │   │   ├── purchases_event.dart
│       │   │   └── purchases_state.dart
│       │   ├── debts/
│       │   │   ├── debts_bloc.dart
│       │   │   ├── debts_event.dart
│       │   │   └── debts_state.dart
│       │   ├── expenses/
│       │   │   ├── expenses_bloc.dart
│       │   │   ├── expenses_event.dart
│       │   │   └── expenses_state.dart
│       │   ├── accounting/
│       │   │   ├── accounting_bloc.dart
│       │   │   ├── accounting_event.dart
│       │   │   └── accounting_state.dart
│       │   └── statistics/
│       │       ├── statistics_bloc.dart
│       │       ├── statistics_event.dart
│       │       └── statistics_state.dart
│       │
│       ├── 📱 screens/
│       │   ├── splash/
│       │   │   └── splash_screen.dart
│       │   ├── auth/
│       │   │   ├── login_screen.dart
│       │   │   └── setup_screen.dart
│       │   ├── home/
│       │   │   ├── home_screen.dart
│       │   │   └── widgets/
│       │   │       ├── menu_card.dart
│       │   │       ├── summary_card.dart
│       │   │       └── quick_stats_widget.dart
│       │   ├── suppliers/
│       │   │   ├── suppliers_list_screen.dart
│       │   │   ├── add_supplier_screen.dart
│       │   │   ├── supplier_details_screen.dart
│       │   │   └── widgets/
│       │   │       ├── supplier_card.dart
│       │   │       └── supplier_form.dart
│       │   ├── customers/
│       │   │   ├── customers_list_screen.dart
│       │   │   ├── add_customer_screen.dart
│       │   │   ├── customer_details_screen.dart
│       │   │   └── widgets/
│       │   │       ├── customer_card.dart
│       │   │       ├── customer_search.dart
│       │   │       └── customer_debt_card.dart
│       │   ├── sales/
│       │   │   ├── sales_screen.dart
│       │   │   ├── quick_sale_screen.dart
│       │   │   ├── sale_details_screen.dart
│       │   │   └── widgets/
│       │   │       ├── sale_form.dart
│       │   │       ├── qat_type_selector.dart
│       │   │       ├── payment_buttons.dart
│       │   │       └── sale_summary.dart
│       │   ├── purchases/
│       │   │   ├── purchases_screen.dart
│       │   │   ├── add_purchase_screen.dart
│       │   │   └── widgets/
│       │   │       ├── purchase_form.dart
│       │   │       └── supplier_selector.dart
│       │   ├── debts/
│       │   │   ├── debts_screen.dart
│       │   │   ├── debt_payment_screen.dart
│       │   │   └── widgets/
│       │   │       ├── debt_card.dart
│       │   │       ├── payment_history.dart
│       │   │       └── debt_filters.dart
│       │   ├── expenses/
│       │   │   ├── expenses_screen.dart
│       │   │   ├── add_expense_screen.dart
│       │   │   └── widgets/
│       │   │       ├── expense_category_selector.dart
│       │   │       └── expense_card.dart
│       │   ├── accounting/
│       │   │   ├── cash_screen.dart
│       │   │   ├── journal_entries_screen.dart
│       │   │   └── widgets/
│       │   │       ├── cash_flow_widget.dart
│       │   │       └── journal_entry_card.dart
│       │   ├── reports/
│       │   │   ├── reports_screen.dart
│       │   │   ├── daily_report_screen.dart
│       │   │   ├── weekly_report_screen.dart
│       │   │   ├── monthly_report_screen.dart
│       │   │   └── widgets/
│       │   │       ├── chart_widget.dart
│       │   │       ├── profit_card.dart
│       │   │       └── best_sellers_widget.dart
│       │   └── settings/
│       │       ├── settings_screen.dart
│       │       ├── backup_screen.dart
│       │       └── about_screen.dart
│       │
│       ├── 🧩 widgets/
│       │   ├── common/
│       │   │   ├── app_button.dart
│       │   │   ├── app_text_field.dart
│       │   │   ├── app_dropdown.dart
│       │   │   ├── loading_widget.dart
│       │   │   ├── error_widget.dart
│       │   │   ├── empty_widget.dart
│       │   │   ├── confirm_dialog.dart
│       │   │   └── number_pad.dart
│       │   └── charts/
│       │       ├── pie_chart_widget.dart
│       │       ├── bar_chart_widget.dart
│       │       └── line_chart_widget.dart
│       │
│       └── 🚦 routes/
│           ├── app_router.dart
│           └── route_names.dart
│
├── 🧪 test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── 📦 assets/
│   ├── images/
│   ├── icons/
│   ├── fonts/
│   └── sounds/
│
├── 📄 pubspec.yaml
├── 📖 README.md
└── 🔧 analysis_options.yaml
