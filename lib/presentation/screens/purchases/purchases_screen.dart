import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class PurchasesScreen extends StatelessWidget {
  const PurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('المشتريات', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة المشتريات', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
