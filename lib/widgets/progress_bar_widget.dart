import 'package:filely/utils/color_extensions.dart';
import 'package:flutter/material.dart';

class ProgressBarWidget extends StatefulWidget {
  final Duration position;

  final Duration duration;

  final ValueChanged<Duration> onSeek;

  final Color? accentColor;

  final double trackHeight;

  const ProgressBarWidget({
    Key? key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.accentColor,
    this.trackHeight = 6.0,
  }) : super(key: key);

  @override
  State<ProgressBarWidget> createState() => _ProgressBarWidgetState();
}

class _ProgressBarWidgetState extends State<ProgressBarWidget> {
  bool _isDragging = false;

  Duration _userPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _userPosition = widget.position;
  }

  @override
  void didUpdateWidget(ProgressBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_isDragging) {
      setState(() {
        _userPosition = widget.position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color activeColor = widget.accentColor ?? theme.colorScheme.primary;
    final Color inactiveColor = theme.colorScheme.surfaceContainerHighest
        .withValues(alpha: 0.3);

    final double maxValue = widget.duration.inMilliseconds > 0
        ? widget.duration.inMilliseconds.toDouble()
        : 1.0;

    final Duration displayPosition = _isDragging
        ? _userPosition
        : widget.position;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: widget.trackHeight,
            activeTrackColor: activeColor,
            inactiveTrackColor: inactiveColor,
            thumbColor: activeColor,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayColor: activeColor.withValues(alpha: 0.2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            min: 0,
            max: maxValue,
            value: displayPosition.inMilliseconds.toDouble().clamp(0, maxValue),
            onChanged: (value) {
              setState(() {
                _userPosition = Duration(milliseconds: value.round());
                if (!_isDragging) {
                  _isDragging = true;
                }
              });
            },
            onChangeStart: (_) {
              setState(() {
                _isDragging = true;
                _userPosition = widget.position;
              });
            },
            onChangeEnd: (value) {
              final newPosition = Duration(milliseconds: value.round());

              setState(() {
                _isDragging = false;
                _userPosition = newPosition;
              });

              widget.onSeek(newPosition);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(displayPosition),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: _isDragging ? FontWeight.bold : FontWeight.normal,
                  color: _isDragging
                      ? activeColor
                      : theme.colorScheme.onSurface,
                ),
              ),
              Text(
                _formatDuration(widget.duration),
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}
