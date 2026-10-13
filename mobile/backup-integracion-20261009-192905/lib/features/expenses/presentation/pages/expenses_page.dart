import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

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
        title: const Text('Gastos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total acumulado',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      r'$1.250.000',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Toyota Corolla · ABC123',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Resumen por categoría',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            const _ExpenseCategory(
              icon: Icons.oil_barrel_outlined,
              title: 'Aceite y lubricantes',
              value: r'$380.000',
            ),

            const SizedBox(height: 10),

            const _ExpenseCategory(
              icon: Icons.disc_full_outlined,
              title: 'Frenos',
              value: r'$320.000',
            ),

            const SizedBox(height: 10),

            const _ExpenseCategory(
              icon: Icons.tire_repair_outlined,
              title: 'Llantas',
              value: r'$550.000',
            ),

            const SizedBox(height: 24),

            Text(
              'Últimos gastos',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 12),

            const _ExpenseEntry(
              title: 'Cambio de aceite',
              date: '20 Sep 2026',
              value: r'$180.000',
            ),

            const SizedBox(height: 10),

            const _ExpenseEntry(
              title: 'Pastillas de freno',
              date: '05 Jul 2026',
              value: r'$320.000',
            ),

            const SizedBox(height: 10),

            const _ExpenseEntry(
              title: 'Llantas',
              date: '10 May 2026',
              value: r'$550.000',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseCategory extends StatelessWidget {
  const _ExpenseCategory({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ExpenseEntry extends StatelessWidget {
  const _ExpenseEntry({
    required this.title,
    required this.date,
    required this.value,
  });

  final String title;
  final String date;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
