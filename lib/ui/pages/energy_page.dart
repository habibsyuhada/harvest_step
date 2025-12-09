import "package:flutter/material.dart";

import "../widgets/shared.dart";

class EnergyPage extends StatelessWidget {
  final int energyPoints;
  final int stepsToNextEnergy;

  const EnergyPage({
    super.key,
    required this.energyPoints,
    required this.stepsToNextEnergy,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleText("Energy Bank"),
          const SizedBox(height: 8),
          const Text(
            "Kumpulkan energi dari langkah lalu tukar buat buff permainan.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Energi Aktif",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$energyPoints pts",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.bolt_rounded, color: Colors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  stepsToNextEnergy == 0
                      ? "Langsung klaim +1 energi, lanjut jalan biar nambah lagi."
                      : "$stepsToNextEnergy langkah lagi ke energi berikutnya.",
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(
            title: "Pakai energi",
            subtitle: "Tukar jadi buff atau item instan.",
          ),
          const SizedBox(height: 12),
          _energyActionCard(
            title: "Speed Buff",
            desc: "Pakai 2 energi buat dapet +10% speed 30 menit.",
            cost: 2,
            icon: Icons.speed_rounded,
          ),
          const SizedBox(height: 12),
          _energyActionCard(
            title: "Loot Radar",
            desc: "Tukar 3 energi untuk auto loot jarak dekat.",
            cost: 3,
            icon: Icons.radar_rounded,
          ),
          const SizedBox(height: 12),
          _energyActionCard(
            title: "Revive Ticket",
            desc: "Simpan 5 energi sebagai cadangan revive.",
            cost: 5,
            icon: Icons.favorite_rounded,
          ),
        ],
      ),
    );
  }

  Widget _energyActionCard({
    required String title,
    required String desc,
    required int cost,
    required IconData icon,
  }) {
    final bool affordable = energyPoints >= cost;
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: affordable ? Colors.teal : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$cost EP",
              style: TextStyle(
                color: affordable ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
