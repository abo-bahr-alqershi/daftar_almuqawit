import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('العملاء', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة العملاء', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
