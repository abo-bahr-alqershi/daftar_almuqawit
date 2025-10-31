import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('المبيعات', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة المبيعات', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
