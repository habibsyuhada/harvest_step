import "package:flutter/material.dart";

import "../widgets/shared.dart";

class GamePlaceholderPage extends StatelessWidget {
  const GamePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleText("Game"),
          const SizedBox(height: 8),
          const Text(
            "Slot ini disiapkan buat konsep game nanti. Untuk sekarang halaman dibiarkan kosong dulu.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Coming soon",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Ide game bakal ditambah di update berikutnya.",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
