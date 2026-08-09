import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.percent,
    this.subtitle,
  });

  final String title;
  final String value;
  final double percent;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final normalized = percent.clamp(0, 100) / 100;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 10),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            LinearProgressIndicator(value: normalized.toDouble()),
          ],
        ),
      ),
    );
  }
}
