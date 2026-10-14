import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../controllers/vehicles_provider.dart';

class VehicleEditPage extends ConsumerStatefulWidget {
  const VehicleEditPage({super.key});

  @override
  ConsumerState<VehicleEditPage> createState() {
    return _VehicleEditPageState();
  }
}

class _VehicleEditPageState extends ConsumerState<VehicleEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();

  String? _vehicleTypeId;
  String? _vehicleId;
  int? _currentMileage;

  @override
  void initState() {
    super.initState();

    final vehicle = ref.read(vehiclesProvider).selectedVehicle;

    if (vehicle != null) {
      _vehicleId = vehicle.id;
      _vehicleTypeId = vehicle.vehicleTypeId;
      _brandController.text = vehicle.brand;
      _modelController.text = vehicle.model;
      _yearController.text = vehicle.year.toString();
      _plateController.text = vehicle.plate;
      _currentMileage = vehicle.mileage;
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vehicleId = _vehicleId;
    final vehicleTypeId = _vehicleTypeId;

    if (vehicleId == null || vehicleTypeId == null) {
      return;
    }

    try {
      ref
          .read(vehiclesProvider.notifier)
          .updateVehicle(
            vehicleId: vehicleId,
            vehicleTypeId: vehicleTypeId,
            brand: _brandController.text,
            model: _modelController.text,
            year: int.parse(_yearController.text),
            plate: _plateController.text,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehículo actualizado correctamente.')),
      );

      context.go(AppRoutes.vehicleDetail);
    } on ArgumentError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message?.toString() ??
                'No fue posible actualizar el vehículo.',
          ),
        ),
      );
    } on StateError catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;

    final catalogsAsync = ref.watch(catalogsProvider);

    if (vehicle == null || _vehicleId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar vehículo')),
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go(AppRoutes.vehicles);
            },
            child: const Text('Volver a mis vehículos'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Cancelar',
          onPressed: () {
            context.go(AppRoutes.vehicleDetail);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Editar vehículo'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Información del vehículo',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Actualiza los datos principales del vehículo.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                catalogsAsync.when(
                  data: (catalogs) {
                    final items = catalogs.activeVehicleTypes;

                    final selectedId =
                        items.any((item) => item.id == _vehicleTypeId)
                        ? _vehicleTypeId
                        : null;

                    return DropdownButtonFormField<String>(
                      initialValue: selectedId,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de vehículo',
                        prefixIcon: Icon(Icons.category_outlined),
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
                          _vehicleTypeId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecciona el tipo de vehículo';
                        }

                        return null;
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const Text(
                    'No fue posible cargar los tipos de vehículo.',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _brandController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Marca',
                    prefixIcon: Icon(Icons.factory_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa la marca';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _modelController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Modelo',
                    prefixIcon: Icon(Icons.directions_car_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el modelo';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Año',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  validator: (value) {
                    final year = int.tryParse(value ?? '');

                    final maxYear = DateTime.now().year + 1;

                    if (year == null || year < 1900 || year > maxYear) {
                      return 'Ingresa un año válido';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  decoration: const InputDecoration(
                    labelText: 'Placa',
                    prefixIcon: Icon(Icons.pin_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 5) {
                      return 'Ingresa una placa válida';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Kilometraje actual',
                    prefixIcon: Icon(Icons.speed_rounded),
                    suffixText: 'km',
                  ),
                  child: Text((_currentMileage ?? vehicle.mileage).toString()),
                ),

                const SizedBox(height: 8),

                const Text(
                  'El kilometraje se actualiza desde su módulo para conservar el historial de lecturas.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 28),

                FilledButton(
                  onPressed: catalogsAsync.hasValue ? _submit : null,
                  child: const Text('Guardar cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
