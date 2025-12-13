import "package:flutter/material.dart";

import "../widgets/shared.dart";

class ProfilePage extends StatelessWidget {
  final int displaySteps;
  final int energyPointsFromSteps;
  final int energyPoints;
  final String status;
  final int achievementPoints;
  final int goldPoints;

  const ProfilePage({
    super.key,
    required this.displaySteps,
    required this.energyPointsFromSteps,
    required this.energyPoints,
    required this.status,
    required this.achievementPoints,
    required this.goldPoints,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleText("Profile & Settings"),
          const SizedBox(height: 8),
          const Text(
            "View summary of all points, status, and preferences.",
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
                  title: "Statistics",
                  subtitle: "Real-time data from pedometer.",
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _miniStat(
                        title: "Steps",
                        value: "$displaySteps",
                        icon: Icons.directions_walk_rounded,
                      ),
                    ),
                    Expanded(
                      child: _miniStat(
                        title: "Energy",
                        value: "$energyPointsFromSteps",
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
                  title: "Point progress",
                  subtitle: "All points from your tracker.",
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _pointBadge(
                      color: Colors.teal.shade50,
                      label: "Energy",
                      value: energyPoints,
                      icon: Icons.bolt_rounded,
                    ),
                    _pointBadge(
                      color: Colors.blue.shade50,
                      label: "Energy",
                      value: energyPointsFromSteps,
                      icon: Icons.bolt_rounded,
                    ),
                    _pointBadge(
                      color: Colors.yellow.shade50,
                      label: "Achievement",
                      value: achievementPoints,
                      icon: Icons.check_circle_rounded,
                    ),
                    _pointBadge(
                      color: Colors.amber.shade50,
                      label: "Gold",
                      value: goldPoints,
                      icon: Icons.monetization_on_rounded,
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
                  title: "Settings",
                  subtitle: "Quick adjustments for profile & notifications.",
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  activeThumbColor: Colors.teal,
                  activeTrackColor: Colors.teal.withValues(alpha: 0.25),
                  title: const Text("Daily achievement notifications"),
                  subtitle: const Text("Send reminder when target is reached."),
                ),
                SwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  activeThumbColor: Colors.teal,
                  activeTrackColor: Colors.teal.withValues(alpha: 0.25),
                  title: const Text("Battery saver mode"),
                  subtitle: const Text("Reduce animation refresh & heavy sensors."),
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

  Widget _pointBadge({
    required Color color,
    required String label,
    required int value,
    required IconData icon,
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
          const SizedBox(width: 8),
          Text(
            "$value",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
