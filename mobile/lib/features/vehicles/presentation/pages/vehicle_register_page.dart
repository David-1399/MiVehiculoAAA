import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../controllers/vehicles_provider.dart';

class VehicleRegisterPage extends ConsumerStatefulWidget {
  const VehicleRegisterPage({super.key});

  @override
  ConsumerState<VehicleRegisterPage> createState() {
    return _VehicleRegisterPageState();
  }
}

class _VehicleRegisterPageState extends ConsumerState<VehicleRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _mileageController = TextEditingController();

  String? _vehicleTypeId;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref
        .read(vehiclesProvider.notifier)
        .addVehicle(
          vehicleTypeId: _vehicleTypeId!,
          brand: _brandController.text,
          model: _modelController.text,
          year: int.parse(_yearController.text),
          plate: _plateController.text,
          mileage: int.parse(_mileageController.text),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehículo registrado correctamente.')),
    );

    context.go(AppRoutes.vehicleDetail);
  }

  @override
  Widget build(BuildContext context) {
    final catalogsAsync = ref.watch(catalogsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Cancelar',
          onPressed: () {
            context.go(AppRoutes.vehicles);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Registrar vehículo'),
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
                  'Datos del vehículo',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ingresa la información principal del vehículo.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                catalogsAsync.when(
                  data: (catalogs) {
                    final items = catalogs.activeVehicleTypes;

                    return DropdownButtonFormField<String>(
                      initialValue: _vehicleTypeId,
                      isExpanded: true,
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

                    if (year == null || year < 1900 || year > 2100) {
                      return 'Ingresa un año válido';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
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

                const SizedBox(height: 24),

                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'La cámara se habilitará con el módulo de evidencias.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Agregar fotografía'),
                ),

                const SizedBox(height: 16),

                FilledButton(
                  onPressed: catalogsAsync.hasValue ? _submit : null,
                  child: const Text('Guardar vehículo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
