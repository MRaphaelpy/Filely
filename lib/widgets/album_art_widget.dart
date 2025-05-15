import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

class AlbumArtWidget extends StatefulWidget {
  final String albumArtUrl;
  final bool isPlaying;
  final bool showVinylEffect;
  final String? albumTitle;
  final String? artistName;
  final VoidCallback? onTap;
  final Color? dominantColor;

  const AlbumArtWidget({
    super.key,
    required this.albumArtUrl,
    this.isPlaying = false,
    this.showVinylEffect = true,
    this.albumTitle,
    this.artistName,
    this.onTap,
    this.dominantColor,
  });

  @override
  State<AlbumArtWidget> createState() => _AlbumArtWidgetState();
}

class _AlbumArtWidgetState extends State<AlbumArtWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  double _dragStartY = 0;
  double _currentScale = 1.0;
  bool _isImageLoaded = false;
  bool _isImageError = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(AlbumArtWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = widget.dominantColor ?? colorScheme.primary;
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return Center(
      child: GestureDetector(
        onTap: widget.onTap,
        onVerticalDragStart: (details) {
          _dragStartY = details.localPosition.dy;
        },
        onVerticalDragUpdate: (details) {
          final dragDelta = (_dragStartY - details.localPosition.dy) / 300;
          setState(() {
            _currentScale = (1.0 + dragDelta).clamp(0.8, 1.2);
          });
        },
        onVerticalDragEnd: (_) {
          setState(() => _currentScale = 1.0);
        },
        child: Hero(
          tag: 'album_art_${widget.albumArtUrl}',
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AspectRatio(
              aspectRatio: 1,
              child: AnimatedScale(
                scale: _currentScale,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: _buildAlbumArtWithEffects(
                  baseColor,
                  colorScheme,
                  isDarkMode,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArtWithEffects(
    Color baseColor,
    ColorScheme colorScheme,
    bool isDarkMode,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isImageLoaded && !_isImageError)
          Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(0.5),
                      blurRadius: widget.isPlaying ? 90 : 50,
                      spreadRadius: widget.isPlaying ? 8 : 4,
                    ),
                  ],
                ),
              )
              .animate(
                onPlay:
                    widget.isPlaying
                        ? (controller) => controller.repeat()
                        : null,
              )
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.05, 1.05),
                duration: 3.seconds,
              )
              .then()
              .scale(
                begin: const Offset(1.05, 1.05),
                end: const Offset(0.95, 0.95),
                duration: 3.seconds,
              ),

        if (widget.showVinylEffect && !_isImageError)
          RotationTransition(
            turns: _rotationController,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
                gradient: RadialGradient(
                  colors: [
                    Colors.grey.shade800,
                    Colors.black,
                    Colors.black,
                    Colors.grey.shade900,
                  ],
                  stops: const [0.0, 0.4, 0.9, 1.0],
                  center: Alignment.center,
                ),
              ),
              child: Center(
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(
            duration: 600.ms,
            delay: widget.isPlaying ? 0.ms : 300.ms,
          ),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              widget.isPlaying && widget.showVinylEffect && !_isImageError
                  ? 300
                  : 24,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.3),
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: baseColor.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin:
                widget.isPlaying && widget.showVinylEffect && !_isImageError
                    ? const EdgeInsets.all(20)
                    : EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                widget.isPlaying && widget.showVinylEffect && !_isImageError
                    ? 300
                    : 24,
              ),
              child:
                  _isImageError ? _buildPlaceholderImage() : _buildAlbumImage(),
            ),
          ),
        ),

        if (!_isImageError)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                widget.isPlaying && widget.showVinylEffect ? 300 : 24,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin:
                    widget.isPlaying && widget.showVinylEffect
                        ? const EdgeInsets.all(20)
                        : EdgeInsets.zero,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight.add(const Alignment(0.3, 0.3)),
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.1),
                    ],
                    stops: const [0.0, 0.15, 0.3, 0.6, 0.8, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(
                    widget.isPlaying && widget.showVinylEffect ? 300 : 24,
                  ),
                ),
              ),
            ),
          ),

        if (widget.isPlaying && !_isImageError)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                widget.isPlaying && widget.showVinylEffect ? 300 : 24,
              ),
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin:
                      widget.showVinylEffect
                          ? const EdgeInsets.all(20)
                          : EdgeInsets.zero,
                  child: AnimatedOpacity(
                    opacity: 0.15,
                    duration: const Duration(milliseconds: 500),
                    child: Container(height: 2, color: Colors.white)
                        .animate(onPlay: (controller) => controller.repeat())
                        .moveY(
                          begin: -100,
                          end: 300,
                          curve: Curves.easeInOut,
                          duration: 2.seconds,
                        ),
                  ),
                ),
              ),
            ),
          ),

        if (widget.albumTitle != null &&
            widget.artistName != null &&
            !_isImageError)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: 0.0,
              duration: const Duration(milliseconds: 200),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(
                    widget.isPlaying && widget.showVinylEffect ? 300 : 24,
                  ),
                  bottomRight: Radius.circular(
                    widget.isPlaying && widget.showVinylEffect ? 300 : 24,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 20.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.albumTitle!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.artistName!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (!_isImageLoaded && !_isImageError)
          _buildLoadingIndicator(baseColor),
      ],
    );
  }

  Widget _buildAlbumImage() {
    return CachedNetworkImage(
          imageUrl: widget.albumArtUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(color: Colors.grey.shade200),
          errorWidget: (context, url, error) {
            if (!_isImageError) {
              Future.delayed(Duration.zero, () {
                if (mounted)
                  setState(() {
                    _isImageError = true;
                    _isImageLoaded = true;
                  });
              });
            }
            return Container();
          },
          imageBuilder: (context, imageProvider) {
            if (!_isImageLoaded) {
              Future.delayed(Duration.zero, () {
                if (mounted) setState(() => _isImageLoaded = true);
              });
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            );
          },
        )
        .animate()
        .fadeIn(duration: 800.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.96, 0.96),
          end: const Offset(1.0, 1.0),
          duration: 800.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildPlaceholderImage() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
        gradient: RadialGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.8),
            colorScheme.primaryContainer.withOpacity(0.7),
          ],
          stops: const [0.2, 0.6, 1.0],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.1,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 25,
              itemBuilder:
                  (context, index) => Icon(
                    Icons.music_note,
                    size: 20,
                    color: colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
          Icon(
            Icons.album,
            size: 80,
            color: colorScheme.onPrimaryContainer.withOpacity(0.8),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
            curve: Curves.elasticOut,
            duration: 800.ms,
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final double height = [0.4, 0.7, 1.0, 0.7, 0.4][index];
                final delay = (index * 200).ms;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: Container(
                        width: 4,
                        height: 30 * height,
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimaryContainer.withOpacity(
                            0.6,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )
                      .animate(
                        onPlay:
                            (controller) => controller.repeat(reverse: true),
                      )
                      .scaleY(
                        begin: height,
                        end: height > 0.5 ? height - 0.3 : height + 0.3,
                        duration: 1.seconds,
                        delay: delay,
                        curve: Curves.easeInOut,
                      ),
                );
              }),
            ),
          ),

          if (widget.albumTitle != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                widget.albumTitle!,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(Color baseColor) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            widget.isPlaying && widget.showVinylEffect ? 300 : 24,
          ),
          color: Colors.grey.withOpacity(0.15),
        ),
        child: Center(
          child: SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
                  color: baseColor,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  strokeWidth: 2,
                )
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 1.5.seconds, begin: 0, end: 2 * math.pi),
          ),
        ),
      ),
    );
  }
}
