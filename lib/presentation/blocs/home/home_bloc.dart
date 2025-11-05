/// Bloc إدارة الشاشة الرئيسية
/// يدير بيانات وحالة الشاشة الرئيسية

import 'package:bloc/bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../core/services/local/shared_preferences_service.dart';
import '../../../core/services/logger_service.dart';

/// Bloc الشاشة الرئيسية
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final SharedPreferencesService _prefs;
  final LoggerService _logger;
  
  HomeBloc({
    required SharedPreferencesService prefs,
    required LoggerService logger,
  })  : _prefs = prefs,
        _logger = logger,
        super(HomeInitial()) {
    on<HomeStarted>(_onHomeStarted);
    on<HomeRefreshed>(_onHomeRefreshed);
    on<HomeNavigateToSection>(_onNavigateToSection);
  }

  /// معالج بدء الشاشة الرئيسية
  Future<void> _onHomeStarted(HomeStarted event, Emitter<HomeState> emit) async {
    try {
      emit(HomeLoading());
      
      _logger.info('بدء تحميل الشاشة الرئيسية');
      
      // تحميل البيانات الأساسية
      final data = await _loadHomeData();
      
      emit(HomeLoaded(data));
      _logger.info('تم تحميل الشاشة الرئيسية بنجاح');
    } catch (e, s) {
      _logger.error('خطأ في تحميل الشاشة الرئيسية', error: e, stackTrace: s);
      emit(HomeError('فشل تحميل البيانات'));
    }
  }

  /// معالج تحديث الشاشة الرئيسية
  Future<void> _onHomeRefreshed(HomeRefreshed event, Emitter<HomeState> emit) async {
    try {
      _logger.info('تحديث الشاشة الرئيسية');
      
      final data = await _loadHomeData();
      
      emit(HomeLoaded(data));
      _logger.info('تم تحديث الشاشة الرئيسية بنجاح');
    } catch (e, s) {
      _logger.error('خطأ في تحديث الشاشة الرئيسية', error: e, stackTrace: s);
      emit(HomeError('فشل تحديث البيانات'));
    }
  }

  /// معالج الانتقال لقسم معين
  Future<void> _onNavigateToSection(
    HomeNavigateToSection event,
    Emitter<HomeState> emit,
  ) async {
    _logger.info('الانتقال إلى قسم: ${event.section}');
    // سيتم التعامل مع التنقل في طبقة UI
  }

  /// تحميل بيانات الشاشة الرئيسية
  Future<Map<String, dynamic>> _loadHomeData() async {
    // تحميل الإعدادات والبيانات الأساسية
    final language = await _prefs.getString('language') ?? 'ar';
    final theme = await _prefs.getString('theme_mode') ?? 'light';
    
    return {
      'language': language,
      'theme': theme,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
