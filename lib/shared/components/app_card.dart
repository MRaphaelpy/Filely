import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? selectedColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              borderRadius ??
              BorderRadius.circular(AppConstants.defaultBorderRadius),
          child: Card(
            elevation: elevation ?? 2,
            color: isSelected
                ? (selectedColor ?? theme.colorScheme.primaryContainer)
                : backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius:
                  borderRadius ??
                  BorderRadius.circular(AppConstants.defaultBorderRadius),
              side: isSelected
                  ? BorderSide(color: theme.colorScheme.primary, width: 2)
                  : BorderSide.none,
            ),
            child: Padding(
              padding:
                  padding ?? const EdgeInsets.all(AppConstants.defaultPadding),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AppListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final bool isSelected;
  final Color? selectedColor;

  const AppListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.contentPadding,
    this.isSelected = false,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: isSelected
          ? BoxDecoration(
              color: selectedColor ?? theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(
                AppConstants.defaultBorderRadius,
              ),
            )
          : null,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
              vertical: AppConstants.smallPadding,
            ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
    );
  }
}
