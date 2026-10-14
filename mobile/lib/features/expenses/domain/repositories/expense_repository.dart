import '../entities/expense.dart';

abstract interface class ExpenseRepository {
  List<Expense> getAll();

  List<Expense> getByVehicleId(String vehicleId);

  Expense? getById(String id);

  Expense create(Expense expense);

  Expense update(Expense expense);

  void delete(String id);
}
