import 'package:filely/shared/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

enum AppButtonType { primary, secondary, outline, text, icon }

class AppButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    this.text,
    this.icon,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  }) : type = AppButtonType.primary,
       icon = null;

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  }) : type = AppButtonType.secondary,
       icon = null;

  const AppButton.outline({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  }) : type = AppButtonType.outline,
       icon = null;

  const AppButton.text({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.foregroundColor,
    this.borderRadius,
  }) : type = AppButtonType.text,
       icon = null,
       backgroundColor = null;

  const AppButton.icon({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  }) : type = AppButtonType.icon,
       text = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (type == AppButtonType.icon) {
      return _buildIconButton(context, theme);
    }

    return _buildButton(context, theme);
  }

  Widget _buildIconButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: width ?? 48,
      height: height ?? 48,
      child: IconButton(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: AppConstants.iconSize,
                height: AppConstants.iconSize,
                child: CustomLoader(
                  primaryColor:
                      foregroundColor ?? theme.colorScheme.onPrimaryContainer,
                  secondaryColor:
                      foregroundColor ?? theme.colorScheme.onSecondaryContainer,
                  size: AppConstants.iconSize,
                ),
              )
            : Icon(icon, color: foregroundColor, size: AppConstants.iconSize),
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ??
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, ThemeData theme) {
    final buttonStyle = _getButtonStyle(theme);

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CustomLoader(
                  primaryColor: _getProgressIndicatorColor(theme),
                  secondaryColor: _getProgressIndicatorColor(
                    theme,
                  ).withValues(alpha: 0.5),
                  size: 20,
                ),
              )
            : Text(text ?? ''),
      ),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ??
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        );
      case AppButtonType.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.secondary,
          foregroundColor: foregroundColor ?? theme.colorScheme.onSecondary,
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ??
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        );
      case AppButtonType.outline:
        return OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? theme.colorScheme.primary,
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ??
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          side: BorderSide(color: foregroundColor ?? theme.colorScheme.primary),
        );
      case AppButtonType.text:
        return TextButton.styleFrom(
          foregroundColor: foregroundColor ?? theme.colorScheme.primary,
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
                vertical: AppConstants.smallPadding,
              ),
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ??
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        );
      default:
        return ElevatedButton.styleFrom();
    }
  }

  Color _getProgressIndicatorColor(ThemeData theme) {
    switch (type) {
      case AppButtonType.primary:
        return foregroundColor ?? theme.colorScheme.onPrimary;
      case AppButtonType.secondary:
        return foregroundColor ?? theme.colorScheme.onSecondary;
      case AppButtonType.outline:
      case AppButtonType.text:
        return foregroundColor ?? theme.colorScheme.primary;
      default:
        return theme.colorScheme.primary;
    }
  }
}
