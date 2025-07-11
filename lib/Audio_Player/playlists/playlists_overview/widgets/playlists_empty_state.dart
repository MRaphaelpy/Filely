import 'package:flutter/material.dart';

class EmptyStateWidget extends StatefulWidget {
  final String? title;
  final String? description;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Color? primaryColor;
  final Color? secondaryColor;

  const EmptyStateWidget({
    Key? key,
    this.title,
    this.description,
    this.icon,
    this.onAction,
    this.actionLabel,
    this.primaryColor,
    this.secondaryColor,
  }) : super(key: key);

  @override
  State<EmptyStateWidget> createState() => _EmptyStateWidgetState();
}

class _EmptyStateWidgetState extends State<EmptyStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEmptyIcon(colorScheme),
              const SizedBox(height: 32),
              _buildTitleAndDescription(colorScheme, textTheme),
              const SizedBox(height: 40),
              _buildActionButton(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyIcon(ColorScheme colorScheme) {
    final primaryColor = widget.primaryColor ?? colorScheme.primary;
    final secondaryColor = widget.secondaryColor ?? colorScheme.secondary;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                primaryColor.withOpacity(0.2),
                primaryColor.withOpacity(0),
              ],
              radius: 0.8,
            ),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(widget.icon, size: 54, color: primaryColor),
        ),
        Positioned(
          top: 0,
          right: 40,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: secondaryColor.withOpacity(0.3),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 35,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: colorScheme.tertiary.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndDescription(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Column(
      children: [
        Text(
          widget.title ?? '',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.description ?? '',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(ColorScheme colorScheme) {
    return ElevatedButton.icon(
      onPressed: widget.onAction,
      icon: Icon(widget.icon ?? Icons.question_mark),
      label: Text(widget.actionLabel ?? 'Ação'),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            widget.secondaryColor ?? colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
