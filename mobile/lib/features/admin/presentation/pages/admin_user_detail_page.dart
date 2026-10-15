import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';
import '../controllers/admin_users_provider.dart';

class AdminUserDetailPage extends ConsumerWidget {
  const AdminUserDetailPage({super.key});

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver a usuarios',
          onPressed: () {
            context.go(AppRoutes.adminUsers);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Detalle del usuario'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            onPressed: usersAsync.asData?.value.selectedUser == null
                ? null
                : () {
                    context.push(AppRoutes.adminUserEdit);
                  },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: usersAsync.when(
        data: (state) {
          final user = state.selectedUser;

          if (user == null) {
            return Center(
              child: FilledButton(
                onPressed: () {
                  context.go(AppRoutes.adminUsers);
                },
                child: const Text('Volver a usuarios'),
              ),
            );
          }

          final currentSession = ref.watch(authProvider).asData?.value;
          final isSelf = currentSession?.userId == user.id;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 44,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.role.label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _Row(label: 'Correo', value: user.email),
                      const Divider(),
                      _Row(
                        label: 'Teléfono',
                        value: user.phone ?? 'No registrado',
                      ),
                      const Divider(),
                      _Row(
                        label: 'Estado',
                        value: user.isActive ? 'Activo' : 'Inactivo',
                      ),
                      const Divider(),
                      _Row(label: 'Creación', value: _date(user.createdAt)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  context.push(AppRoutes.adminUserEdit);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar usuario'),
              ),
              const SizedBox(height: 10),
              if (!user.isActive)
                FilledButton.icon(
                  onPressed: () async {
                    final confirmed =
                        await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Reactivar usuario'),
                              content: Text(
                                '¿Deseas reactivar a ${user.fullName}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(false);
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(true);
                                  },
                                  child: const Text('Reactivar'),
                                ),
                              ],
                            );
                          },
                        ) ??
                        false;

                    if (!confirmed || !context.mounted) {
                      return;
                    }

                    try {
                      await ref
                          .read(adminUsersProvider.notifier)
                          .activateUser(user.id);

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuario reactivado correctamente.'),
                        ),
                      );
                    } on ApiException catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(error.message)));
                    }
                  },
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Reactivar usuario'),
                ),
              if (!user.isActive) const SizedBox(height: 10),
              if (user.isActive)
                OutlinedButton.icon(
                  onPressed: isSelf
                      ? null
                      : () async {
                          final confirmed =
                              await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Desactivar usuario'),
                                    content: Text(
                                      '¿Deseas desactivar a ${user.fullName}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext)
                                              .pop(false);
                                        },
                                        child: const Text('Cancelar'),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop(true);
                                        },
                                        child: const Text('Desactivar'),
                                      ),
                                    ],
                                  );
                                },
                              ) ??
                              false;

                          if (!confirmed || !context.mounted) {
                            return;
                          }

                          try {
                            await ref
                                .read(adminUsersProvider.notifier)
                                .deactivateUser(user.id);

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Usuario desactivado correctamente.',
                                ),
                              ),
                            );
                          } on ApiException catch (error) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.message)),
                            );
                          }
                        },
                  icon: const Icon(Icons.person_off_outlined),
                  label: Text(
                    isSelf
                        ? 'No puedes desactivar tu cuenta'
                        : 'Desactivar usuario',
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
