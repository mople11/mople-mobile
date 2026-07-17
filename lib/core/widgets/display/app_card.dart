import 'package:flutter/material.dart';

import '../../constants/color.dart';
import '../../constants/radius.dart';
import '../../constants/shadow.dart';
import '../../constants/spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool elevated;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.space6),
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: elevated ? AppShadow.card : null,
      ),
      child: child,
    );
  }
}
