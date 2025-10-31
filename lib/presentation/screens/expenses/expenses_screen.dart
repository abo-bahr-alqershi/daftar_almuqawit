import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('المصروفات', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة المصروفات', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
