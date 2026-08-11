import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  const MetricCard(
      {super.key,
      required this.title,
      required this.value,
      required this.percent,
      this.subtitle});
  final String title, value;
  final double percent;
  final String? subtitle;
  @override
  Widget build(BuildContext c) => Card(
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(c).textTheme.headlineSmall),
            if (subtitle != null) Text(subtitle!),
            const SizedBox(height: 12),
            LinearProgressIndicator(
                value: (percent.clamp(0, 100) / 100).toDouble())
          ])));
}
