import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expense.dart';

class ExpensesNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() {
    return [
      Expense(
        id: '1',
        category: 'Aceite',
        description: 'Cambio de aceite',
        amount: 180000,
        date: DateTime(2026, 9, 20),
      ),
      Expense(
        id: '2',
        category: 'Frenos',
        description: 'Pastillas de freno',
        amount: 320000,
        date: DateTime(2026, 7, 5),
      ),
      Expense(
        id: '3',
        category: 'Llantas',
        description: 'Cambio de llantas',
        amount: 550000,
        date: DateTime(2026, 5, 10),
      ),
    ];
  }

  void addExpense({
    required String category,
    required String description,
    required int amount,
    required DateTime date,
  }) {
    state = [
      ...state,
      Expense(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        category: category,
        description: description,
        amount: amount,
        date: date,
      ),
    ];
  }
}

final expensesProvider = NotifierProvider<ExpensesNotifier, List<Expense>>(
  ExpensesNotifier.new,
);
