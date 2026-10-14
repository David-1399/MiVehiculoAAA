import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../../core/widgets/evidence_image_preview.dart';
import '../controllers/expenses_provider.dart';

class ExpenseDetailPage extends ConsumerWidget {
  const ExpenseDetailPage({super.key});

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
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expense = ref.watch(expensesProvider).selectedExpense;
    final catalogs = ref.watch(catalogsProvider).asData?.value;

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del gasto')),
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go(AppRoutes.expenses);
            },
            child: const Text('Volver a gastos'),
          ),
        ),
      );
    }

    final category =
        catalogs?.expenseCategoryById(expense.expenseCategoryId)?.name ??
        'Categoría no disponible';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go(AppRoutes.expenses);
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Detalle del gasto'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            onPressed: () {
              context.push(AppRoutes.expenseEdit);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.description,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Divider(height: 26),
                  _Row(label: 'Categoría', value: category),
                  _Row(label: 'Fecha', value: _date(expense.date)),
                  _Row(label: 'Valor', value: _money(expense.amount)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Soporte fotográfico',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          if (expense.evidencePath == null)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.no_photography_outlined,
                      color: AppColors.textSecondary,
                      size: 36,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Este gasto no tiene una fotografía adjunta.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            EvidenceImagePreview(path: expense.evidencePath!),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              context.push(AppRoutes.expenseEdit);
            },
            icon: const Icon(Icons.edit_outlined),
            label: Text(
              expense.evidencePath == null
                  ? 'Editar y agregar fotografía'
                  : 'Editar gasto',
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
