import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../controllers/expenses_provider.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  String _money(int value) {
    final text = value.toString();
    final result = StringBuffer();

    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        result.write('.');
      }

      result.write(text[i]);
    }

    return '\$${result.toString()}';
  }

  String _date(DateTime value) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref.watch(vehiclesProvider).selectedVehicle;
    final expensesState = ref.watch(expensesProvider);
    final catalogs = ref.watch(catalogsProvider).asData?.value;

    if (vehicle == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gastos')),
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

    final expenses = expensesState.forVehicle(vehicle.id);
    final total = expensesState.totalForVehicle(vehicle.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver al vehículo',
          onPressed: () {
            context.go(AppRoutes.vehicleDetail);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Gastos'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          context.push(AppRoutes.expenseRegister);
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            vehicle.displayName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            vehicle.plate,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
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
                      Icons.payments_outlined,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total registrado',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _money(total),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Historial',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  context.push(AppRoutes.expenseRegister);
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Registrar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (expenses.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 44,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No hay gastos registrados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else
            ...expenses.map((expense) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    onTap: () {
                      ref
                          .read(expensesProvider.notifier)
                          .selectExpense(expense.id);

                      context.push(AppRoutes.expenseDetail);
                    },
                    leading: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        expense.evidencePath == null
                            ? Icons.receipt_long_outlined
                            : Icons.photo_camera_outlined,
                        color: AppColors.secondary,
                      ),
                    ),
                    title: Text(
                      expense.description,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${catalogs?.expenseCategoryById(expense.expenseCategoryId)?.name ?? 'Categoría no disponible'} · ${_date(expense.date)}',
                    ),
                    trailing: Text(
                      _money(expense.amount),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              context.push(AppRoutes.expenseRegister);
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Registrar gasto'),
          ),
        ],
      ),
    );
  }
}
