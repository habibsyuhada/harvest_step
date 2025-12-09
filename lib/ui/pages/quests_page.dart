import "package:flutter/material.dart";

import "../../models/quest.dart";
import "../widgets/shared.dart";

class QuestsPage extends StatelessWidget {
  final int displaySteps;
  final int stepsPerEnergy;

  const QuestsPage({
    super.key,
    required this.displaySteps,
    required this.stepsPerEnergy,
  });

  @override
  Widget build(BuildContext context) {
    final quests = <Quest>[
      const Quest(
        title: "Explorer I",
        description: "Kumpulkan 500 langkah untuk buka mini-map harian.",
        reward: "+2 energi",
        icon: Icons.map_rounded,
        target: 500,
      ),
      const Quest(
        title: "City Loop",
        description: "Berjalan 1.5 km (2000 langkah) sebelum jam 6 sore.",
        reward: "Badge Jalan Sore",
        icon: Icons.route_rounded,
        target: 2000,
      ),
      Quest(
        title: "Energy Rush",
        description: "Capai 5 energi dalam satu hari.",
        reward: "Loot Box Kasual",
        icon: Icons.bolt_rounded,
        target: stepsPerEnergy * 5,
      ),
      const Quest(
        title: "Social Boost",
        description: "Share progress setelah 3000 langkah.",
        reward: "+1 reroll quest",
        icon: Icons.group_rounded,
        target: 3000,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleText("Quests"),
          const SizedBox(height: 8),
          const Text(
            "Selesaikan quest buat ngumpulin energi dan badge koleksi.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ...quests.map(
            (q) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _questCard(q),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questCard(Quest quest) {
    final double progress = (displaySteps / quest.target).clamp(0, 1).toDouble();
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(quest.icon, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quest.description,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Text(
                quest.reward,
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: Colors.teal,
            minHeight: 10,
          ),
          const SizedBox(height: 8),
          Text(
            "${displaySteps.clamp(0, quest.target)} / ${quest.target} langkah",
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
