// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';

/// كيان أساسي يحتوي معرف اختياري
abstract class BaseEntity extends Equatable {
  final int? id;
  const BaseEntity({this.id});

  @override
  List<Object?> get props => [id];
}
