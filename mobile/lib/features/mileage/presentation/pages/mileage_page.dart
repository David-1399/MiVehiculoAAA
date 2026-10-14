import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../controllers/mileage_provider.dart';

class MileagePage extends ConsumerStatefulWidget {
  const MileagePage({super.key});

  @override
  ConsumerState<MileagePage> createState() {
    return _MileagePageState();
  }
}

class _MileagePageState extends ConsumerState<MileagePage> {
  final _formKey = GlobalKey<FormState>();

  final _mileageController = TextEditingController();

  @override
  void dispose() {
    _mileageController.dispose();
    super.dispose();
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final result = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        result.write('.');
      }

      result.write(text[i]);
    }

    return result.toString();
  }

  String _formatDate(DateTime value) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  void _showRegisterMileageDialog() {
    final vehicle = ref.read(vehiclesProvider).selectedVehicle;

    if (vehicle == null) {
      return;
    }

    _mileageController.clear();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Registrar kilometraje'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _mileageController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Kilometraje actual',
                suffixText: 'km',
                prefixIcon: Icon(Icons.speed_rounded),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa el kilometraje';
                }

                final mileage = int.tryParse(value);

                if (mileage == null) {
                  return 'Ingresa un kilometraje válido';
                }

                if (mileage < vehicle.mileage) {
                  return 'Debe ser igual o mayor a ${_formatNumber(vehicle.mileage)} km';
                }

                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                final newMileage = int.parse(_mileageController.text);

                await ref
                    .read(mileageProvider.notifier)
                    .addReading(vehicleId: vehicle.id, mileage: newMileage);

                ref
                    .read(vehiclesProvider.notifier)
                    .updateMileage(vehicleId: vehicle.id, mileage: newMileage);

                if (!mounted) {
                  return;
                }

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Kilometraje actualizado a ${_formatNumber(newMileage)} km.',
                    ),
                  ),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;

    final mileageState = ref.watch(mileageProvider);

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kilometraje')),
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go(AppRoutes.vehicles);
            },
            child: const Text('Seleccionar vehículo'),
          ),
        ),
      );
    }

    final readings = mileageState.forVehicle(vehicle.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al vehículo',
          onPressed: () {
            context.go(AppRoutes.vehicleDetail);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Kilometraje'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _showRegisterMileageDialog,
        child: const Icon(Icons.add_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            vehicle.displayName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            vehicle.plate,
            style: const TextStyle(color: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.speed_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kilometraje actual',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatNumber(vehicle.mileage)} km',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Historial de lecturas',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 12),

          if (readings.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.speed_outlined,
                      size: 42,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No hay lecturas adicionales registradas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'El kilometraje inicial corresponde al registrado con el vehículo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            for (var i = 0; i < readings.length; i++) ...[
              _MileageEntry(
                value: '${_formatNumber(readings[i].mileage)} km',
                date: _formatDate(readings[i].recordedAt),
                difference: i < readings.length - 1
                    ? '+${_formatNumber(readings[i].mileage - readings[i + 1].mileage)} km'
                    : 'Lectura registrada',
                isLatest: i == 0,
              ),
              if (i < readings.length - 1) const _TimelineConnector(),
            ],

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: _showRegisterMileageDialog,
            icon: const Icon(Icons.add_road_rounded),
            label: const Text('Registrar nueva lectura'),
          ),
        ],
      ),
    );
  }
}

class _MileageEntry extends StatelessWidget {
  const _MileageEntry({
    required this.value,
    required this.date,
    required this.difference,
    this.isLatest = false,
  });

  final String value;
  final String date;
  final String difference;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: isLatest ? AppColors.primary : AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    difference,
                    style: TextStyle(
                      color: isLatest
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 2,
        height: 20,
        margin: const EdgeInsets.only(left: 8),
        color: AppColors.border,
      ),
    );
  }
}
