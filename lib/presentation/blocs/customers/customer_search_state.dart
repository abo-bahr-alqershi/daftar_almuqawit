/// حالات Bloc البحث عن العملاء
/// تحتوي على جميع الحالات الممكنة للبحث عن العملاء

import 'package:equatable/equatable.dart';

/// الحالة الأساسية للبحث عن العملاء
abstract class CustomerSearchState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class CustomerSearchInitial extends CustomerSearchState {}

/// حالة جاري البحث
class CustomerSearchLoading extends CustomerSearchState {}

/// حالة نتائج البحث
class CustomerSearchLoaded extends CustomerSearchState {
  final List<Map<String, dynamic>> results;
  final String query;
  
  CustomerSearchLoaded(this.results, this.query);
  
  @override
  List<Object?> get props => [results, query];
}

/// حالة لا توجد نتائج
class CustomerSearchEmpty extends CustomerSearchState {
  final String query;
  CustomerSearchEmpty(this.query);
  
  @override
  List<Object?> get props => [query];
}

/// حالة حدوث خطأ
class CustomerSearchError extends CustomerSearchState {
  final String message;
  CustomerSearchError(this.message);
  
  @override
  List<Object?> get props => [message];
}
