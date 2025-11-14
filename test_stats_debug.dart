/// ملف اختبار للتحقق من الإحصائيات
/// 
/// استخدم هذا الملف لتشخيص مشاكل الإحصائيات

import 'package:flutter/material.dart';

void main() {
  print('=== اختبار حساب التاريخ ===');
  
  final now = DateTime.now();
  final todayISO = now.toIso8601String().split('T')[0];
  
  print('التاريخ الحالي: $now');
  print('التاريخ بصيغة ISO: $todayISO');
  print('التاريخ بصيغة toString: ${now.toString().split(' ')[0]}');
  
  // اختبار مقارنة التواريخ
  final testDate1 = '2025-01-15';
  final testDate2 = '2025-01-15';
  print('\nمقارنة: $testDate1 == $testDate2 : ${testDate1 == testDate2}');
  
  print('\n=== نهاية الاختبار ===');
}
