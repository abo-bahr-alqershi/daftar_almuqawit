📦 daftar_almuqawit/
│
├── 📄 pubspec.yaml
├── 📖 README.md
├── 🔧 analysis_options.yaml
├── ⚙️ .env
├── 🔥 google-services.json (Android)
├── 🔥 GoogleService-Info.plist (iOS)
│
├── 📱 lib/
│   ├── 🎯 main.dart
│   ├── 📦 app.dart
│   ├── 🔥 firebase_options.dart
│   │
│   ├── 🎨 core/
│   │   ├── 🎨 theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_theme.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── app_dimensions.dart
│   │   │   └── app_shadows.dart
│   │   │
│   │   ├── 🌐 constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── database_constants.dart
│   │   │   ├── firebase_constants.dart
│   │   │   ├── storage_keys.dart
│   │   │   └── api_endpoints.dart
│   │   │
│   │   ├── 🛠️ utils/
│   │   │   ├── formatters.dart
│   │   │   ├── validators.dart
│   │   │   ├── helpers.dart
│   │   │   ├── date_utils.dart
│   │   │   ├── currency_utils.dart
│   │   │   ├── arabic_numbers.dart
│   │   │   ├── network_utils.dart
│   │   │   ├── permission_handler.dart
│   │   │   └── device_info.dart
│   │   │
│   │   ├── 🌍 localization/
│   │   │   ├── app_localizations.dart
│   │   │   ├── strings.dart
│   │   │   └── translations/
│   │   │       ├── ar.json
│   │   │       └── en.json
│   │   │
│   │   ├── ⚠️ errors/
│   │   │   ├── exceptions.dart
│   │   │   ├── failures.dart
│   │   │   └── error_handler.dart
│   │   │
│   │   ├── 🔌 services/
│   │   │   ├── 🔥 firebase/
│   │   │   │   ├── firebase_service.dart
│   │   │   │   ├── firestore_service.dart
│   │   │   │   ├── firebase_auth_service.dart
│   │   │   │   ├── firebase_storage_service.dart
│   │   │   │   └── firebase_analytics_service.dart
│   │   │   │
│   │   │   ├── 💾 local/
│   │   │   │   ├── database_service.dart
│   │   │   │   ├── cache_service.dart
│   │   │   │   ├── shared_preferences_service.dart
│   │   │   │   └── secure_storage_service.dart
│   │   │   │
│   │   │   ├── 🔄 sync/
│   │   │   │   ├── sync_service.dart
│   │   │   │   ├── sync_queue.dart
│   │   │   │   ├── sync_manager.dart
│   │   │   │   ├── conflict_resolver.dart
│   │   │   │   └── offline_queue.dart
│   │   │   │
│   │   │   ├── 📡 network/
│   │   │   │   ├── network_service.dart
│   │   │   │   ├── connectivity_service.dart
│   │   │   │   └── api_client.dart
│   │   │   │
│   │   │   ├── backup_service.dart
│   │   │   ├── export_service.dart
│   │   │   ├── notification_service.dart
│   │   │   ├── share_service.dart
│   │   │   ├── print_service.dart
│   │   │   └── logger_service.dart
│   │   │
│   │   └── 💉 di/
│   │       ├── injection_container.dart
│   │       ├── service_locator.dart
│   │       └── modules/
│   │           ├── database_module.dart
│   │           ├── firebase_module.dart
│   │           ├── bloc_module.dart
│   │           └── repository_module.dart
│   │
│   ├── 💾 data/
│   │   ├── 📊 database/
│   │   │   ├── database_helper.dart
│   │   │   ├── database_config.dart
│   │   │   ├── 📋 tables/
│   │   │   │   ├── suppliers_table.dart
│   │   │   │   ├── customers_table.dart
│   │   │   │   ├── qat_types_table.dart
│   │   │   │   ├── purchases_table.dart
│   │   │   │   ├── sales_table.dart
│   │   │   │   ├── debts_table.dart
│   │   │   │   ├── expenses_table.dart
│   │   │   │   ├── accounts_table.dart
│   │   │   │   ├── journal_entries_table.dart
│   │   │   │   ├── sync_queue_table.dart
│   │   │   │   └── metadata_table.dart
│   │   │   │
│   │   │   ├── 🔄 migrations/
│   │   │   │   ├── migration_manager.dart
│   │   │   │   ├── migration_v1.dart
│   │   │   │   ├── migration_v2.dart
│   │   │   │   └── migration_v3.dart
│   │   │   │
│   │   │   └── 🔍 queries/
│   │   │       ├── base_queries.dart
│   │   │       ├── report_queries.dart
│   │   │       └── search_queries.dart
│   │   │
│   │   ├── 🔥 firebase/
│   │   │   ├── collections/
│   │   │   │   ├── users_collection.dart
│   │   │   │   ├── suppliers_collection.dart
│   │   │   │   ├── customers_collection.dart
│   │   │   │   ├── sales_collection.dart
│   │   │   │   ├── purchases_collection.dart
│   │   │   │   ├── debts_collection.dart
│   │   │   │   ├── expenses_collection.dart
│   │   │   │   └── backups_collection.dart
│   │   │   │
│   │   │   └── converters/
│   │   │       ├── timestamp_converter.dart
│   │   │       └── model_converter.dart
│   │   │
│   │   ├── 📦 models/
│   │   │   ├── base/
│   │   │   │   ├── base_model.dart
│   │   │   │   └── syncable_model.dart
│   │   │   │
│   │   │   ├── supplier_model.dart
│   │   │   ├── customer_model.dart
│   │   │   ├── qat_type_model.dart
│   │   │   ├── purchase_model.dart
│   │   │   ├── sale_model.dart
│   │   │   ├── debt_model.dart
│   │   │   ├── expense_model.dart
│   │   │   ├── account_model.dart
│   │   │   ├── journal_entry_model.dart
│   │   │   ├── statistics_model.dart
│   │   │   ├── user_model.dart
│   │   │   ├── sync_record_model.dart
│   │   │   └── backup_model.dart
│   │   │
│   │   ├── 📡 datasources/
│   │   │   ├── 💾 local/
│   │   │   │   ├── base_local_datasource.dart
│   │   │   │   ├── supplier_local_datasource.dart
│   │   │   │   ├── customer_local_datasource.dart
│   │   │   │   ├── sales_local_datasource.dart
│   │   │   │   ├── purchase_local_datasource.dart
│   │   │   │   ├── debt_local_datasource.dart
│   │   │   │   ├── expense_local_datasource.dart
│   │   │   │   ├── accounting_local_datasource.dart
│   │   │   │   └── sync_local_datasource.dart
│   │   │   │
│   │   │   └── 🔥 remote/
│   │   │       ├── base_remote_datasource.dart
│   │   │       ├── supplier_remote_datasource.dart
│   │   │       ├── customer_remote_datasource.dart
│   │   │       ├── sales_remote_datasource.dart
│   │   │       ├── purchase_remote_datasource.dart
│   │   │       ├── debt_remote_datasource.dart
│   │   │       ├── expense_remote_datasource.dart
│   │   │       ├── accounting_remote_datasource.dart
│   │   │       ├── backup_remote_datasource.dart
│   │   │       └── sync_remote_datasource.dart
│   │   │
│   │   └── 🗄️ repositories/
│   │       ├── base/
│   │       │   └── base_repository_impl.dart
│   │       │
│   │       ├── supplier_repository_impl.dart
│   │       ├── customer_repository_impl.dart
│   │       ├── sales_repository_impl.dart
│   │       ├── purchase_repository_impl.dart
│   │       ├── debt_repository_impl.dart
│   │       ├── expense_repository_impl.dart
│   │       ├── accounting_repository_impl.dart
│   │       ├── statistics_repository_impl.dart
│   │       ├── sync_repository_impl.dart
│   │       └── backup_repository_impl.dart
│   │
│   ├── 🏢 domain/
│   │   ├── 📋 entities/
│   │   │   ├── base/
│   │   │   │   ├── base_entity.dart
│   │   │   │   └── syncable_entity.dart
│   │   │   │
│   │   │   ├── supplier.dart
│   │   │   ├── customer.dart
│   │   │   ├── qat_type.dart
│   │   │   ├── purchase.dart
│   │   │   ├── sale.dart
│   │   │   ├── debt.dart
│   │   │   ├── expense.dart
│   │   │   ├── account.dart
│   │   │   ├── journal_entry.dart
│   │   │   ├── daily_statistics.dart
│   │   │   ├── user.dart
│   │   │   └── sync_status.dart
│   │   │
│   │   ├── 🔗 repositories/
│   │   │   ├── base/
│   │   │   │   └── base_repository.dart
│   │   │   │
│   │   │   ├── supplier_repository.dart
│   │   │   ├── customer_repository.dart
│   │   │   ├── sales_repository.dart
│   │   │   ├── purchase_repository.dart
│   │   │   ├── debt_repository.dart
│   │   │   ├── expense_repository.dart
│   │   │   ├── accounting_repository.dart
│   │   │   ├── statistics_repository.dart
│   │   │   ├── sync_repository.dart
│   │   │   └── backup_repository.dart
│   │   │
│   │   └── 🎯 usecases/
│   │       ├── base/
│   │       │   └── base_usecase.dart
│   │       │
│   │       ├── 🔄 sync/
│   │       │   ├── sync_data.dart
│   │       │   ├── check_sync_status.dart
│   │       │   ├── resolve_conflicts.dart
│   │       │   └── queue_offline_operation.dart
│   │       │
│   │       ├── 📊 suppliers/
│   │       │   ├── add_supplier.dart
│   │       │   ├── get_suppliers.dart
│   │       │   ├── update_supplier.dart
│   │       │   ├── delete_supplier.dart
│   │       │   └── search_suppliers.dart
│   │       │
│   │       ├── 👥 customers/
│   │       │   ├── add_customer.dart
│   │       │   ├── get_customers.dart
│   │       │   ├── update_customer.dart
│   │       │   ├── block_customer.dart
│   │       │   ├── get_customer_debts.dart
│   │       │   └── get_customer_history.dart
│   │       │
│   │       ├── 💰 sales/
│   │       │   ├── add_sale.dart
│   │       │   ├── quick_sale.dart
│   │       │   ├── get_today_sales.dart
│   │       │   ├── cancel_sale.dart
│   │       │   ├── update_sale.dart
│   │       │   └── get_sales_by_customer.dart
│   │       │
│   │       ├── 📦 purchases/
│   │       │   ├── add_purchase.dart
│   │       │   ├── get_today_purchases.dart
│   │       │   ├── update_purchase.dart
│   │       │   ├── cancel_purchase.dart
│   │       │   └── get_purchases_by_supplier.dart
│   │       │
│   │       ├── 💳 debts/
│   │       │   ├── add_debt.dart
│   │       │   ├── pay_debt.dart
│   │       │   ├── partial_payment.dart
│   │       │   ├── get_pending_debts.dart
│   │       │   ├── get_overdue_debts.dart
│   │       │   └── send_reminder.dart
│   │       │
│   │       ├── 💸 expenses/
│   │       │   ├── add_expense.dart
│   │       │   ├── update_expense.dart
│   │       │   ├── delete_expense.dart
│   │       │   ├── get_daily_expenses.dart
│   │       │   └── get_expenses_by_category.dart
│   │       │
│   │       ├── 📊 accounting/
│   │       │   ├── add_journal_entry.dart
│   │       │   ├── get_cash_balance.dart
│   │       │   ├── close_daily_accounts.dart
│   │       │   ├── get_trial_balance.dart
│   │       │   └── generate_financial_statements.dart
│   │       │
│   │       ├── 📈 statistics/
│   │       │   ├── get_daily_statistics.dart
│   │       │   ├── get_weekly_report.dart
│   │       │   ├── get_monthly_report.dart
│   │       │   ├── get_yearly_report.dart
│   │       │   ├── get_profit_analysis.dart
│   │       │   ├── get_best_sellers.dart
│   │       │   └── get_customer_ranking.dart
│   │       │
│   │       └── 💾 backup/
│   │           ├── create_backup.dart
│   │           ├── restore_backup.dart
│   │           ├── schedule_auto_backup.dart
│   │           └── export_to_excel.dart
│   │
│   └── 🎨 presentation/
│       ├── 🧩 blocs/
│       │   ├── 📱 app/
│       │   │   ├── app_bloc.dart
│       │   │   ├── app_event.dart
│       │   │   ├── app_state.dart
│       │   │   └── app_settings_bloc.dart
│       │   │
│       │   ├── 🔐 auth/
│       │   │   ├── auth_bloc.dart
│       │   │   ├── auth_event.dart
│       │   │   ├── auth_state.dart
│       │   │   └── auth_validator.dart
│       │   │
│       │   ├── 🔄 sync/
│       │   │   ├── sync_bloc.dart
│       │   │   ├── sync_event.dart
│       │   │   ├── sync_state.dart
│       │   │   └── sync_monitor.dart
│       │   │
│       │   ├── 🏠 home/
│       │   │   ├── home_bloc.dart
│       │   │   ├── home_event.dart
│       │   │   ├── home_state.dart
│       │   │   └── dashboard_bloc.dart
│       │   │
│       │   ├── 📊 suppliers/
│       │   │   ├── suppliers_bloc.dart
│       │   │   ├── suppliers_event.dart
│       │   │   ├── suppliers_state.dart
│       │   │   └── supplier_form_bloc.dart
│       │   │
│       │   ├── 👥 customers/
│       │   │   ├── customers_bloc.dart
│       │   │   ├── customers_event.dart
│       │   │   ├── customers_state.dart
│       │   │   ├── customer_form_bloc.dart
│       │   │   └── customer_search_bloc.dart
│       │   │
│       │   ├── 💰 sales/
│       │   │   ├── sales_bloc.dart
│       │   │   ├── sales_event.dart
│       │   │   ├── sales_state.dart
│       │   │   ├── quick_sale/
│       │   │   │   ├── quick_sale_bloc.dart
│       │   │   │   ├── quick_sale_event.dart
│       │   │   │   └── quick_sale_state.dart
│       │   │   └── sale_form_bloc.dart
│       │   │
│       │   ├── 📦 purchases/
│       │   │   ├── purchases_bloc.dart
│       │   │   ├── purchases_event.dart
│       │   │   ├── purchases_state.dart
│       │   │   └── purchase_form_bloc.dart
│       │   │
│       │   ├── 💳 debts/
│       │   │   ├── debts_bloc.dart
│       │   │   ├── debts_event.dart
│       │   │   ├── debts_state.dart
│       │   │   └── payment_bloc.dart
│       │   │
│       │   ├── 💸 expenses/
│       │   │   ├── expenses_bloc.dart
│       │   │   ├── expenses_event.dart
│       │   │   ├── expenses_state.dart
│       │   │   └── expense_form_bloc.dart
│       │   │
│       │   ├── 📊 accounting/
│       │   │   ├── accounting_bloc.dart
│       │   │   ├── accounting_event.dart
│       │   │   ├── accounting_state.dart
│       │   │   └── cash_management_bloc.dart
│       │   │
│       │   ├── 📈 statistics/
│       │   │   ├── statistics_bloc.dart
│       │   │   ├── statistics_event.dart
│       │   │   ├── statistics_state.dart
│       │   │   └── reports_bloc.dart
│       │   │
│       │   └── ⚙️ settings/
│       │       ├── settings_bloc.dart
│       │       ├── settings_event.dart
│       │       ├── settings_state.dart
│       │       └── backup_bloc.dart
│       │
│       ├── 📱 screens/
│       │   ├── 🚀 splash/
│       │   │   ├── splash_screen.dart
│       │   │   └── widgets/
│       │   │       └── logo_animation.dart
│       │   │
│       │   ├── 🔐 auth/
│       │   │   ├── login_screen.dart
│       │   │   ├── register_screen.dart
│       │   │   ├── setup_screen.dart
│       │   │   ├── forgot_password_screen.dart
│       │   │   └── widgets/
│       │   │       ├── auth_header.dart
│       │   │       ├── login_form.dart
│       │   │       └── social_login_buttons.dart
│       │   │
│       │   ├── 🏠 home/
│       │   │   ├── home_screen.dart
│       │   │   ├── dashboard_screen.dart
│       │   │   └── widgets/
│       │   │       ├── menu_grid.dart
│       │   │       ├── menu_card.dart
│       │   │       ├── summary_card.dart
│       │   │       ├── quick_stats_widget.dart
│       │   │       ├── recent_activities.dart
│       │   │       ├── shortcuts_bar.dart
│       │   │       └── sync_indicator.dart
│       │   │
│       │   ├── 📊 suppliers/
│       │   │   ├── suppliers_list_screen.dart
│       │   │   ├── add_supplier_screen.dart
│       │   │   ├── edit_supplier_screen.dart
│       │   │   ├── supplier_details_screen.dart
│       │   │   └── widgets/
│       │   │       ├── supplier_card.dart
│       │   │       ├── supplier_form.dart
│       │   │       ├── supplier_search_bar.dart
│       │   │       ├── supplier_filter_chips.dart
│       │   │       └── supplier_stats_card.dart
│       │   │
│       │   ├── 👥 customers/
│       │   │   ├── customers_list_screen.dart
│       │   │   ├── add_customer_screen.dart
│       │   │   ├── edit_customer_screen.dart
│       │   │   ├── customer_details_screen.dart
│       │   │   ├── blocked_customers_screen.dart
│       │   │   └── widgets/
│       │   │       ├── customer_card.dart
│       │   │       ├── customer_form.dart
│       │   │       ├── customer_search.dart
│       │   │       ├── customer_debt_card.dart
│       │   │       ├── customer_history_tab.dart
│       │   │       └── customer_rating_widget.dart
│       │   │
│       │   ├── 💰 sales/
│       │   │   ├── sales_screen.dart
│       │   │   ├── quick_sale_screen.dart
│       │   │   ├── add_sale_screen.dart
│       │   │   ├── sale_details_screen.dart
│       │   │   ├── today_sales_screen.dart
│       │   │   └── widgets/
│       │   │       ├── sale_form.dart
│       │   │       ├── qat_type_selector.dart
│       │   │       ├── customer_selector.dart
│       │   │       ├── payment_method_selector.dart
│       │   │       ├── payment_buttons.dart
│       │   │       ├── sale_summary.dart
│       │   │       ├── sale_item_card.dart
│       │   │       ├── quantity_input.dart
│       │   │       └── receipt_preview.dart
│       │   │
│       │   ├── 📦 purchases/
│       │   │   ├── purchases_screen.dart
│       │   │   ├── add_purchase_screen.dart
│       │   │   ├── edit_purchase_screen.dart
│       │   │   ├── purchase_details_screen.dart
│       │   │   └── widgets/
│       │   │       ├── purchase_form.dart
│       │   │       ├── supplier_selector.dart
│       │   │       ├── purchase_item_card.dart
│       │   │       ├── cost_calculator.dart
│       │   │       └── purchase_summary.dart
│       │   │
│       │   ├── 💳 debts/
│       │   │   ├── debts_screen.dart
│       │   │   ├── add_debt_screen.dart
│       │   │   ├── debt_payment_screen.dart
│       │   │   ├── debt_details_screen.dart
│       │   │   ├── overdue_debts_screen.dart
│       │   │   └── widgets/
│       │   │       ├── debt_card.dart
│       │   │       ├── debt_form.dart
│       │   │       ├── payment_form.dart
│       │   │       ├── payment_history.dart
│       │   │       ├── debt_filters.dart
│       │   │       ├── debt_timeline.dart
│       │   │       └── reminder_settings.dart
│       │   │
│       │   ├── 💸 expenses/
│       │   │   ├── expenses_screen.dart
│       │   │   ├── add_expense_screen.dart
│       │   │   ├── expense_categories_screen.dart
│       │   │   └── widgets/
│       │   │       ├── expense_form.dart
│       │   │       ├── expense_category_selector.dart
│       │   │       ├── expense_card.dart
│       │   │       ├── expense_chart.dart
│       │   │       └── category_manager.dart
│       │   │
│       │   ├── 📊 accounting/
│       │   │   ├── cash_screen.dart
│       │   │   ├── journal_entries_screen.dart
│       │   │   ├── add_journal_entry_screen.dart
│       │   │   ├── trial_balance_screen.dart
│       │   │   ├── income_statement_screen.dart
│       │   │   └── widgets/
│       │   │       ├── cash_flow_widget.dart
│       │   │       ├── journal_entry_card.dart
│       │   │       ├── account_selector.dart
│       │   │       ├── balance_sheet_widget.dart
│       │   │       └── closing_entries_widget.dart
│       │   │
│       │   ├── 📈 reports/
│       │   │   ├── reports_screen.dart
│       │   │   ├── daily_report_screen.dart
│       │   │   ├── weekly_report_screen.dart
│       │   │   ├── monthly_report_screen.dart
│       │   │   ├── yearly_report_screen.dart
│       │   │   ├── custom_report_screen.dart
│       │   │   └── widgets/
│       │   │       ├── report_card.dart
│       │   │       ├── chart_widget.dart
│       │   │       ├── profit_card.dart
│       │   │       ├── best_sellers_widget.dart
│       │   │       ├── customer_ranking_widget.dart
│       │   │       ├── date_range_picker.dart
│       │   │       ├── export_options.dart
│       │   │       └── report_filters.dart
│       │   │
│       │   └── ⚙️ settings/
│       │       ├── settings_screen.dart
│       │       ├── profile_screen.dart
│       │       ├── backup_screen.dart
│       │       ├── sync_settings_screen.dart
│       │       ├── notification_settings_screen.dart
│       │       ├── language_screen.dart
│       │       ├── theme_screen.dart
│       │       ├── security_screen.dart
│       │       ├── about_screen.dart
│       │       └── widgets/
│       │           ├── settings_tile.dart
│       │           ├── backup_options.dart
│       │           ├── sync_status_card.dart
│       │           ├── storage_info.dart
│       │           └── app_version_card.dart
│       │
│       ├── 🧩 widgets/
│       │   ├── 🎯 common/
│       │   │   ├── app_button.dart
│       │   │   ├── app_text_field.dart
│       │   │   ├── app_dropdown.dart
│       │   │   ├── app_checkbox.dart
│       │   │   ├── app_radio_button.dart
│       │   │   ├── app_switch.dart
│       │   │   ├── app_slider.dart
│       │   │   ├── app_date_picker.dart
│       │   │   ├── app_time_picker.dart
│       │   │   ├── loading_widget.dart
│       │   │   ├── error_widget.dart
│       │   │   ├── empty_widget.dart
│       │   │   ├── retry_widget.dart
│       │   │   ├── confirm_dialog.dart
│       │   │   ├── info_dialog.dart
│       │   │   ├── bottom_sheet_widget.dart
│       │   │   ├── snackbar_widget.dart
│       │   │   ├── number_pad.dart
│       │   │   ├── search_bar.dart
│       │   │   ├── filter_chip_list.dart
│       │   │   └── offline_banner.dart
│       │   │
│       │   ├── 📊 charts/
│       │   │   ├── pie_chart_widget.dart
│       │   │   ├── bar_chart_widget.dart
│       │   │   ├── line_chart_widget.dart
│       │   │   ├── area_chart_widget.dart
│       │   │   └── gauge_chart_widget.dart
│       │   │
│       │   ├── 📋 lists/
│       │   │   ├── paginated_list.dart
│       │   │   ├── infinite_scroll_list.dart
│       │   │   ├── grouped_list.dart
│       │   │   └── swipeable_list_item.dart
│       │   │
│       │   └── 🎨 animations/
│       │       ├── fade_animation.dart
│       │       ├── slide_animation.dart
│       │       ├── scale_animation.dart
│       │       └── shimmer_effect.dart
│       │
│       └── 🚦 navigation/
│           ├── app_router.dart
│           ├── route_names.dart
│           ├── route_guards.dart
│           ├── route_observers.dart
│           └── deep_link_handler.dart
│
├── 🧪 test/
│   ├── unit/
│   │   ├── domain/
│   │   ├── data/
│   │   └── core/
│   ├── widget/
│   │   ├── screens/
│   │   └── widgets/
│   ├── integration/
│   │   ├── sync_test.dart
│   │   └── offline_test.dart
│   └── fixtures/
│       └── test_data.dart
│
├── 📦 assets/
│   ├── images/
│   │   ├── logo/
│   │   ├── icons/
│   │   └── illustrations/
│   ├── animations/
│   │   └── lottie/
│   ├── fonts/
│   │   ├── arabic/
│   │   └── english/
│   ├── sounds/
│   └── certificates/
│
├── 🔧 android/
│   ├── app/
│   │   ├── src/
│   │   │   └── main/
│   │   │       ├── AndroidManifest.xml
│   │   │       └── res/
│   │   └── build.gradle
│   └── build.gradle
│
├── 🍎 ios/
│   ├── Runner/
│   │   ├── Info.plist
│   │   └── AppDelegate.swift
│   └── Podfile
│
└── 🌐 web/
    ├── index.html
    └── manifest.json

