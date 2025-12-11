import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../models/weight_goal.dart";
import "../widgets/shared.dart";

class DashboardPage extends StatefulWidget {
  final int displaySteps;
  final int sapphirePoints;
  final double sapphireProgress;
  final int stepsToNextSapphire;
  final int energyPoints;
  final int hydrationPoints;
  final String status;
  final String? stepError;
  final double waterGoalLiters;
  final double waterIntakeLiters;
  final void Function(double liters) onAddWater;
  final List<double> weightEntries;
  final WeightGoalDirection weightGoalDirection;
  final void Function(double weight) onAddWeight;
  final void Function(WeightGoalDirection goal) onUpdateWeightGoal;
  final int bodyPoints;

  const DashboardPage({
    super.key,
    required this.displaySteps,
    required this.sapphirePoints,
    required this.sapphireProgress,
    required this.stepsToNextSapphire,
    required this.energyPoints,
    required this.hydrationPoints,
    required this.status,
    required this.stepError,
    required this.waterGoalLiters,
    required this.waterIntakeLiters,
    required this.onAddWater,
    required this.weightEntries,
    required this.weightGoalDirection,
    required this.onAddWeight,
    required this.onUpdateWeightGoal,
    required this.bodyPoints,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _selectedWaterMl = 250;

  @override
  void dispose() {
    _waterController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waterProgress = (widget.waterIntakeLiters / widget.waterGoalLiters)
        .clamp(0, 1)
        .toDouble();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0FB486), Color(0xFF0EA69C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Wellness Tracker",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Total energy",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${widget.energyPoints} pts",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _energyProgressCard(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _statTile(
                  icon: Icons.directions_walk_rounded,
                  title: "Langkah Hari Ini",
                  value: widget.stepError ?? "${widget.displaySteps}",
                  color: Colors.indigo,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.status == "walking"
                            ? Icons.directions_walk_rounded
                            : Icons.self_improvement_rounded,
                        color: Colors.grey.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.status,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _weightTrackerCard(),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: "Air minum hari ini",
                        subtitle:
                            "Capai ${widget.waterGoalLiters.toStringAsFixed(1)}L untuk target hidrasi harian.",
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: waterProgress,
                              minHeight: 12,
                              color: Colors.teal,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${widget.waterIntakeLiters.toStringAsFixed(2)} L",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "${(widget.waterGoalLiters - widget.waterIntakeLiters).clamp(0, widget.waterGoalLiters).toStringAsFixed(2)} L lagi",
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _waterController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: "Tambah minum (ml)",
                          border: OutlineInputBorder(),
                          suffixText: "ml",
                        ),
                        onSubmitted: (_) => _submitWater(),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _quickWaterChip(100),
                          _quickWaterChip(250),
                          _quickWaterChip(500),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Atur cepat pakai slider (${_selectedWaterMl.toStringAsFixed(0)} ml)",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Slider(
                            value: _selectedWaterMl,
                            min: 50,
                            max: 1000,
                            divisions: 19,
                            label: "${_selectedWaterMl.toStringAsFixed(0)} ml",
                            activeColor: Colors.teal,
                            onChanged: (value) =>
                                setState(() => _selectedWaterMl = value),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: _addSelectedWater,
                              icon: const Icon(Icons.water_drop_rounded),
                              label: const Text("Tambahkan"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _energyProgressCard() {
    final totalEnergy = widget.energyPoints;
    return AppCard(
      color: Colors.white.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total energy",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$totalEnergy pts",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pointChip(
                color: Colors.white.withValues(alpha: 0.12),
                icon: Icons.directions_walk_rounded,
                label: "Langkah",
                value: widget.sapphirePoints,
              ),
              _pointChip(
                color: Colors.white.withValues(alpha: 0.12),
                icon: Icons.monitor_weight_rounded,
                label: "Berat badan",
                value: widget.bodyPoints,
              ),
              _pointChip(
                color: Colors.white.withValues(alpha: 0.12),
                icon: Icons.water_drop_rounded,
                label: "Air minum",
                value: widget.hydrationPoints,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Saphire dari langkah",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${widget.displaySteps} langkah",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: widget.sapphireProgress.clamp(0, 1),
              minHeight: 10,
              color: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Menuju energi berikutnya",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
              Text(
                widget.stepsToNextSapphire == 0
                    ? "Sudah siap +1 saphire"
                    : "${widget.stepsToNextSapphire} langkah lagi",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    Widget? trailing,
  }) {
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _weightTrackerCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Body weight tracker",
            subtitle:
                "Pilih target turun/naik berat. Masukkan berat hari ini untuk cek progres.",
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<WeightGoalDirection>(
            key: ValueKey(widget.weightGoalDirection),
            initialValue: widget.weightGoalDirection,
            items: WeightGoalDirection.values
                .map(
                  (goal) =>
                      DropdownMenuItem(value: goal, child: Text(goal.label)),
                )
                .toList(),
            onChanged: (goal) {
              if (goal != null) {
                widget.onUpdateWeightGoal(goal);
              }
            },
            decoration: const InputDecoration(
              labelText: "Target",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^\d{0,3}([.,]\d{0,2})?$'),
              ),
            ],
            decoration: const InputDecoration(
              labelText: "Berat hari ini (kg)",
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submitWeight(),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton(
              onPressed: _submitWeight,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
              ),
              child: const Text("Catat"),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _pointChip(
                color: Colors.indigo.shade50,
                icon: Icons.trending_down_rounded,
                label: "Body progress",
                value: widget.bodyPoints,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.weightEntries.isEmpty)
            const Text(
              "Belum ada log berat.",
              style: TextStyle(color: Colors.black54),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Riwayat terakhir",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ...widget.weightEntries.reversed
                    .take(4)
                    .map(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.monitor_weight_rounded,
                                color: Colors.indigo,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "${w.toStringAsFixed(1)} kg",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _pointChip({
    required Color color,
    required IconData icon,
    required String label,
    required int value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 6),
          Text("$value", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _quickWaterChip(double ml) {
    return ActionChip(
      label: Text("+${ml.toStringAsFixed(0)} ml"),
      avatar: const Icon(Icons.local_drink_rounded, color: Colors.teal),
      onPressed: () => _addWaterMl(ml),
      backgroundColor: Colors.teal.withValues(alpha: 0.08),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  void _addSelectedWater() {
    _addWaterMl(_selectedWaterMl);
  }

  void _addWaterMl(double ml) {
    widget.onAddWater(ml / 1000);
  }

  void _submitWater() {
    final raw = double.tryParse(_waterController.text.replaceAll(",", "."));
    if (raw == null) return;
    widget.onAddWater(raw / 1000);
    _waterController.clear();
  }

  void _submitWeight() {
    final raw = double.tryParse(_weightController.text.replaceAll(",", "."));
    if (raw == null) return;
    widget.onAddWeight(raw);
    _weightController.clear();
  }
}
