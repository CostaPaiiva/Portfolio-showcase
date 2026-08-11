import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.percent,
    this.subtitle,
    this.icon = Icons.analytics_outlined,
  });

  final String title, value;
  final double percent;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.accentBright, size: 20),
                  const SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
              const SizedBox(height: 14),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 5,
                  value: (percent.clamp(0, 100) / 100).toDouble(),
                  backgroundColor: Colors.white12,
                  color:
                      percent >= 90 ? AppColors.accentBright : AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      );
}
