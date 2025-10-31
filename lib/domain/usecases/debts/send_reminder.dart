// ignore_for_file: public_member_api_docs

import '../../repositories/debt_repository.dart';
import '../../../core/services/notification_service.dart';
import '../base/base_usecase.dart';

class SendReminder implements UseCase<void, int> {
  final NotificationService notifications;
  final DebtRepository repo;
  SendReminder(this.notifications, this.repo);
  @override
  Future<void> call(int debtId) async {
    // يمكن لاحقاً جلب معلومات الدين قبل الإرسال
    await notifications.sendDebtReminder(debtId);
  }
}
