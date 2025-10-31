import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class AccountingScreen extends StatelessWidget {
  const AccountingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('المحاسبة', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة المحاسبة', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
