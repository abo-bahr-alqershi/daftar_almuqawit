/// أبعاد وثوابت الهوامش والأحجام المستخدمة في التطبيق
/// 
/// يوفر قيم موحدة للمسافات والأحجام لضمان تناسق التصميم
class AppDimensions {
  AppDimensions._();

  // ========== المسافات (Spacing) ==========
  
  /// مسافة صغيرة جداً
  static const double spaceXS = 4.0;
  
  /// مسافة صغيرة
  static const double spaceS = 8.0;
  
  /// مسافة متوسطة
  static const double spaceM = 16.0;
  
  /// مسافة كبيرة
  static const double spaceL = 24.0;
  
  /// مسافة كبيرة جداً
  static const double spaceXL = 32.0;
  
  /// مسافة ضخمة
  static const double spaceXXL = 48.0;

  // ========== الحشو (Padding) ==========
  
  /// حشو صغير جداً
  static const double paddingXS = 4.0;
  
  /// حشو صغير
  static const double paddingS = 8.0;
  
  /// حشو متوسط
  static const double paddingM = 16.0;
  
  /// حشو كبير
  static const double paddingL = 24.0;
  
  /// حشو كبير جداً
  static const double paddingXL = 32.0;

  // ========== الهوامش (Margin) ==========
  
  /// هامش صغير جداً
  static const double marginXS = 4.0;
  
  /// هامش صغير
  static const double marginS = 8.0;
  
  /// هامش متوسط
  static const double marginM = 16.0;
  
  /// هامش كبير
  static const double marginL = 24.0;
  
  /// هامش كبير جداً
  static const double marginXL = 32.0;

  // ========== نصف أقطار الحواف (Border Radius) ==========
  
  /// نصف قطر صغير جداً
  static const double radiusXS = 4.0;
  
  /// نصف قطر صغير
  static const double radiusS = 8.0;
  
  /// نصف قطر متوسط
  static const double radiusM = 12.0;
  
  /// نصف قطر كبير
  static const double radiusL = 16.0;
  
  /// نصف قطر كبير جداً
  static const double radiusXL = 20.0;
  
  /// نصف قطر دائري كامل
  static const double radiusCircular = 999.0;

  // ========== عرض الحدود (Border Width) ==========
  
  /// حد رفيع
  static const double borderThin = 1.0;
  
  /// حد متوسط
  static const double borderMedium = 2.0;
  
  /// حد سميك
  static const double borderThick = 3.0;

  // ========== أحجام الأيقونات (Icon Sizes) ==========
  
  /// أيقونة صغيرة جداً
  static const double iconXS = 16.0;
  
  /// أيقونة صغيرة
  static const double iconS = 20.0;
  
  /// أيقونة متوسطة
  static const double iconM = 24.0;
  
  /// أيقونة كبيرة
  static const double iconL = 32.0;
  
  /// أيقونة كبيرة جداً
  static const double iconXL = 48.0;
  
  /// أيقونة ضخمة
  static const double iconXXL = 64.0;

  // ========== ارتفاعات المكونات (Component Heights) ==========
  
  /// ارتفاع زر صغير
  static const double buttonHeightS = 36.0;
  
  /// ارتفاع زر متوسط
  static const double buttonHeightM = 48.0;
  
  /// ارتفاع زر كبير
  static const double buttonHeightL = 56.0;
  
  /// ارتفاع حقل إدخال
  static const double inputHeight = 56.0;
  
  /// ارتفاع شريط التطبيق
  static const double appBarHeight = 56.0;
  
  /// ارتفاع شريط التنقل السفلي
  static const double bottomNavHeight = 64.0;
  
  /// ارتفاع البطاقة الصغيرة
  static const double cardHeightS = 80.0;
  
  /// ارتفاع البطاقة المتوسطة
  static const double cardHeightM = 120.0;
  
  /// ارتفاع البطاقة الكبيرة
  static const double cardHeightL = 160.0;

  // ========== عروض المكونات (Component Widths) ==========
  
  /// عرض الحد الأقصى للمحتوى
  static const double maxContentWidth = 600.0;
  
  /// عرض الحوار الصغير
  static const double dialogWidthS = 280.0;
  
  /// عرض الحوار المتوسط
  static const double dialogWidthM = 360.0;
  
  /// عرض الحوار الكبير
  static const double dialogWidthL = 480.0;

  // ========== الارتفاعات (Elevations) ==========
  
  /// ارتفاع منخفض
  static const double elevationLow = 2.0;
  
  /// ارتفاع متوسط
  static const double elevationMedium = 4.0;
  
  /// ارتفاع عالي
  static const double elevationHigh = 8.0;
  
  /// ارتفاع عالي جداً
  static const double elevationVeryHigh = 16.0;

  // ========== أحجام الصور (Image Sizes) ==========
  
  /// حجم صورة صغيرة
  static const double imageS = 40.0;
  
  /// حجم صورة متوسطة
  static const double imageM = 80.0;
  
  /// حجم صورة كبيرة
  static const double imageL = 120.0;
  
  /// حجم صورة كبيرة جداً
  static const double imageXL = 200.0;
  
  /// حجم صورة الأفاتار الصغيرة
  static const double avatarS = 32.0;
  
  /// حجم صورة الأفاتار المتوسطة
  static const double avatarM = 48.0;
  
  /// حجم صورة الأفاتار الكبيرة
  static const double avatarL = 64.0;

  // ========== أبعاد خاصة بالتطبيق ==========
  
  /// ارتفاع بطاقة الملخص في الصفحة الرئيسية
  static const double summaryCardHeight = 100.0;
  
  /// ارتفاع بطاقة القائمة
  static const double menuCardHeight = 120.0;
  
  /// عرض بطاقة القائمة
  static const double menuCardWidth = 160.0;
  
  /// ارتفاع بطاقة العميل
  static const double customerCardHeight = 90.0;
  
  /// ارتفاع بطاقة الدين
  static const double debtCardHeight = 100.0;
  
  /// ارتفاع شريط البحث
  static const double searchBarHeight = 48.0;
}
