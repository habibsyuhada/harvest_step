import "package:flutter/material.dart";

import "../../models/shop_item.dart";
import "../widgets/shared.dart";

class ShopPage extends StatelessWidget {
  final int energyPoints;

  const ShopPage({
    super.key,
    required this.energyPoints,
  });

  @override
  Widget build(BuildContext context) {
    final items = <ShopItem>[
      const ShopItem(
        title: "Starter Crate",
        price: 4,
        perk: "Berisi badge acak & coin game.",
        icon: Icons.inventory_2_rounded,
      ),
      const ShopItem(
        title: "Trail Skin",
        price: 6,
        perk: "Jejak neon unik pas kamu jalan.",
        icon: Icons.style_rounded,
      ),
      const ShopItem(
        title: "Audio Booster",
        price: 3,
        perk: "SFX langkah yang lebih keren.",
        icon: Icons.headphones_rounded,
      ),
      const ShopItem(
        title: "Compass Chip",
        price: 5,
        perk: "Scan lokasi loot terdekat.",
        icon: Icons.explore_rounded,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleText("Shop"),
          const SizedBox(height: 8),
          const Text(
            "Belanja item pakai energi biar progres makin seru.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _shopCard(item),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shopCard(ShopItem item) {
    final bool affordable = energyPoints >= item.price;
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: Colors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.perk,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item.price} EP",
                style: TextStyle(
                  color: affordable ? Colors.teal : Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                affordable ? "Bisa dibeli" : "Belum cukup",
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
