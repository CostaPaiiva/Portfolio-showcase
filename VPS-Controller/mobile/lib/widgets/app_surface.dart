import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class AppSurface extends StatelessWidget {
  const AppSurface({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardLight,
              AppColors.surface,
              AppColors.background,
            ],
            stops: [0, .42, 1],
          ),
        ),
        child: child,
      );
}
