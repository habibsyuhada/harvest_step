import "package:flutter/material.dart";

class Quest {
  final String title;
  final String description;
  final String reward;
  final IconData icon;
  final int target;

  const Quest({
    required this.title,
    required this.description,
    required this.reward,
    required this.icon,
    required this.target,
  });
}
