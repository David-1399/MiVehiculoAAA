import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class InMemoryExpenseRepository implements ExpenseRepository {
  final List<Expense> _items = [];

  @override
  List<Expense> getAll() {
    return List.unmodifiable(_items);
  }

  @override
  List<Expense> getByVehicleId(String vehicleId) {
    final result = _items.where((item) => item.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return List.unmodifiable(result);
  }

  @override
  Expense? getById(String id) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  @override
  Expense create(Expense expense) {
    _items.add(expense);
    return expense;
  }

  @override
  Expense update(Expense expense) {
    final index = _items.indexWhere((item) => item.id == expense.id);

    if (index == -1) {
      throw StateError('Gasto no encontrado.');
    }

    _items[index] = expense;
    return expense;
  }

  @override
  void delete(String id) {
    _items.removeWhere((item) => item.id == id);
  }
}
