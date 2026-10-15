import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';
import '../controllers/admin_users_provider.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() {
    return _AdminUsersPageState();
  }
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final _searchController = TextEditingController();

  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authProvider).asData?.value;

    if (session?.role != UserRole.administrator) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gestión de usuarios')),
        body: const Center(
          child: Text('Acceso exclusivo para administradores.'),
        ),
      );
    }

    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de usuarios')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push(AppRoutes.adminUserRegister);
        },
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return ref.read(adminUsersProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o correo',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value.trim().toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            usersAsync.when(
              data: (state) {
                final filtered = state.users.where((user) {
                  if (_search.isEmpty) {
                    return true;
                  }

                  return user.fullName.toLowerCase().contains(_search) ||
                      user.email.toLowerCase().contains(_search);
                }).toList();

                if (filtered.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(child: Text('No se encontraron usuarios.')),
                  );
                }

                return Column(
                  children: filtered.map((user) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          onTap: () {
                            ref
                                .read(adminUsersProvider.notifier)
                                .selectUser(user.id);

                            context.push(AppRoutes.adminUserDetail);
                          },
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.10,
                            ),
                            child: Icon(
                              user.role == UserRole.administrator
                                  ? Icons.admin_panel_settings_outlined
                                  : Icons.person_outline_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            user.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${user.email}\n${user.role.label}'),
                          isThreeLine: true,
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (user.isActive
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              user.isActive ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                color: user.isActive
                                    ? AppColors.success
                                    : AppColors.error,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Text('No fue posible cargar usuarios: $error'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          ref.read(adminUsersProvider.notifier).refresh();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
