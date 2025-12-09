import "package:flutter/material.dart";

class ShopItem {
  final String title;
  final int price;
  final String perk;
  final IconData icon;

  const ShopItem({
    required this.title,
    required this.price,
    required this.perk,
    required this.icon,
  });
}
