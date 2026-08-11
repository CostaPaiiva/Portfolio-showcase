import 'package:flutter/material.dart';

class ManualSection {
  const ManualSection({
    required this.title,
    required this.icon,
    required this.paragraphs,
    this.bullets = const [],
    this.warning,
  });

  final String title;
  final IconData icon;
  final List<String> paragraphs;
  final List<String> bullets;
  final String? warning;

  String get searchableText =>
      '$title ${paragraphs.join(' ')} ${bullets.join(' ')} ${warning ?? ''}';
}
