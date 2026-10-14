import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../controllers/expenses_provider.dart';

class ExpenseRegisterPage extends ConsumerStatefulWidget {
  const ExpenseRegisterPage({super.key});

  @override
  ConsumerState<ExpenseRegisterPage> createState() {
    return _ExpenseRegisterPageState();
  }
}

class _ExpenseRegisterPageState extends ConsumerState<ExpenseRegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();

  final _amountController = TextEditingController();

  String? _expenseCategoryId;

  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');

    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }

  Future<void> _selectDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vehicle = ref.read(vehiclesProvider).selectedVehicle;

    if (vehicle == null) {
      return;
    }

    await ref
        .read(expensesProvider.notifier)
        .addExpense(
          vehicleId: vehicle.id,
          expenseCategoryId: _expenseCategoryId!,
          description: _descriptionController.text,
          amount: int.parse(_amountController.text),
          date: _selectedDate,
        );

    if (!mounted) {
      return;
    }

    context.go(AppRoutes.expenses);
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;

    final catalogsAsync = ref.watch(catalogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar gasto')),
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
                  return DropdownButtonFormField<String>(
                    initialValue: _expenseCategoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: catalogs.activeExpenseCategories
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _expenseCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selecciona la categoría';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const Text(
                  'No fue posible cargar las categorías de gasto.',
                  style: TextStyle(color: AppColors.error),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Describe el gasto',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa una descripción';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: r'$ ',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final amount = int.tryParse(value ?? '');

                  if (amount == null || amount <= 0) {
                    return 'Ingresa un valor mayor a cero';
                  }

                  return null;
                },
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
                  child: Text(_date(_selectedDate)),
                ),
              ),

              const SizedBox(height: 28),

              FilledButton(
                onPressed: vehicle != null && catalogsAsync.hasValue
                    ? _submit
                    : null,
                child: const Text('Guardar gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
