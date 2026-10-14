import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/controllers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final session = authState.asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : session == null
          ? _NoSession(
              onLogin: () {
                context.go(AppRoutes.login);
              },
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 18),

                Text(
                  session.profileTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  session.role.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),

                const SizedBox(height: 28),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _ProfileRow(
                          icon: Icons.mail_outline_rounded,
                          label: 'Correo electrónico',
                          value: session.email,
                        ),
                        const Divider(),
                        _ProfileRow(
                          icon: Icons.badge_outlined,
                          label: 'Rol',
                          value: session.role.label,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: authState.isLoading
                      ? null
                      : () async {
                          await ref.read(authProvider.notifier).signOut();

                          if (!context.mounted) {
                            return;
                          }

                          context.go(AppRoutes.login);
                        },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesión'),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Los datos completos del perfil se cargarán desde la API de usuarios.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoSession extends StatelessWidget {
  const _NoSession({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 52,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 14),
            const Text(
              'No hay una sesión activa.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onLogin,
              child: const Text('Iniciar sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
