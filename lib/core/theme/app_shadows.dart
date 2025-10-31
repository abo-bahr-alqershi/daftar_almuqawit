// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// ظلال جاهزة للاستخدام
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
}
