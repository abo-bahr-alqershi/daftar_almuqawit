// ignore_for_file: public_member_api_docs

import '../../domain/entities/qat_type.dart';
import '../../domain/repositories/qat_type_repository.dart';
import '../datasources/local/qat_type_local_datasource.dart';
import '../models/qat_type_model.dart';

class QatTypeRepositoryImpl implements QatTypeRepository {
  final QatTypeLocalDataSource local;
  QatTypeRepositoryImpl(this.local);

  QatType _fromModel(QatTypeModel m) => QatType(
        id: m.id,
        name: m.name,
        qualityGrade: m.qualityGrade,
        defaultBuyPrice: m.defaultBuyPrice,
        defaultSellPrice: m.defaultSellPrice,
        color: m.color,
        icon: m.icon,
      );

  QatTypeModel _toModel(QatType e) => QatTypeModel(
        id: e.id,
        name: e.name,
        qualityGrade: e.qualityGrade,
        defaultBuyPrice: e.defaultBuyPrice,
        defaultSellPrice: e.defaultSellPrice,
        color: e.color,
        icon: e.icon,
      );

  @override
  Future<int> add(QatType entity) => local.insert(_toModel(entity));

  @override
  Future<void> delete(int id) => local.delete(id);

  @override
  Future<List<QatType>> getAll() async => (await local.getAll()).map(_fromModel).toList();

  @override
  Future<QatType?> getById(int id) async {
    final m = await local.getById(id);
    return m == null ? null : _fromModel(m);
  }

  @override
  Future<void> update(QatType entity) => local.update(_toModel(entity));
}
