import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class DebtPaymentsScreen extends StatelessWidget {
  const DebtPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('سداد الديون', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة سداد الديون', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
