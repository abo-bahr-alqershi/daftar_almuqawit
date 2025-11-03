import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// أدوات تنسيق النصوص والتواريخ والأرقام
/// 
/// يوفر دوال مساعدة لتنسيق البيانات للعرض
class Formatters {
  Formatters._();

  // ========== تنسيق الأرقام ==========

  /// تنسيق رقم بفواصل الآلاف
  static String number(num value, {int decimalDigits = 0}) {
    return NumberFormat('#,##0${decimalDigits > 0 ? '.' + '0' * decimalDigits : ''}', 'ar')
        .format(value);
  }

  /// تنسيق نسبة مئوية
  static String percentage(num value, {int decimalDigits = 1}) {
    return NumberFormat('#,##0.${'0' * decimalDigits}%', 'ar').format(value / 100);
  }

  /// تنسيق رقم مدمج (اختصار للأرقام الكبيرة)
  static String compactNumber(num value) {
    return NumberFormat.compact(locale: 'ar').format(value);
  }

  // ========== تنسيق العملة ==========

  /// تنسيق مبلغ مالي بالريال اليمني
  static String currency(num value, {bool showSymbol = true}) {
    final formatted = NumberFormat('#,##0.00', 'ar').format(value);
    return showSymbol ? '$formatted ${AppConstants.currencySymbol}' : formatted;
  }

  /// تنسيق مبلغ مالي بدون كسور عشرية
  static String currencyInt(num value, {bool showSymbol = true}) {
    final formatted = NumberFormat('#,##0', 'ar').format(value);
    return showSymbol ? '$formatted ${AppConstants.currencySymbol}' : formatted;
  }

  /// تنسيق مبلغ مالي مدمج
  static String currencyCompact(num value, {bool showSymbol = true}) {
    final formatted = NumberFormat.compact(locale: 'ar').format(value);
    return showSymbol ? '$formatted ${AppConstants.currencySymbol}' : formatted;
  }

  // ========== تنسيق التواريخ ==========

  /// تنسيق تاريخ (yyyy-MM-dd)
  static String date(DateTime date) {
    return DateFormat(AppConstants.dateFormat, 'ar').format(date);
  }

  /// تنسيق تاريخ للعرض (dd/MM/yyyy)
  static String displayDate(DateTime date) {
    return DateFormat(AppConstants.displayDateFormat, 'ar').format(date);
  }

  /// تنسيق تاريخ ووقت
  static String dateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat, 'ar').format(dateTime);
  }

  /// تنسيق تاريخ ووقت للعرض
  static String displayDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.displayDateTimeFormat, 'ar').format(dateTime);
  }

  /// تنسيق وقت (HH:mm)
  static String time(DateTime dateTime) {
    return DateFormat(AppConstants.timeFormat, 'ar').format(dateTime);
  }

  /// تنسيق تاريخ نسبي (منذ ساعة، أمس، إلخ)
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'الآن';
        }
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months ${months == 1 ? 'شهر' : 'أشهر'}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'منذ $years ${years == 1 ? 'سنة' : 'سنوات'}';
    }
  }

  /// تنسيق اسم اليوم
  static String dayName(DateTime date) {
    return DateFormat('EEEE', 'ar').format(date);
  }

  /// تنسيق اسم الشهر
  static String monthName(DateTime date) {
    return DateFormat('MMMM', 'ar').format(date);
  }

  /// تنسيق شهر وسنة
  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'ar').format(date);
  }

  // ========== تنسيق رقم الهاتف ==========

  /// تنسيق رقم هاتف يمني
  static String phone(String phone) {
    // إزالة أي رموز أو مسافات
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // إذا كان الرقم يبدأ بـ 967، نزيله
    String formattedPhone = cleanPhone;
    if (cleanPhone.startsWith('967')) {
      formattedPhone = cleanPhone.substring(3);
    }
    
    // تنسيق الرقم: 777 123 456
    if (formattedPhone.length == 9) {
      return '${formattedPhone.substring(0, 3)} ${formattedPhone.substring(3, 6)} ${formattedPhone.substring(6)}';
    }
    
    return phone;
  }

  /// تنسيق رقم هاتف دولي
  static String phoneInternational(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    if (cleanPhone.startsWith('967')) {
      return '+$cleanPhone';
    } else if (cleanPhone.startsWith('7') && cleanPhone.length == 9) {
      return '+967$cleanPhone';
    }
    
    return phone;
  }

  // ========== تنسيق النصوص ==========

  /// اختصار نص طويل
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - suffix.length)}$suffix';
  }

  /// تحويل أول حرف إلى حرف كبير
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// تحويل كل كلمة لتبدأ بحرف كبير
  static String titleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // ========== تنسيق الحجم ==========

  /// تنسيق حجم الملف
  static String fileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ========== تنسيقات خاصة بالتطبيق ==========

  /// تنسيق حالة الدفع
  static String paymentStatus(String status) {
    switch (status) {
      case AppConstants.paymentCash:
        return 'نقدي';
      case AppConstants.paymentCredit:
        return 'آجل';
      case AppConstants.paymentTransfer:
        return 'تحويل بنكي';
      default:
        return status;
    }
  }

  /// تنسيق حالة الطلب
  static String orderStatus(String status) {
    switch (status) {
      case AppConstants.statusPending:
        return 'معلق';
      case AppConstants.statusCompleted:
        return 'مكتمل';
      case AppConstants.statusCancelled:
        return 'ملغي';
      case AppConstants.statusProcessing:
        return 'قيد المعالجة';
      default:
        return status;
    }
  }

  /// تنسيق التقييم
  static String rating(int rating) {
    return '⭐' * rating;
  }

  // ========== دوال قديمة للتوافق ==========

  /// تنسيق تاريخ (للتوافق)
  static String dateYMD(DateTime date) => Formatters.date(date);

  /// تنسيق وقت (للتوافق)
  static String timeHM(DateTime date) => time(date);
}
