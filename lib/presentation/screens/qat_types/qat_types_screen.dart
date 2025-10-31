import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

class QatTypesScreen extends StatelessWidget {
  const QatTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('أنواع القات', style: AppTextStyles.title)),
        body: Center(
          child: Text('شاشة أنواع القات', style: AppTextStyles.body),
        ),
      ),
    );
  }
}
