import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../controllers/admin_users_provider.dart';

class AdminUserEditPage extends ConsumerStatefulWidget {
  const AdminUserEditPage({super.key});

  @override
  ConsumerState<AdminUserEditPage> createState() {
    return _AdminUserEditPageState();
  }
}

class _AdminUserEditPageState extends ConsumerState<AdminUserEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _role = UserRole.owner;
  bool _initialized = false;
  bool _saving = false;
  bool _obscure = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _initialize() {
    if (_initialized) {
      return;
    }

    final user = ref.read(adminUsersProvider).asData?.value.selectedUser;

    if (user == null) {
      return;
    }

    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _phoneController.text = user.phone ?? '';
    _emailController.text = user.email;
    _role = user.role;
    _initialized = true;
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    final current = ref.read(adminUsersProvider).asData?.value.selectedUser;

    if (current == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await ref
          .read(adminUsersProvider.notifier)
          .updateUser(
            id: current.id,
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            phone: _phoneController.text,
            email: _emailController.text,
            role: _role.code,
            password: _passwordController.text.trim().isEmpty
                ? null
                : _passwordController.text,
          );

      if (!mounted) {
        return;
      }

      context.go(AppRoutes.adminUserDetail);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialize();

    final current = ref.watch(adminUsersProvider).asData?.value.selectedUser;

    if (current == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Volver al detalle',
            onPressed: _saving
                ? null
                : () {
                    context.go(AppRoutes.adminUserDetail);
                  },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: const Text('Editar usuario'),
        ),
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go(AppRoutes.adminUsers);
            },
            child: const Text('Volver a usuarios'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _lastNameController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                enabled: !_saving,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                enabled: !_saving,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                validator: _emailValidator,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: UserRole.values
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.label),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _role = value;
                          });
                        }
                      },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                enabled: !_saving,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña (opcional)',
                  helperText:
                      'Déjala vacía para conservar la contraseña actual.',
                  suffixIcon: IconButton(
                    onPressed: _saving
                        ? null
                        : () {
                            setState(() {
                              _obscure = !_obscure;
                            });
                          },
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar cambios'),
                ),
              ),
              if (!current.isActive) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _saving
                        ? null
                        : () async {
                            final confirmed =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (dialogContext) {
                                    return AlertDialog(
                                      title: const Text('Reactivar usuario'),
                                      content: const Text(
                                        '¿Deseas volver a activar este usuario?',
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
                                            Navigator.of(dialogContext)
                                                .pop(true);
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

                            setState(() {
                              _saving = true;
                            });

                            try {
                              await ref
                                  .read(adminUsersProvider.notifier)
                                  .activateUser(current.id);

                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Usuario reactivado correctamente.',
                                  ),
                                ),
                              );

                              context.go(AppRoutes.adminUserDetail);
                            } on ApiException catch (error) {
                              if (!context.mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(error.message)),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _saving = false;
                                });
                              }
                            }
                          },
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('Reactivar este usuario'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? 'Campo obligatorio' : null;
  }

  String? _emailValidator(String? value) {
    final normalized = value?.trim() ?? '';

    if (normalized.isEmpty) {
      return 'Ingresa el correo';
    }

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    return regex.hasMatch(normalized) ? null : 'Correo no válido';
  }
}
