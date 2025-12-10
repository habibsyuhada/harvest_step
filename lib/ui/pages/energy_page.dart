import "package:flutter/material.dart";

import "../../models/money_entry.dart";
import "../widgets/shared.dart";

class MoneyPage extends StatefulWidget {
  final List<MoneyEntry> entries;
  final void Function(String label, double amount) onAddEntry;
  final int diamondPoints;

  const MoneyPage({
    super.key,
    required this.entries,
    required this.onAddEntry,
    required this.diamondPoints,
  });

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double? latestAmount =
        widget.entries.isNotEmpty ? widget.entries.last.amount : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleText("Money Tracking"),
          const SizedBox(height: 8),
          const Text(
            "Tambah data keuangan, kalau naik dibanding entri sebelumnya kamu dapet Diamond point.",
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
                  child: const Icon(Icons.diamond_rounded, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Diamond point",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.diamondPoints}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Saldo terakhir",
                      style: TextStyle(color: Colors.black54),
                    ),
                    Text(
                      latestAmount != null
                          ? "Rp ${latestAmount.toStringAsFixed(0)}"
                          : "-",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _entryForm(),
          const SizedBox(height: 12),
          if (widget.entries.isEmpty)
            const Text(
              "Belum ada catatan keuangan.",
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

  Widget _entryForm() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Catat transaksi",
            subtitle: "Isi nama transaksi dan nominal.",
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    labelText: "Nama transaksi",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Nominal (Rp)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _submitEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
                child: const Text("Simpan"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moneyTile(MoneyEntry entry) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.savings_rounded, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Rp ${entry.amount.toStringAsFixed(0)}",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            "${entry.date.hour.toString().padLeft(2, "0")}:${entry.date.minute.toString().padLeft(2, "0")}",
            style: const TextStyle(color: Colors.black45, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _submitEntry() {
    final label = _labelController.text.trim();
    final amount =
        double.tryParse(_amountController.text.replaceAll(",", "."));
    if (label.isEmpty || amount == null) return;
    widget.onAddEntry(label, amount);
    _labelController.clear();
    _amountController.clear();
    setState(() {});
  }
}
