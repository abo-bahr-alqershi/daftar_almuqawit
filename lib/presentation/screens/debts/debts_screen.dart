import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('الديون', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة الديون', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
