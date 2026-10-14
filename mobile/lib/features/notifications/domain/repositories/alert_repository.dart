import '../entities/app_alert.dart';

abstract interface class AlertRepository {
  Future<List<AppAlert>> getAll();

  Future<int> generate();

  Future<void> markAsRead(String id);
}
