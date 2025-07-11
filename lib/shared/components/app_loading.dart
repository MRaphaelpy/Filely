import 'package:filely/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;
  final bool showMessage;

  const AppLoading({
    super.key,
    this.message,
    this.size = 50.0,
    this.color,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CustomLoader(
              primaryColor: color ?? theme.colorScheme.onPrimaryContainer,
              secondaryColor: color ?? theme.colorScheme.onSecondaryContainer,
              size: size,
            ),
          ),
          if (showMessage && message != null) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              message!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final Color? overlayColor;

  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withValues(alpha: 0.5),
            child: AppLoading(
              message: loadingMessage ?? AppStrings.loading(context),
            ),
          ),
      ],
    );
  }
}
