import 'package:filely/utils/color_extensions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomLoader extends StatefulWidget {
  final Color? primaryColor;
  final Color? secondaryColor;
  final double size;
  final Duration duration;
  final String? message;

  const CustomLoader({
    super.key,
    this.primaryColor,
    this.secondaryColor,
    this.size = 50.0,
    this.duration = const Duration(milliseconds: 1500),
    this.message,
  });

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _radiusAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.elasticOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        widget.primaryColor ?? Theme.of(context).colorScheme.primary;
    final secondaryColor =
        widget.secondaryColor ?? Theme.of(context).colorScheme.secondary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: _rotationAnimation.value * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _SpinnerRingPainter(
                        color: primaryColor,
                        strokeWidth: widget.size * 0.1,
                        value: _rotationAnimation.value,
                      ),
                    ),
                  ),

                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      width: widget.size * _radiusAnimation.value,
                      height: widget.size * _radiusAnimation.value,
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: widget.size * 0.3,
                          height: widget.size * 0.3,
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: secondaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (widget.message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                widget.message!,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpinnerRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double value;

  _SpinnerRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      tileMode: TileMode.repeated,
      colors: [color.withValues(), color.withOpacity(0.5)],
      stops: const [0.0, 1.0],
      transform: GradientRotation(value * 2 * math.pi),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width - strokeWidth,
        height: size.height - strokeWidth,
      ),
      0,
      2 * math.pi * 0.85,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_SpinnerRingPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class LoaderShowcase extends StatelessWidget {
  const LoaderShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomLoader(),
          const SizedBox(height: 40),

          CustomLoader(
            primaryColor: Colors.purple,
            secondaryColor: Colors.amber,
          ),
          const SizedBox(height: 40),

          CustomLoader(
            size: 80,
            primaryColor: Colors.teal,
            secondaryColor: Colors.orange,
            message: 'Carregando arquivos...',
            duration: const Duration(milliseconds: 2000),
          ),
        ],
      ),
    );
  }
}
