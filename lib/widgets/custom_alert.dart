import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAlert extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? elevation;
  final bool dismissible;
  final double blurStrength;
  final VoidCallback? onDismiss;

  const CustomAlert({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.elevation = 10.0,
    this.dismissible = true,
    this.blurStrength = 5.0,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<CustomAlert> createState() => _CustomAlertState();
}

class _CustomAlertState extends State<CustomAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _animationController.forward();

    // Fornece feedback tátil quando o diálogo é exibido
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismissDialog() async {
    if (!widget.dismissible) return;

    // Anima o fechamento do diálogo
    await _animationController.reverse();

    if (widget.onDismiss != null) {
      widget.onDismiss!();
    }

    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    // Calcula as dimensões com base na orientação
    final deviceWidth = orientation == Orientation.portrait
        ? screenSize.width
        : screenSize.height;

    // Usar SafeArea para garantir que o alerta não seja cortado em dispositivos com notch
    return SafeArea(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blurStrength * _fadeAnimation.value,
              sigmaY: widget.blurStrength * _fadeAnimation.value,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.4 * _fadeAnimation.value),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTap: widget.dismissible ? _dismissDialog : null,
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: () {}, // Impede que o tap interno feche o diálogo
                  child: Container(
                    width: deviceWidth * 0.85,
                    constraints: BoxConstraints(
                      maxWidth: 450, // Limita largura máxima em tablets
                      minWidth:
                          280, // Garante uma largura mínima em pequenos dispositivos
                    ),
                    child: Material(
                      color:
                          widget.backgroundColor ??
                          theme.dialogTheme.backgroundColor ??
                          theme.cardColor,
                      elevation: widget.elevation ?? 0,
                      shadowColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius ?? 16.0,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
