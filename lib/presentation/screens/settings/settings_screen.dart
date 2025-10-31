import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('الإعدادات', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة الإعدادات', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
