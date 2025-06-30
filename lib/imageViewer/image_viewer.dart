import 'package:filely/imageViewer/app_bar_widget.dart';
import 'package:filely/imageViewer/floating_controls_widget.dart';
import 'package:filely/imageViewer/image_widget.dart';
import 'package:filely/imageViewer/options_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';

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

  void _handleImageOptions() {
    final File imageFile = File(widget.imageUrl);

    // Criar um objeto MediaItem com os dados da imagem
    final MediaItem item = MediaItem(
      id: imageFile.path.split('/').last, // Usar o nome do arquivo como ID
      title: widget.title ?? 'Imagem',
      description: widget.subtitle,
      filePath: widget.imageUrl,
      createdAt:
          imageFile.existsSync()
              ? imageFile.lastModifiedSync()
              : DateTime.now(),
      thumbnailPath: null, // Opcional: pode ser o mesmo que filePath
    );

    // Chamar showOptionsBottomSheet com os parâmetros necessários
    showOptionsBottomSheet(
      context,
      item: item,
      onDelete: (deletedItem) {
        // Fechar visualizador após exclusão
        Navigator.of(context).pop();
      },
      onDeleteComplete: () {
        // Opcional: fazer algo depois que a exclusão for concluída
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagem excluída com sucesso')),
        );
      },
    );
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
      appBar:
          widget.showAppBar
              ? AppBarImageWidget(
                title: widget.title,
                subtitle: widget.subtitle,
                immersiveMode: widget.immersiveMode,
                onBackPressed: () => Navigator.of(context).pop(),
                onMoreOptionsPressed:
                    _handleImageOptions, // Usar o método que chama o bottom sheet
              )
              : null,
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
              child: Center(
                child: ImageWidget(
                  imageUrl: widget.imageUrl,
                  errorWidget: widget.errorWidget,
                ),
              ),
            ),
          ),
          if (widget.enableGestures)
            Positioned.fill(
              child: GestureDetector(
                onDoubleTapDown: _handleDoubleTap,
                behavior: HitTestBehavior.translucent,
              ),
            ),
        ],
      ),
    );
  }
}
