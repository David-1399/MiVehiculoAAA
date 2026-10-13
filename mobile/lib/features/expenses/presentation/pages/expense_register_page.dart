import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
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

  String? _category;

  final _categories = const [
    'Aceite',
    'Frenos',
    'Llantas',
    'Combustible',
    'Repuestos',
    'Mantenimiento',
    'Otro',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ref
        .read(expensesProvider.notifier)
        .addExpense(
          category: _category!,
          description: _descriptionController.text.trim(),
          amount: int.parse(_amountController.text),
          date: DateTime.now(),
        );

    context.go(AppRoutes.expenses);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar gasto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Categor\u00EDa'),
                items: _categories.map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecciona una categor\u00EDa';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripci\u00F3n',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa la descripci\u00F3n';
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
                ),
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return 'Ingresa un valor v\u00E1lido';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Guardar gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
