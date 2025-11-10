import 'package:bloc/bloc.dart';
import '../../../domain/usecases/base/base_usecase.dart';
import '../../../domain/usecases/qat_types/add_qat_type.dart';
import '../../../domain/usecases/qat_types/delete_qat_type.dart';
import '../../../domain/usecases/qat_types/get_qat_type_by_id.dart';
import '../../../domain/usecases/qat_types/get_qat_types.dart';
import '../../../domain/usecases/qat_types/update_qat_type.dart';
import 'qat_types_event.dart';
import 'qat_types_state.dart';

class QatTypesBloc extends Bloc<QatTypesEvent, QatTypesState> {
  final GetQatTypes getQatTypes;
  final GetQatTypeById getQatTypeById;
  final AddQatType addQatType;
  final UpdateQatType updateQatType;
  final DeleteQatType deleteQatType;

  QatTypesBloc({
    required this.getQatTypes,
    required this.getQatTypeById,
    required this.addQatType,
    required this.updateQatType,
    required this.deleteQatType,
  }) : super(QatTypesInitial()) {
    on<LoadQatTypes>(_onLoadQatTypes);
    on<LoadQatTypeById>(_onLoadQatTypeById);
    on<AddQatTypeEvent>(_onAddQatType);
    on<UpdateQatTypeEvent>(_onUpdateQatType);
    on<DeleteQatTypeEvent>(_onDeleteQatType);
    on<SearchQatTypes>(_onSearchQatTypes);
    on<FilterQatTypesByQuality>(_onFilterByQuality);
  }

  Future<void> _onLoadQatTypes(
      LoadQatTypes event, Emitter<QatTypesState> emit) async {
    try {
      emit(QatTypesLoading());
      final qatTypes = await getQatTypes(const NoParams());
      emit(QatTypesLoaded(qatTypes));
    } catch (e) {
      emit(QatTypesError('فشل تحميل أنواع القات: ${e.toString()}'));
    }
  }

  Future<void> _onLoadQatTypeById(
      LoadQatTypeById event, Emitter<QatTypesState> emit) async {
    try {
      emit(QatTypesLoading());
      final qatType = await getQatTypeById(event.id);
      if (qatType != null) {
        emit(QatTypeDetailsLoaded(qatType));
      } else {
        emit(QatTypesError('لم يتم العثور على نوع القات'));
      }
    } catch (e) {
      emit(QatTypesError('فشل تحميل نوع القات: ${e.toString()}'));
    }
  }

  /// معالج إضافة نوع قات جديد
  Future<void> _onAddQatType(
      AddQatTypeEvent event, Emitter<QatTypesState> emit) async {
    try {
      await addQatType(event.qatType);
      emit(QatTypeOperationSuccess('تم إضافة نوع القات بنجاح'));
      add(LoadQatTypes());
    } catch (e) {
      emit(QatTypesError('فشل إضافة نوع القات: ${e.toString()}'));
    }
  }

  /// معالج تحديث نوع قات
  Future<void> _onUpdateQatType(
      UpdateQatTypeEvent event, Emitter<QatTypesState> emit) async {
    try {
      await updateQatType(event.qatType);
      emit(QatTypeOperationSuccess('تم تحديث نوع القات بنجاح'));
      add(LoadQatTypes());
    } catch (e) {
      emit(QatTypesError('فشل تحديث نوع القات: ${e.toString()}'));
    }
  }

  /// معالج حذف نوع قات
  Future<void> _onDeleteQatType(
      DeleteQatTypeEvent event, Emitter<QatTypesState> emit) async {
    try {
      await deleteQatType(event.id);
      emit(QatTypeOperationSuccess('تم حذف نوع القات بنجاح'));
      add(LoadQatTypes());
    } catch (e) {
      emit(QatTypesError('فشل حذف نوع القات: ${e.toString()}'));
    }
  }

  Future<void> _onSearchQatTypes(
      SearchQatTypes event, Emitter<QatTypesState> emit) async {
    try {
      emit(QatTypesLoading());
      final allQatTypes = await getQatTypes(const NoParams());
      
      final results = allQatTypes.where((qatType) {
        return qatType.name.toLowerCase().contains(event.query.toLowerCase()) ||
            (qatType.qualityGrade?.toLowerCase().contains(event.query.toLowerCase()) ?? false);
      }).toList();
      
      emit(QatTypesSearchResults(results, event.query));
    } catch (e) {
      emit(QatTypesError('فشل البحث: ${e.toString()}'));
    }
  }

  Future<void> _onFilterByQuality(
      FilterQatTypesByQuality event, Emitter<QatTypesState> emit) async {
    try {
      emit(QatTypesLoading());
      final allQatTypes = await getQatTypes(const NoParams());
      
      final filtered = allQatTypes.where((qatType) {
        return qatType.qualityGrade == event.qualityGrade;
      }).toList();
      
      emit(QatTypesLoaded(filtered));
    } catch (e) {
      emit(QatTypesError('فشل الفلترة: ${e.toString()}'));
    }
  }
}
