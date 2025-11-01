import 'package:flutter/material.dart';

class Merchant {
  final String? id;
  final String name;
  final String category;
  final IconData icon;
  final Color color;

  const Merchant({
    this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.color,
  });
}
