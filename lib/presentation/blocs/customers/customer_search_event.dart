/// أحداث Bloc البحث عن العملاء
/// تحتوي على جميع الأحداث المتعلقة بالبحث عن العملاء

/// الحدث الأساسي للبحث عن العملاء
abstract class CustomerSearchEvent {}

/// حدث البحث عن العملاء
class SearchCustomers extends CustomerSearchEvent {
  final String query;
  SearchCustomers(this.query);
}

/// حدث مسح البحث
class ClearSearch extends CustomerSearchEvent {}
