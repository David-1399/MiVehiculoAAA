class Expense {
  const Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });

  final String id;
  final String category;
  final String description;
  final int amount;
  final DateTime date;
}
