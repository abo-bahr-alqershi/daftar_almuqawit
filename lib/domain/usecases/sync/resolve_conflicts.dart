// ignore_for_file: public_member_api_docs

import '../../../core/services/sync/conflict_resolver.dart';
import '../base/base_usecase.dart';

class ResolveConflicts implements UseCase<void, NoParams> {
  final ConflictResolver resolver;
  ResolveConflicts(this.resolver);
  @override
  Future<void> call(NoParams params) => resolver.resolveAll();
}
