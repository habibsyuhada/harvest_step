import "package:flutter/material.dart";

import "../widgets/shared.dart";

class DashboardPage extends StatelessWidget {
  final int displaySteps;
  final int energyPoints;
  final double energyProgress;
  final int stepsToNextEnergy;
  final String status;
  final String? stepError;

  const DashboardPage({
    super.key,
    required this.displaySteps,
    required this.energyPoints,
    required this.energyProgress,
    required this.stepsToNextEnergy,
    required this.status,
    required this.stepError,
  });

  @override
  Widget build(BuildContext context) {
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
                  "Harvest Step",
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
                      "Energy",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "$energyPoints pts",
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
                  value: stepError ?? "$displaySteps",
                  color: Colors.indigo,
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: "Rutinitas Pagi",
                        subtitle:
                            "Mulai hari dengan misi ringan buat dapet energi ekstra.",
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          _taskRow(
                            icon: Icons.sunny,
                            title: "Morning Warm-up",
                            detail: "Jalan santai 200 langkah",
                            progress:
                                displaySteps >= 200 ? 1 : displaySteps / 200,
                          ),
                          const SizedBox(height: 12),
                          _taskRow(
                            icon: Icons.water_drop,
                            title: "Hydration Bonus",
                            detail: "Minum air setelah 500 langkah",
                            progress:
                                displaySteps >= 500 ? 1 : displaySteps / 500,
                          ),
                          const SizedBox(height: 12),
                          _taskRow(
                            icon: Icons.local_florist,
                            title: "Nature Check-in",
                            detail: "Keluar rumah sebentar saat 800 langkah",
                            progress:
                                displaySteps >= 800 ? 1 : displaySteps / 800,
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
                        title: "Streak & Perk",
                        subtitle: "Jaga ritme harian biar energi makin deras masuk.",
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _badgeTile(
                              color: Colors.teal.shade100,
                              iconColor: Colors.teal.shade800,
                              title: "Streak 3 Hari",
                              desc: "+3% bonus energi",
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _badgeTile(
                              color: Colors.blue.shade100,
                              iconColor: Colors.blue.shade800,
                              title: "Langkah Konsisten",
                              desc: "Target 5k langkah",
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
    return AppCard(
      color: Colors.white.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Energi dari langkah",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$displaySteps langkah",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: energyProgress.clamp(0, 1),
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
                stepsToNextEnergy == 0
                    ? "Sudah siap +1 energi"
                    : "$stepsToNextEnergy langkah lagi",
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
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
        ],
      ),
    );
  }

  Widget _taskRow({
    required IconData icon,
    required String title,
    required String detail,
    required double progress,
  }) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
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
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0, 1),
                backgroundColor: Colors.grey.shade200,
                color: Colors.teal,
                minHeight: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _badgeTile({
    required Color color,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.emoji_events_rounded, color: iconColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
