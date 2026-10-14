import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/in_memory_expense_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return InMemoryExpenseRepository();
});

class ExpensesState {
  const ExpensesState({this.items = const []});

  final List<Expense> items;

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
    return ExpensesState(items: _repository.getAll());
  }

  Expense addExpense({
    required String vehicleId,
    required String expenseCategoryId,
    required String description,
    required int amount,
    required DateTime date,
    String? maintenanceId,
    String? evidencePath,
  }) {
    final now = DateTime.now();

    final expense = Expense(
      id: now.microsecondsSinceEpoch.toString(),
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

    _repository.create(expense);

    state = ExpensesState(items: _repository.getAll());

    return expense;
  }

  void deleteExpense(String id) {
    _repository.delete(id);

    state = ExpensesState(items: _repository.getAll());
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
