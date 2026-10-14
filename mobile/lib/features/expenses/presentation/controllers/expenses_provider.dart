import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../../data/repositories/api_expense_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ApiExpenseRepository();
});

class ExpensesState {
  const ExpensesState({
    this.items = const [],
    this.selectedExpenseId,
    this.loading = false,
  });

  final List<Expense> items;
  final String? selectedExpenseId;
  final bool loading;

  Expense? get selectedExpense {
    final id = selectedExpenseId;

    if (id == null) {
      return null;
    }

    for (final item in items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  List<Expense> forVehicle(String vehicleId) {
    final result = items.where((item) => item.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  int totalForVehicle(String vehicleId) {
    return forVehicle(vehicleId)
        .fold<int>(0, (total, expense) => total + expense.amount);
  }
}

class ExpensesNotifier extends Notifier<ExpensesState> {
  ExpenseRepository get _repository {
    return ref.read(expenseRepositoryProvider);
  }

  @override
  ExpensesState build() {
    final vehicleId = ref.watch(
      vehiclesProvider.select((state) => state.selectedVehicleId),
    );

    if (vehicleId != null) {
      Future<void>.microtask(() => refresh(vehicleId));
    }

    return const ExpensesState(loading: true);
  }

  Future<void> refresh(String vehicleId) async {
    final selectedId = state.selectedExpenseId;
    final items = await _repository.getByVehicleId(vehicleId);

    state = ExpensesState(items: items, selectedExpenseId: selectedId);
  }

  Future<Expense> addExpense({
    required String vehicleId,
    required String expenseCategoryId,
    required String description,
    required int amount,
    required DateTime date,
    String? maintenanceId,
    String? evidencePath,
  }) async {
    final now = DateTime.now();

    final expense = Expense(
      id: '',
      vehicleId: vehicleId,
      expenseCategoryId: expenseCategoryId,
      description: description.trim(),
      amount: amount,
      date: date,
      maintenanceId: _nullableText(maintenanceId),
      evidencePath: _nullableText(evidencePath),
      createdAt: now,
      updatedAt: now,
    );

    final saved = await _repository.create(expense);
    final items = await _repository.getByVehicleId(vehicleId);

    state = ExpensesState(items: items, selectedExpenseId: saved.id);

    return saved;
  }

  Future<Expense> updateExpense({
    required Expense current,
    required String expenseCategoryId,
    required String description,
    required int amount,
    required DateTime date,
    String? evidencePath,
    bool clearEvidencePath = false,
  }) async {
    final updated = current.copyWith(
      expenseCategoryId: expenseCategoryId,
      description: description.trim(),
      amount: amount,
      date: date,
      evidencePath: _nullableText(evidencePath),
      clearEvidencePath: clearEvidencePath,
      updatedAt: DateTime.now(),
    );

    final saved = await _repository.update(updated);
    final items = await _repository.getByVehicleId(current.vehicleId);

    state = ExpensesState(items: items, selectedExpenseId: saved.id);

    return saved;
  }

  void selectExpense(String id) {
    state = ExpensesState(items: state.items, selectedExpenseId: id);
  }

  Future<void> deleteExpense(String id) async {
    final vehicleId = ref.read(vehiclesProvider).selectedVehicleId;

    await _repository.delete(id);

    if (vehicleId == null) {
      state = const ExpensesState();
      return;
    }

    final items = await _repository.getByVehicleId(vehicleId);
    state = ExpensesState(items: items);
  }

  String? _nullableText(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}

final expensesProvider = NotifierProvider<ExpensesNotifier, ExpensesState>(
  ExpensesNotifier.new,
);
