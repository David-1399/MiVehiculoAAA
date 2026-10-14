import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_upcoming_maintenance_repository.dart';
import '../../domain/entities/upcoming_maintenance.dart';
import '../../domain/repositories/upcoming_maintenance_repository.dart';

final upcomingMaintenanceRepositoryProvider =
    Provider<UpcomingMaintenanceRepository>((ref) {
      return ApiUpcomingMaintenanceRepository();
    });

class UpcomingMaintenanceNotifier extends Notifier<List<UpcomingMaintenance>> {
  UpcomingMaintenanceRepository get _repository {
    return ref.read(upcomingMaintenanceRepositoryProvider);
  }

  @override
  List<UpcomingMaintenance> build() {
    Future<void>.microtask(refresh);
    return const [];
  }

  Future<void> refresh() async {
    state = List.unmodifiable(await _repository.getUpcoming());
  }
}

final upcomingMaintenanceProvider =
    NotifierProvider<UpcomingMaintenanceNotifier, List<UpcomingMaintenance>>(
      UpcomingMaintenanceNotifier.new,
    );
