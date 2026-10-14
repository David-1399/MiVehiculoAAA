import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../controllers/maintenance_provider.dart';

class MaintenanceRegisterPage extends ConsumerStatefulWidget {
  const MaintenanceRegisterPage({super.key});

  @override
  ConsumerState<MaintenanceRegisterPage> createState() {
    return _MaintenanceRegisterPageState();
  }
}

class _MaintenanceRegisterPageState
    extends ConsumerState<MaintenanceRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _mileageController = TextEditingController();

  final _costController = TextEditingController();

  final _workshopController = TextEditingController();

  final _observationsController = TextEditingController();

  final _nextMileageController = TextEditingController();

  String? _maintenanceTypeId;

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _mileageController.dispose();
    _costController.dispose();
    _workshopController.dispose();
    _observationsController.dispose();
    _nextMileageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  String get _formattedDate {
    final day = _selectedDate.day.toString().padLeft(2, '0');

    final month = _selectedDate.month.toString().padLeft(2, '0');

    return '$day/$month/${_selectedDate.year}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vehicle = ref.read(vehiclesProvider).selectedVehicle;

    if (vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Selecciona un vehículo antes de registrar el mantenimiento.',
          ),
        ),
      );
      return;
    }

    await ref
        .read(maintenanceProvider.notifier)
        .addMaintenance(
          vehicleId: vehicle.id,
          maintenanceTypeId: _maintenanceTypeId!,
          date: _selectedDate,
          mileage: int.parse(_mileageController.text),
          cost: int.parse(_costController.text),
          workshop: _workshopController.text,
          observations: _observationsController.text,
          nextMileage: _nextMileageController.text.isEmpty
              ? null
              : int.parse(_nextMileageController.text),
        );

    if (!mounted) {
      return;
    }

    context.go(AppRoutes.maintenanceDetail);
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;

    final catalogsAsync = ref.watch(catalogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar mantenimiento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (vehicle != null) ...[
                Text(
                  vehicle.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.plate,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
              ],

              catalogsAsync.when(
                data: (catalogs) {
                  final items = catalogs.activeMaintenanceTypes;

                  return DropdownButtonFormField<String>(
                    initialValue: _maintenanceTypeId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de mantenimiento',
                      prefixIcon: Icon(Icons.build_outlined),
                    ),
                    items: items
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _maintenanceTypeId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona el tipo de mantenimiento';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text(
                  'No fue posible cargar los tipos de mantenimiento.',
                  style: TextStyle(color: AppColors.error),
                ),
              ),

              if (_maintenanceTypeId != null)
                catalogsAsync.when(
                  data: (catalogs) {
                    final type = catalogs.maintenanceTypeById(
                      _maintenanceTypeId!,
                    );

                    final category = type?.attributes['category'];

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        category == 'preventive'
                            ? 'Clasificación: Preventivo'
                            : category == 'corrective'
                            ? 'Clasificación: Correctivo'
                            : '',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),

              const SizedBox(height: 16),

              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(_formattedDate),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Kilometraje',
                  suffixText: 'km',
                  prefixIcon: Icon(Icons.speed_rounded),
                ),
                validator: (value) {
                  final mileage = int.tryParse(value ?? '');

                  if (mileage == null || mileage < 0) {
                    return 'Ingresa un kilometraje válido';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Costo',
                  prefixText: r'$ ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final cost = int.tryParse(value ?? '');

                  if (cost == null || cost < 0) {
                    return 'Ingresa un costo válido';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _workshopController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Taller o proveedor',
                  prefixIcon: Icon(Icons.store_outlined),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nextMileageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Próximo kilometraje',
                  suffixText: 'km',
                  prefixIcon: Icon(Icons.event_repeat_outlined),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _observationsController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: vehicle != null && catalogsAsync.hasValue
                    ? _submit
                    : null,
                child: const Text('Guardar mantenimiento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
