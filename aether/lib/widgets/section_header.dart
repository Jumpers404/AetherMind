import 'package:flutter/material.dart';
import '../app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({
    Key? key,
    required this.title,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyPrimary,
            textAlign: TextAlign.left,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
