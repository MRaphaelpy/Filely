import 'package:flutter/material.dart';

class AudioAppBarWidget extends StatelessWidget {
  final VoidCallback onBack;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;

  const AudioAppBarWidget({
    super.key,
    required this.onBack,
    this.title = 'Tocando Agora',
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        child: Row(
          children: [
            _buildBackButton(context, colorScheme),
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'player_title',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      title ?? 'Tocando Agora',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),

            if (actions == null || actions!.isEmpty) const SizedBox(width: 48),
            if (actions != null && actions!.isNotEmpty) ...actions!,
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, ColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onBack,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  leading ??
                  Icon(
                    Icons.arrow_back_rounded,
                    color: colorScheme.onSurface,
                    size: 24,
                    key: const ValueKey('back_icon'),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
