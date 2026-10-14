import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../../core/evidence/evidence_upload_service.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/evidence_camera_field.dart';
import '../controllers/expenses_provider.dart';

class ExpenseEditPage extends ConsumerStatefulWidget {
  const ExpenseEditPage({super.key});

  @override
  ConsumerState<ExpenseEditPage> createState() {
    return _ExpenseEditPageState();
  }
}

class _ExpenseEditPageState extends ConsumerState<ExpenseEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _uploadService = EvidenceUploadService();

  String? _expenseCategoryId;
  DateTime _selectedDate = DateTime.now();

  String? _newEvidenceLocalPath;
  bool _removeEvidence = false;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _initialize() {
    if (_initialized) {
      return;
    }

    final expense = ref.read(expensesProvider).selectedExpense;

    if (expense == null) {
      return;
    }

    _expenseCategoryId = expense.expenseCategoryId;
    _descriptionController.text = expense.description;
    _amountController.text = expense.amount.toString();
    _selectedDate = expense.date;
    _initialized = true;
  }

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedDate = result;
      });
    }
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    final current = ref.read(expensesProvider).selectedExpense;

    if (current == null) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      String? evidencePath = current.evidencePath;

      if (_removeEvidence) {
        evidencePath = null;
      }

      if (_newEvidenceLocalPath != null) {
        evidencePath = await _uploadService.uploadImage(_newEvidenceLocalPath!);
      }

      await ref
          .read(expensesProvider.notifier)
          .updateExpense(
            current: current,
            expenseCategoryId: _expenseCategoryId!,
            description: _descriptionController.text,
            amount: int.parse(_amountController.text),
            date: _selectedDate,
            evidencePath: evidencePath,
            clearEvidencePath: _removeEvidence && _newEvidenceLocalPath == null,
          );

      if (!mounted) {
        return;
      }

      context.go(AppRoutes.expenseDetail);
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

    final expense = ref.watch(expensesProvider).selectedExpense;
    final catalogsAsync = ref.watch(catalogsProvider);

    if (expense == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar gasto')),
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

    final evidencePath =
        _newEvidenceLocalPath ??
        (_removeEvidence ? null : expense.evidencePath);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar gasto')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              catalogsAsync.when(
                data: (catalogs) {
                  return DropdownButtonFormField<String>(
                    initialValue: _expenseCategoryId,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: catalogs.activeExpenseCategories
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _expenseCategoryId = value;
                            });
                          },
                    validator: (value) {
                      return value == null || value.isEmpty
                          ? 'Selecciona la categoría'
                          : null;
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, _) =>
                    const Text('No fue posible cargar las categorías.'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  return value == null || value.trim().isEmpty
                      ? 'Ingresa una descripción'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: r'$ ',
                ),
                validator: (value) {
                  final amount = int.tryParse(value ?? '');

                  return amount == null || amount <= 0
                      ? 'Ingresa un valor mayor a cero'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha'),
                subtitle: Text(_date(_selectedDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _saving ? null : _pickDate,
              ),
              const SizedBox(height: 20),
              const Text(
                'Soporte fotográfico',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              EvidenceCameraField(
                filePath: evidencePath,
                enabled: !_saving,
                onChanged: (value) {
                  setState(() {
                    if (value == null) {
                      _newEvidenceLocalPath = null;
                      _removeEvidence = true;
                    } else {
                      _newEvidenceLocalPath = value;
                      _removeEvidence = false;
                    }
                  });
                },
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: !_saving && catalogsAsync.hasValue ? _submit : null,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
