import "package:flutter/material.dart";

import "../../models/money_entry.dart";
import "../widgets/shared.dart";

class MoneyPage extends StatefulWidget {
  final List<MoneyEntry> entries;
  final void Function(String label, double amount, MoneyType type) onAddEntry;
  final int goldPoints;

  const MoneyPage({
    super.key,
    required this.entries,
    required this.onAddEntry,
    required this.goldPoints,
  });

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  MoneyType _selectedType = MoneyType.income;

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = widget.entries
        .where((e) => e.type == MoneyType.income)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final totalExpense = widget.entries
        .where((e) => e.type == MoneyType.expense)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final balance = totalIncome - totalExpense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleText("Money Tracking"),
          const SizedBox(height: 8),
          const Text(
            "Record income and expenses to manage your finances.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.monetization_on_rounded, color: Colors.amber),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Gold point",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.goldPoints}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _summaryCard(totalIncome, totalExpense, balance),
          const SizedBox(height: 16),
          _entryForm(),
          const SizedBox(height: 12),
          if (widget.entries.isEmpty)
            const Text(
              "No financial records yet.",
              style: TextStyle(color: Colors.black54),
            )
          else
            Column(
              children: widget.entries.reversed
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _moneyTile(entry),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _summaryCard(double income, double expense, double balance) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Financial Summary",
            subtitle: "Total income, expenses, and your balance.",
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  "Income",
                  income,
                  Colors.green,
                  Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryItem(
                  "Expense",
                  expense,
                  Colors.red,
                  Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: balance >= 0
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Balance",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Rp ${balance.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: balance >= 0 
                        ? const Color(0xFF2E7D32) 
                        : const Color(0xFFC62828),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Rp ${amount.toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color == Colors.green 
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFC62828),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryForm() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Record transaction",
            subtitle: "Select transaction type, fill name and amount.",
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text("Income"),
                  selected: _selectedType == MoneyType.income,
                  selectedColor: Colors.green.shade100,
                  onSelected: (_) {
                    setState(() => _selectedType = MoneyType.income);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text("Expense"),
                  selected: _selectedType == MoneyType.expense,
                  selectedColor: Colors.red.shade100,
                  onSelected: (_) {
                    setState(() => _selectedType = MoneyType.expense);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _labelController,
            decoration: InputDecoration(
              labelText: _selectedType == MoneyType.income
                  ? "Income name"
                  : "Expense name",
              border: const OutlineInputBorder(),
              hintText: _selectedType == MoneyType.income
                  ? "Example: Salary, Bonus"
                  : "Example: Food, Transport",
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Nominal (Rp)",
              border: OutlineInputBorder(),
              prefixText: "Rp ",
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedType == MoneyType.income
                    ? Colors.green
                    : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: Icon(
                _selectedType == MoneyType.income
                    ? Icons.add_rounded
                    : Icons.remove_rounded,
              ),
              label: const Text("Save Transaction"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moneyTile(MoneyEntry entry) {
    final isIncome = entry.type == MoneyType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isIncome ? "Income" : "Expense",
                        style: TextStyle(
                          color: color == Colors.green 
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  entry.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${isIncome ? "+" : "-"}Rp ${entry.amount.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: color == Colors.green 
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFC62828),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${entry.date.day}/${entry.date.month}/${entry.date.year}",
                style: const TextStyle(color: Colors.black45, fontSize: 11),
              ),
              Text(
                "${entry.date.hour.toString().padLeft(2, "0")}:${entry.date.minute.toString().padLeft(2, "0")}",
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitEntry() {
    final label = _labelController.text.trim();
    final amount =
        double.tryParse(_amountController.text.replaceAll(",", "."));
    if (label.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name and amount must be filled correctly"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    widget.onAddEntry(label, amount, _selectedType);
    _labelController.clear();
    _amountController.clear();
    setState(() {});
  }
}
