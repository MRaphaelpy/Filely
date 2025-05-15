import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:async';

class ImageViewerM3 extends StatefulWidget {
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final bool showAppBar;
  final bool enableGestures;
  final Color? backgroundColor;
  final bool immersiveMode;
  final Widget? errorWidget;
  final Widget? loadingWidget;

  const ImageViewerM3({
    super.key,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.showAppBar = true,
    this.enableGestures = true,
    this.backgroundColor,
    this.immersiveMode = false,
    this.errorWidget,
    this.loadingWidget,
  });

  @override
  State<ImageViewerM3> createState() => _ImageViewerM3State();
}

class _ImageViewerM3State extends State<ImageViewerM3>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  late ValueNotifier<bool> _isControlsVisible;
  Timer? _controlsTimer;

  bool _isLoading = true;
  bool _hasError = false;

  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
      if (_animation != null) {
        _transformationController.value = _animation!.value;
      }
    });

    _isControlsVisible = ValueNotifier<bool>(true);

    if (widget.immersiveMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_transformationController.value != Matrix4.identity()) {
      _resetTransformation();
    } else {
      final position = details.localPosition;
      const double scale = 2.5;

      final Matrix4 matrix =
          Matrix4.identity()
            ..translate(-position.dx * (scale - 1), -position.dy * (scale - 1))
            ..scale(scale);

      _animateTransformation(matrix);
    }
  }

  void _resetTransformation() {
    _animateTransformation(Matrix4.identity());
  }

  void _animateTransformation(Matrix4 targetMatrix) {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: targetMatrix,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutExpo),
    );

    _animationController.forward(from: 0);
  }

  void _toggleControls() {
    _isControlsVisible.value = !_isControlsVisible.value;
    _resetControlsTimer();
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();

    if (_isControlsVisible.value && widget.immersiveMode) {
      _controlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _isControlsVisible.value = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    _isControlsVisible.dispose();
    _controlsTimer?.cancel();

    if (widget.immersiveMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: widget.showAppBar ? _buildAppBar(context) : null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: widget.immersiveMode ? _toggleControls : null,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              onInteractionEnd: (_) => _resetControlsTimer(),
              panEnabled: widget.enableGestures,
              scaleEnabled: widget.enableGestures,
              child: Center(child: _buildImage()),
            ),
          ),
          if (widget.enableGestures)
            Positioned.fill(
              child: GestureDetector(
                onDoubleTapDown: _handleDoubleTap,
                behavior: HitTestBehavior.translucent,
              ),
            ),
          _buildFloatingControls(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor:
          widget.immersiveMode
              ? Colors.transparent
              : Theme.of(context).colorScheme.surface,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Voltar',
      ),
      title:
          widget.title != null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title!,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              )
              : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: () {
            // Implementar compartilhamento
          },
          tooltip: 'Compartilhar',
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showOptionsBottomSheet(context),
          tooltip: 'Mais opções',
        ),
      ],
    );
  }

  Widget _buildImage() {
    final file = File(widget.imageUrl);

    return Hero(
      tag: widget.imageUrl,
      child: Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ??
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Não foi possível carregar a imagem',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () {
                        setState(() {});
                      },
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
        },
      ),
    );
  }

  Widget _buildFloatingControls(BuildContext context) {
    if (!widget.immersiveMode) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: _isControlsVisible,
      builder: (context, isVisible, child) {
        return AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: child,
        );
      },
      child:
          _hasError
              ? const SizedBox.shrink()
              : Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _dominantColor ?? Colors.black87,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.zoom_out_map,
                          onPressed: _resetTransformation,
                        ),
                        _buildControlButton(
                          icon: Icons.share_outlined,
                          onPressed: () {
                            // Implementar compartilhamento
                          },
                        ),
                        _buildControlButton(
                          icon: Icons.download_outlined,
                          onPressed: () {
                            // Implementar download
                          },
                        ),
                        _buildControlButton(
                          icon: Icons.more_horiz,
                          onPressed: () => _showOptionsBottomSheet(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Salvar imagem'),
                  onTap: () {
                    Navigator.pop(context);
                    // Implementar download
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_outlined),
                  title: const Text('Compartilhar'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }
}
