import 'package:flutter/material.dart';
import '../app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const AppCard({
    Key? key,
    required this.child,
    this.padding,
    this.color,
    this.gradient,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.card) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [AppShadows.soft],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    
    return card;
  }
}
