import "package:flutter/material.dart";

import "../widgets/shared.dart";

class ProfilePage extends StatelessWidget {
  final int displaySteps;
  final int sapphirePoints;
  final int energyPoints;
  final String status;
  final int topazPoints;
  final int diamondPoints;

  const ProfilePage({
    super.key,
    required this.displaySteps,
    required this.sapphirePoints,
    required this.energyPoints,
    required this.status,
    required this.topazPoints,
    required this.diamondPoints,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleText("Profil & Pengaturan"),
          const SizedBox(height: 8),
          const Text(
            "Lihat ringkasan semua point, status, dan preferensi.",
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
                        title: "Saphire",
                        value: "$sapphirePoints",
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
                  subtitle: "Semua point dari tracker kamu.",
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
                      label: "Saphire",
                      value: sapphirePoints,
                      icon: Icons.water_drop_rounded,
                    ),
                    _pointBadge(
                      color: Colors.yellow.shade50,
                      label: "Topaz",
                      value: topazPoints,
                      icon: Icons.check_circle_rounded,
                    ),
                    _pointBadge(
                      color: Colors.lightBlue.shade50,
                      label: "Diamond",
                      value: diamondPoints,
                      icon: Icons.diamond_rounded,
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
                  title: "Pengaturan",
                  subtitle: "Penyesuaian cepat profil & notifikasi.",
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  activeThumbColor: Colors.teal,
                  activeTrackColor: Colors.teal.withValues(alpha: 0.25),
                  title: const Text("Notifikasi pencapaian harian"),
                  subtitle: const Text("Kirim reminder pas target tercapai."),
                ),
                SwitchListTile(
                  value: true,
                  onChanged: (_) {},
                  activeThumbColor: Colors.teal,
                  activeTrackColor: Colors.teal.withValues(alpha: 0.25),
                  title: const Text("Mode hemat baterai"),
                  subtitle: const Text("Kurangi refresh animasi & sensor berat."),
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
