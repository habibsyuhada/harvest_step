import "package:flutter/material.dart";

import "../widgets/shared.dart";

class ProfilePage extends StatelessWidget {
  final int displaySteps;
  final int energyPoints;
  final String status;

  const ProfilePage({
    super.key,
    required this.displaySteps,
    required this.energyPoints,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleText("Profil"),
          const SizedBox(height: 8),
          const Text(
            "Lihat statistik personal dan performa langkah.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.teal),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Traveler",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Tier: Explorer",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: "Statistik",
                  subtitle: "Data real-time dari pedometer.",
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _miniStat(
                        title: "Langkah",
                        value: "$displaySteps",
                        icon: Icons.directions_walk_rounded,
                      ),
                    ),
                    Expanded(
                      child: _miniStat(
                        title: "Energi",
                        value: "$energyPoints",
                        icon: Icons.bolt_rounded,
                      ),
                    ),
                    Expanded(
                      child: _miniStat(
                        title: "Status",
                        value: status,
                        icon: status == "walking"
                            ? Icons.directions_walk_rounded
                            : Icons.self_improvement_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: "Perkembangan",
                  subtitle: "Target harian dan weekly insight.",
                ),
                const SizedBox(height: 12),
                _progressRow(
                  label: "Target 3k langkah",
                  value: displaySteps,
                  target: 3000,
                ),
                const SizedBox(height: 12),
                _progressRow(
                  label: "Target 10 energi",
                  value: energyPoints,
                  target: 10,
                  unit: "EP",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.teal),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _progressRow({
    required String label,
    required int value,
    required int target,
    String unit = "Langkah",
  }) {
    final double progress = (value / target).clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              "$value / $target $unit",
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          color: Colors.teal,
          backgroundColor: Colors.grey.shade200,
        ),
      ],
    );
  }
}
