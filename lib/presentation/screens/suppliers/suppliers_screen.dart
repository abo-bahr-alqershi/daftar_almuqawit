import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('الموردون', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة الموردين', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