## 📋 تفاصيل الملفات الأساسية

### 🔥 Firebase Configuration Files:
- firebase_options.dart (تكوين Firebase)
- google-services.json (Android)
- GoogleService-Info.plist (iOS)

### 💾 Database Schema:
- SQLite للتخزين المحلي
- Firestore للتخزين السحابي
- جداول المزامنة للعمليات غير المتصلة

### 🔄 Sync System:
- sync_service.dart (خدمة المزامنة الرئيسية)
- offline_queue.dart (قائمة العمليات غير المتصلة)
- conflict_resolver.dart (حل تعارضات المزامنة)
- sync_monitor.dart (مراقب حالة المزامنة)

### 📡 Network Handling:
- connectivity_service.dart (مراقبة الاتصال)
- network_utils.dart (أدوات الشبكة)
- api_client.dart (عميل API)

### 🎯 Key Features:
1. **Offline-First Architecture**: العمل بدون إنترنت
2. **Auto-Sync**: المزامنة التلقائية عند توفر الاتصال
3. **Conflict Resolution**: حل التعارضات تلقائياً
4. **Real-time Updates**: تحديثات فورية عبر Firebase
5. **Local Caching**: تخزين مؤقت محلي للأداء
6. **Queue Management**: إدارة قوائم العمليات
7. **Backup & Restore**: نسخ احتياطي واستعادة
8. **Multi-platform**: دعم متعدد المنصات

## 🛠️ Dependencies (pubspec.yaml):
```yaml
dependencies:
  # Core
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
  firebase_analytics: ^10.7.0
  
  # Local Storage
  sqflite: ^2.3.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # State Management
  flutter_bloc: ^8.1.3
  
  # Networking
  dio: ^5.4.0
  connectivity_plus: ^5.0.2
  
  # UI
  flutter_screenutil: ^5.9.0
  animations: ^2.0.8
  
  # Utilities
  intl: ^0.18.1
  path_provider: ^2.1.1
  permission_handler: ^11.1.0