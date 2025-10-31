// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// الشاشة الرئيسية كبداية
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('الصفحة الرئيسية', style: AppTextStyles.title)),
        body: Center(
          child: Text('أهلاً بك في دفتر المقاوت', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
