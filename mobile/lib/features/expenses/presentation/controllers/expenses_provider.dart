import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../vehicles/presentation/controllers/vehicles_provider.dart';
import '../../data/repositories/api_expense_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ApiExpenseRepository();
});

class ExpensesState {
  const ExpensesState({this.items = const [], this.loading = false});

  final List<Expense> items;
  final bool loading;

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
    final items = await _repository.getByVehicleId(vehicleId);
    state = ExpensesState(items: items);
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

    state = ExpensesState(items: items);

    return saved;
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
