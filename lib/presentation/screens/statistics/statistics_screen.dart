import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('الإحصائيات', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة الإحصائيات', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
