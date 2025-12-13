enum MoneyType { income, expense }

class MoneyEntry {
  MoneyEntry({
    required this.label,
    required this.amount,
    required this.type,
    required this.date,
  });

  final String label;
  final double amount;
  final MoneyType type;
  final DateTime date;
}
