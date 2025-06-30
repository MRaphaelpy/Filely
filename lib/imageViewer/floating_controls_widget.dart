import 'package:flutter/material.dart';

class FloatingControlsWidget extends StatelessWidget {
  final ValueNotifier<bool> isVisible;
  final VoidCallback onResetTransformation;
  final VoidCallback onMoreOptionsPressed;

  const FloatingControlsWidget({
    super.key,
    required this.isVisible,
    required this.onResetTransformation,
    required this.onMoreOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isVisible,
      builder: (context, isVisible, child) {
        return AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
      child: Positioned(
        bottom: 16 + MediaQuery.of(context).padding.bottom,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.zoom_out_map, color: Colors.white),
              onPressed: onResetTransformation,
            ),
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onPressed: onMoreOptionsPressed,
            ),
          ],
        ),
      ),
    );
  }
}
