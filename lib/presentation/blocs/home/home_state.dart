// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';

/// الحالة الأساسية للشاشة الرئيسية
abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class HomeInitial extends HomeState {}

/// حالة التحميل
class HomeLoading extends HomeState {}

/// حالة التحميل بنجاح
class HomeLoaded extends HomeState {
  final Map<String, dynamic> data;
  
  HomeLoaded(this.data);
  
  @override
  List<Object?> get props => [data];
}

/// حالة الخطأ
class HomeError extends HomeState {
  final String message;
  
  HomeError(this.message);
  
  @override
  List<Object?> get props => [message];
}
