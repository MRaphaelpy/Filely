import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerControlsWidget extends StatefulWidget {
  final bool isPlaying;
  final bool? isBuffering;
  final double? playbackSpeed;
  final VoidCallback onPlayPause;
  final VoidCallback onRewind;
  final VoidCallback onFastForward;
  final VoidCallback? onSpeedChange;
  final VoidCallback? onShare;

  const PlayerControlsWidget({
    super.key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onRewind,
    required this.onFastForward,
    this.isBuffering,
    this.playbackSpeed,
    this.onSpeedChange,
    this.onShare,
  });

  @override
  State<PlayerControlsWidget> createState() => _PlayerControlsWidgetState();
}

class _PlayerControlsWidgetState extends State<PlayerControlsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _playPauseController;

  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _updatePlayPauseState();
  }

  @override
  void didUpdateWidget(PlayerControlsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePlayPauseState();
  }

  void _updatePlayPauseState() {
    if (widget.isPlaying) {
      _playPauseController.forward();
    } else {
      _playPauseController.reverse();
    }
  }

  @override
  void dispose() {
    _playPauseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSpeedButton(colorScheme),
              const SizedBox(width: 24),
              _buildShareButton(colorScheme),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSkipButton(
                Icons.skip_previous_rounded,
                widget.onRewind,
                colorScheme,
              ),
              const SizedBox(width: 40),
              _buildPlayPauseButton(colorScheme),
              const SizedBox(width: 40),
              _buildSkipButton(
                Icons.skip_next_rounded,
                widget.onFastForward,
                colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkipButton(
    IconData icon,
    VoidCallback onPressed,
    ColorScheme colorScheme,
  ) {
    return FilledButton.tonal(
      onPressed: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      style: FilledButton.styleFrom(
        minimumSize: const Size(60, 60),
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
      ),
      child: Icon(icon, size: 36, color: colorScheme.onSecondaryContainer),
    );
  }

  Widget _buildPlayPauseButton(ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        FilledButton.tonal(
          onPressed: () {
            HapticFeedback.mediumImpact();
            widget.onPlayPause();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            minimumSize: const Size(72, 72),
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          child:
              widget.isBuffering == true
                  ? SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  )
                  : AnimatedBuilder(
                    animation: _playPauseController,
                    builder: (_, __) {
                      return AnimatedIcon(
                        icon: AnimatedIcons.play_pause,
                        progress: _playPauseController,
                        size: 38,
                        color: colorScheme.onPrimaryContainer,
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildSpeedButton(ColorScheme colorScheme) {
    return FilledButton.tonalIcon(
      onPressed: widget.onSpeedChange,
      icon: const Icon(Icons.speed),
      label: Text(
        '${widget.playbackSpeed ?? 1.0}x',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.surfaceVariant.withOpacity(0.7),
        foregroundColor: colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildShareButton(ColorScheme colorScheme) {
    return IconButton(
      onPressed: widget.onShare,
      icon: const Icon(Icons.share_rounded),
    );
  }
}
