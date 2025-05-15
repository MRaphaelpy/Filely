import 'package:flutter/material.dart';

class ProgressBarWidget extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const ProgressBarWidget({
    Key? key,
    required this.position,
    required this.duration,
    required this.onSeek,
  }) : super(key: key);

  @override
  State<ProgressBarWidget> createState() => _ProgressBarWidgetState();
}

class _ProgressBarWidgetState extends State<ProgressBarWidget>
    with SingleTickerProviderStateMixin {
  late Duration _dragPosition;
  bool _isDragging = false;
  late AnimationController _rippleAnimationController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _dragPosition = widget.position;

    _rippleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleAnimationController,
        curve: Curves.easeOutQuad,
      ),
    );
  }

  @override
  void didUpdateWidget(ProgressBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging && oldWidget.position != widget.position) {
      _dragPosition = widget.position;
    }
  }

  @override
  void dispose() {
    _rippleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final inactiveColor = colorScheme.surfaceVariant;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Track and progress
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 6,
                activeTrackColor: primaryColor,
                inactiveTrackColor: inactiveColor.withOpacity(0.3),
                thumbColor: primaryColor,
                thumbShape: CustomSliderThumbShape(
                  isDragging: _isDragging,
                  rippleAnimation: _rippleAnimation,
                  color: primaryColor,
                ),
                overlayColor: primaryColor.withOpacity(0.2),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              ),
              child: Slider(
                min: 0,
                max:
                    widget.duration.inMilliseconds > 0
                        ? widget.duration.inMilliseconds.toDouble()
                        : 1.0,
                value:
                    _isDragging
                        ? _dragPosition.inMilliseconds.toDouble().clamp(
                          0,
                          widget.duration.inMilliseconds.toDouble(),
                        )
                        : widget.position.inMilliseconds.toDouble().clamp(
                          0,
                          widget.duration.inMilliseconds.toDouble(),
                        ),
                onChanged: (value) {
                  setState(() {
                    _dragPosition = Duration(milliseconds: value.round());
                    if (!_isDragging) {
                      _isDragging = true;
                      _rippleAnimationController.forward(from: 0.0);
                    }
                  });
                },
                onChangeStart: (_) {
                  setState(() {
                    _isDragging = true;
                    _rippleAnimationController.forward(from: 0.0);
                  });
                },
                onChangeEnd: (value) {
                  setState(() {
                    _isDragging = false;
                  });
                  widget.onSeek(Duration(milliseconds: value.round()));
                  _rippleAnimationController.reverse();
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _formatDuration(
                    _isDragging ? _dragPosition : widget.position,
                  ),
                  key: ValueKey<bool>(_isDragging),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        _isDragging ? FontWeight.bold : FontWeight.normal,
                    color:
                        _isDragging ? primaryColor : colorScheme.onBackground,
                  ),
                ),
              ),
              Text(
                _formatDuration(widget.duration),
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onBackground.withOpacity(0.7),
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

class CustomSliderThumbShape extends SliderComponentShape {
  final bool isDragging;
  final Animation<double> rippleAnimation;
  final Color color;

  const CustomSliderThumbShape({
    required this.isDragging,
    required this.rippleAnimation,
    required this.color,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(isDragging ? 16 : 12, isDragging ? 16 : 12);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Pinta o círculo de ripple quando arrastando
    if (isDragging) {
      final Paint ripplePaint =
          Paint()
            ..color = color.withOpacity(0.3 * rippleAnimation.value)
            ..style = PaintingStyle.fill;

      canvas.drawCircle(center, 20 * rippleAnimation.value, ripplePaint);
    }

    // Pinta o círculo principal
    final Paint thumbPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Sombra
    if (isDragging) {
      canvas.drawShadow(
        Path()..addOval(Rect.fromCircle(center: center, radius: 8)),
        Colors.black,
        3.0,
        true,
      );
    }

    // Círculo principal
    double radius = isDragging ? 8 : 6;
    canvas.drawCircle(center, radius, thumbPaint);

    // Borda branca
    final Paint borderPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(center, radius * 0.8, borderPaint);
  }
}
