import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';

class PlayPauseButton extends StatefulWidget {
  final bool isPlaying;
  final bool isBuffering;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const PlayPauseButton({
    Key? key,
    required this.isPlaying,
    this.isBuffering = false,
    this.size = 48.0,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconTransition;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.85,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.85,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_animationController);

    _iconTransition = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PlayPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = widget.backgroundColor ?? theme.colorScheme.primary;
    final iconColor = widget.iconColor ?? theme.colorScheme.onPrimary;
    final iconSize = widget.size * 0.5;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(widget.size / 2),
                splashColor: iconColor.withOpacity(0.2),
                highlightColor: iconColor.withOpacity(0.1),
                onTap: _handlePlayPause,
                child: widget.isBuffering
                    ? _buildBufferingIndicator(iconColor)
                    : _buildPlayPauseIcon(iconSize, iconColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBufferingIndicator(Color iconColor) {
    return Center(
      child: SizedBox(
        width: widget.size * 0.5,
        height: widget.size * 0.5,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      ),
    );
  }

  Widget _buildPlayPauseIcon(double iconSize, Color iconColor) {
    return AnimatedBuilder(
      animation: _iconTransition,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 1.0 - _iconTransition.value,
              child: Icon(
                Icons.play_arrow_rounded,
                size: iconSize,
                color: iconColor,
              ),
            ),
            Opacity(
              opacity: _iconTransition.value,
              child: Icon(
                Icons.pause_rounded,
                size: iconSize,
                color: iconColor,
              ),
            ),
          ],
        );
      },
    );
  }

  void _handlePlayPause() {
    HapticFeedback.lightImpact();

    if (widget.isBuffering) return;

    if (widget.isPlaying) {
      audioHandler.pause();
    } else {
      audioHandler.play();
    }
  }
}
