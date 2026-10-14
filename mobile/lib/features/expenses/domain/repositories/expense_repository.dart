import '../entities/expense.dart';

abstract interface class ExpenseRepository {
  Future<List<Expense>> getByVehicleId(String vehicleId);

  Future<Expense> create(Expense expense);

  Future<Expense> update(Expense expense);

  Future<void> delete(String id);
}
