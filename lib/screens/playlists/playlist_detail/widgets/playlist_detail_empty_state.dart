import 'package:flutter/material.dart';

class PlaylistDetailEmptyState extends StatefulWidget {
  final VoidCallback onGoToLibrary;

  const PlaylistDetailEmptyState({super.key, required this.onGoToLibrary});

  @override
  State<PlaylistDetailEmptyState> createState() =>
      _PlaylistDetailEmptyStateState();
}

class _PlaylistDetailEmptyStateState extends State<PlaylistDetailEmptyState>
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

    return SliverFillRemaining(
      child: FadeTransition(
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
      ),
    );
  }

  Widget _buildEmptyIcon(ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.2),
                colorScheme.primary.withValues(alpha: 0),
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
                color: colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.music_off_rounded,
            size: 54,
            color: colorScheme.primary,
          ),
        ),
        Positioned(
          top: 0,
          right: 40,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.secondary.withValues(alpha: 0.3),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 35,
          child: CircleAvatar(
            radius: 15,
            backgroundColor: colorScheme.tertiary.withValues(alpha: 0.3),
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
          'Playlist vazia',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Adicione músicas tocando e segurando em arquivos de áudio na biblioteca',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(ColorScheme colorScheme) {
    return ElevatedButton.icon(
      onPressed: widget.onGoToLibrary,
      icon: const Icon(Icons.library_music_rounded),
      label: const Text('Explorar biblioteca'),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondaryContainer,
        foregroundColor: colorScheme.onSecondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
