// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';

/// الحدث الأساسي للشاشة الرئيسية
abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// حدث بدء الشاشة الرئيسية
class HomeStarted extends HomeEvent {}

/// حدث تحديث الشاشة الرئيسية
class HomeRefreshed extends HomeEvent {}

/// حدث الانتقال لقسم معين
class HomeNavigateToSection extends HomeEvent {
  final String section;
  
  HomeNavigateToSection(this.section);
  
  @override
  List<Object?> get props => [section];
}
