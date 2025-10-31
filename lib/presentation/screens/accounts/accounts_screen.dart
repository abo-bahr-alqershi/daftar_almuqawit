import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('الحسابات', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة الحسابات', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
