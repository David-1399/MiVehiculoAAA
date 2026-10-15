import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/api_admin_user_repository.dart';
import '../../domain/entities/admin_user.dart';
import '../../domain/repositories/admin_user_repository.dart';

final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  return ApiAdminUserRepository();
});

class AdminUsersState {
  const AdminUsersState({this.users = const [], this.selectedUserId});

  final List<AdminUser> users;
  final String? selectedUserId;

  AdminUser? get selectedUser {
    final id = selectedUserId;

    if (id == null) {
      return null;
    }

    for (final user in users) {
      if (user.id == id) {
        return user;
      }
    }

    return null;
  }

  int get total => users.length;

  int get activeCount {
    return users.where((user) => user.isActive).length;
  }

  int get ownerCount {
    return users
        .where((user) => user.isActive && user.role.name == 'owner')
        .length;
  }

  int get administratorCount {
    return users
        .where((user) => user.isActive && user.role.name == 'administrator')
        .length;
  }
}

class AdminUsersNotifier extends AsyncNotifier<AdminUsersState> {
  AdminUserRepository get _repository {
    return ref.read(adminUserRepositoryProvider);
  }

  @override
  Future<AdminUsersState> build() async {
    final users = await _repository.getAll();

    return AdminUsersState(users: users);
  }

  Future<void> refresh() async {
    final current = state.asData?.value;

    state = const AsyncLoading<AdminUsersState>();

    state = await AsyncValue.guard(() async {
      final users = await _repository.getAll();

      return AdminUsersState(
        users: users,
        selectedUserId: current?.selectedUserId,
      );
    });
  }

  Future<AdminUser> createUser({
    required String firstName,
    required String lastName,
    required String? phone,
    required String email,
    required String password,
    required String role,
  }) async {
    final created = await _repository.create(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      password: password,
      role: role,
    );

    final users = await _repository.getAll();

    state = AsyncData(
      AdminUsersState(users: users, selectedUserId: created.id),
    );

    return created;
  }

  Future<AdminUser> updateUser({
    required String id,
    required String firstName,
    required String lastName,
    required String? phone,
    required String email,
    required String role,
    String? password,
  }) async {
    final updated = await _repository.update(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      role: role,
      password: password,
    );

    final users = await _repository.getAll();

    state = AsyncData(
      AdminUsersState(users: users, selectedUserId: updated.id),
    );

    return updated;
  }

  Future<void> deactivateUser(String id) async {
    await _repository.deactivate(id);

    final users = await _repository.getAll();

    state = AsyncData(AdminUsersState(users: users, selectedUserId: id));
  }

  Future<void> activateUser(String id) async {
    await _repository.activate(id);

    final users = await _repository.getAll();

    state = AsyncData(AdminUsersState(users: users, selectedUserId: id));
  }

  void selectUser(String id) {
    final current = state.asData?.value;

    if (current == null) {
      return;
    }

    state = AsyncData(
      AdminUsersState(users: current.users, selectedUserId: id),
    );
  }
}

final adminUsersProvider =
    AsyncNotifierProvider<AdminUsersNotifier, AdminUsersState>(
      AdminUsersNotifier.new,
    );
