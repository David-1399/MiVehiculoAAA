import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';

class MileagePage extends StatefulWidget {
  const MileagePage({super.key});

  @override
  State<MileagePage> createState() => _MileagePageState();
}

class _MileagePageState extends State<MileagePage> {
  final _formKey = GlobalKey<FormState>();
  final _mileageController = TextEditingController();

  @override
  void dispose() {
    _mileageController.dispose();
    super.dispose();
  }

  void _showRegisterMileageDialog() {
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

                if (mileage == null || mileage < 35000) {
                  return 'Debe ser igual o mayor a 35.000 km';
                }

                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Kilometraje actualizado a ${_mileageController.text} km.',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kilometraje actual',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '35.000 km',
                            style: TextStyle(
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

            const _MileageEntry(
              value: '35.000 km',
              date: '20 Sep 2026',
              difference: '+4.500 km',
              isLatest: true,
            ),

            const _TimelineConnector(),

            const _MileageEntry(
              value: '30.500 km',
              date: '05 Jul 2026',
              difference: '+5.500 km',
            ),

            const _TimelineConnector(),

            const _MileageEntry(
              value: '25.000 km',
              date: '12 Mar 2026',
              difference: 'Registro inicial',
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _showRegisterMileageDialog,
              icon: const Icon(Icons.add_road_rounded),
              label: const Text('Registrar nueva lectura'),
            ),
          ],
        ),
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
    return Container(
      width: 2,
      height: 20,
      margin: const EdgeInsets.only(left: 8),
      color: AppColors.border,
    );
  }
}
