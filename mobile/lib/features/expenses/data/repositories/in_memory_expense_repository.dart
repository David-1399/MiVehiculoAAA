import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class InMemoryExpenseRepository implements ExpenseRepository {
  final List<Expense> _items = [];

  @override
  Future<List<Expense>> getByVehicleId(String vehicleId) async {
    final result = _items.where((item) => item.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return List.unmodifiable(result);
  }

  @override
  Future<Expense> create(Expense expense) async {
    _items.add(expense);
    return expense;
  }

  @override
  Future<Expense> update(Expense expense) async {
    final index = _items.indexWhere((item) => item.id == expense.id);

    if (index == -1) {
      throw StateError('Gasto no encontrado.');
    }

    _items[index] = expense;
    return expense;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}
