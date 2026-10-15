import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../../core/network/api_exception.dart';
import '../controllers/maintenance_provider.dart';

class MaintenanceEditPage extends ConsumerStatefulWidget {
  const MaintenanceEditPage({super.key});

  @override
  ConsumerState<MaintenanceEditPage> createState() {
    return _MaintenanceEditPageState();
  }
}

class _MaintenanceEditPageState extends ConsumerState<MaintenanceEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _mileageController = TextEditingController();
  final _costController = TextEditingController();
  final _workshopController = TextEditingController();
  final _observationsController = TextEditingController();
  final _nextMileageController = TextEditingController();

  String? _maintenanceTypeId;
  DateTime _date = DateTime.now();
  DateTime? _nextDate;

  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _mileageController.dispose();
    _costController.dispose();
    _workshopController.dispose();
    _observationsController.dispose();
    _nextMileageController.dispose();
    super.dispose();
  }

  void _initialize() {
    if (_initialized) {
      return;
    }

    final current = ref.read(maintenanceProvider).selectedMaintenance;

    if (current == null) {
      return;
    }

    _maintenanceTypeId = current.maintenanceTypeId;
    _date = current.date;
    _nextDate = current.nextDate;
    _mileageController.text = current.mileage.toString();
    _costController.text = current.cost.toString();
    _workshopController.text = current.workshop ?? '';
    _observationsController.text = current.observations ?? '';
    _nextMileageController.text = current.nextMileage?.toString() ?? '';

    _initialized = true;
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected != null && mounted) {
      setState(() {
        _date = selected;
      });
    }
  }

  Future<void> _pickNextDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _nextDate ?? _date.add(const Duration(days: 90)),
      firstDate: _date,
      lastDate: DateTime(2100),
    );

    if (selected != null && mounted) {
      setState(() {
        _nextDate = selected;
      });
    }
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    final current = ref.read(maintenanceProvider).selectedMaintenance;

    if (current == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await ref
          .read(maintenanceProvider.notifier)
          .updateMaintenance(
            current: current,
            maintenanceTypeId: _maintenanceTypeId!,
            date: _date,
            mileage: int.parse(_mileageController.text),
            cost: int.parse(_costController.text),
            workshop: _workshopController.text,
            observations: _observationsController.text,
            nextMileage: int.tryParse(_nextMileageController.text.trim()),
            nextDate: _nextDate,
          );

      if (!mounted) {
        return;
      }

      context.go(AppRoutes.maintenanceDetail);
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

    final current = ref.watch(maintenanceProvider).selectedMaintenance;
    final catalogsAsync = ref.watch(catalogsProvider);

    if (current == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar mantenimiento')),
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go(AppRoutes.maintenance);
            },
            child: const Text('Volver a mantenimientos'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al detalle',
          onPressed: _saving
              ? null
              : () {
                  context.go(AppRoutes.maintenanceDetail);
                },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Editar mantenimiento'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              catalogsAsync.when(
                data: (catalogs) {
                  return DropdownButtonFormField<String>(
                    initialValue: _maintenanceTypeId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de mantenimiento',
                    ),
                    items: catalogs.activeMaintenanceTypes
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _maintenanceTypeId = value;
                            });
                          },
                    validator: (value) {
                      return value == null || value.isEmpty
                          ? 'Selecciona el tipo'
                          : null;
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text(
                  'No fue posible cargar los tipos de mantenimiento.',
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha'),
                subtitle: Text(_formatDate(_date)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _saving ? null : _pickDate,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mileageController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Kilometraje',
                  suffixText: 'km',
                ),
                validator: (value) {
                  final mileage = int.tryParse(value ?? '');

                  return mileage == null || mileage < 0
                      ? 'Ingresa un kilometraje válido'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Costo',
                  prefixText: r'$ ',
                ),
                validator: (value) {
                  final cost = int.tryParse(value ?? '');

                  return cost == null || cost < 0
                      ? 'Ingresa un costo válido'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workshopController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Taller'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _observationsController,
                enabled: !_saving,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Observaciones'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nextMileageController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Próximo kilometraje',
                  suffixText: 'km',
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Próxima fecha'),
                subtitle: Text(
                  _nextDate == null
                      ? 'Sin fecha programada'
                      : _formatDate(_nextDate!),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_nextDate != null)
                      IconButton(
                        tooltip: 'Quitar fecha',
                        onPressed: _saving
                            ? null
                            : () {
                                setState(() {
                                  _nextDate = null;
                                });
                              },
                        icon: const Icon(Icons.clear_rounded),
                      ),
                    const Icon(Icons.calendar_today_outlined),
                  ],
                ),
                onTap: _saving ? null : _pickNextDate,
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: !_saving && catalogsAsync.hasValue
                      ? _submit
                      : null,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
