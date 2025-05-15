import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:filely/utils/file_icon_helper.dart';
import 'package:filely/utils/thumbnail_manager.dart';

class LeadingThumbnail extends StatelessWidget {
  final FileSystemEntity file;
  final bool isDirectory;
  final String fileExtension;
  final ThumbnailManager _thumbnailManager = ThumbnailManager();

  LeadingThumbnail({
    super.key,
    required this.file,
    required this.isDirectory,
    required this.fileExtension,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'thumbnail_${file.path}',
      child: Container(
        width: 56,
        height: 56,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: FutureBuilder<Widget>(
            future: _buildThumbnailWidget(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return _AnimatedThumbnail(child: snapshot.data!);
              } else {
                return _AnimatedThumbnail(
                  child: _buildPlaceholderWidget(context),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderWidget(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceVariant.withOpacity(0.7),
      ),
      child: Center(
        child: FileIconHelper.getIconForFileType(isDirectory, fileExtension),
      ),
    );
  }

  Future<Widget> _buildThumbnailWidget(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    if (isDirectory) {
      return _FolderThumbnail(
        fileExtension: fileExtension,
        colorScheme: colorScheme,
      );
    }

    if (_thumbnailManager.isImage(file.path)) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(file.path),
              fit: BoxFit.cover,
              cacheWidth: 200, // Otimização para melhor performance
              errorBuilder: (context, error, stackTrace) {
                return _ErrorThumbnail(fileExtension: fileExtension);
              },
            ),
            // Overlay gradient para tornar os ícones mais visíveis caso a imagem seja clara
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                  ),
                ),
              ),
            ),
            // Pequeno indicador de tipo de arquivo no canto
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.image, size: 12, color: colorScheme.primary),
              ),
            ),
          ],
        ),
      );
    }

    if (_thumbnailManager.isVideo(file.path)) {
      return _VideoThumbnail(
        file: file,
        fileExtension: fileExtension,
        colorScheme: colorScheme,
      );
    }

    if (_thumbnailManager.isAudio(file.path)) {
      return _AudioThumbnail(
        fileExtension: fileExtension,
        colorScheme: colorScheme,
      );
    }

    // Para outros tipos de arquivos
    return _FileTypeThumbnail(
      fileExtension: fileExtension,
      colorScheme: colorScheme,
    );
  }
}

class _AnimatedThumbnail extends StatefulWidget {
  final Widget child;

  const _AnimatedThumbnail({required this.child});

  @override
  State<_AnimatedThumbnail> createState() => _AnimatedThumbnailState();
}

class _AnimatedThumbnailState extends State<_AnimatedThumbnail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}

class _FolderThumbnail extends StatelessWidget {
  final String fileExtension;
  final ColorScheme colorScheme;

  const _FolderThumbnail({
    required this.fileExtension,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          Center(child: FileIconHelper.getIconForFileType(true, fileExtension)),
          // Efeito de brilho no canto
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(24),
                ),
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.3), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final FileSystemEntity file;
  final String fileExtension;
  final ColorScheme colorScheme;

  const _VideoThumbnail({
    required this.file,
    required this.fileExtension,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.tertiary.withOpacity(0.5),
                  colorScheme.tertiaryContainer,
                ],
              ),
            ),
            child: Center(
              child: FileIconHelper.getIconForFileType(false, fileExtension),
            ),
          ),
          // Play icon overlay
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
          ),
          // Tipo de arquivo no canto
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                fileExtension.toUpperCase(),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioThumbnail extends StatelessWidget {
  final String fileExtension;
  final ColorScheme colorScheme;

  const _AudioThumbnail({
    required this.fileExtension,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.secondary.withOpacity(0.5),
            colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Padrão de onda de áudio estilizado
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                  (index) => Container(
                    width: 4,
                    height: 10.0 + (index % 3) * 8,
                    decoration: BoxDecoration(
                      color: colorScheme.onSecondaryContainer.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Ícone central
          Center(
            child: FileIconHelper.getIconForFileType(false, fileExtension),
          ),
        ],
      ),
    );
  }
}

class _FileTypeThumbnail extends StatelessWidget {
  final String fileExtension;
  final ColorScheme colorScheme;

  const _FileTypeThumbnail({
    required this.fileExtension,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _getColorForExtension(fileExtension, colorScheme);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: backgroundColor,
      ),
      child: Stack(
        children: [
          // Padrão de fundo sutil
          Positioned.fill(
            child: CustomPaint(
              painter: _FilePatternPainter(
                color: colorScheme.onSurface.withOpacity(0.05),
              ),
            ),
          ),
          // Ícone do tipo de arquivo
          Center(
            child: FileIconHelper.getIconForFileType(false, fileExtension),
          ),
          // Extensão do arquivo
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  fileExtension.toUpperCase(),
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForExtension(String ext, ColorScheme colorScheme) {
    // Cores personalizadas baseadas na extensão do arquivo
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Colors.red.shade200;
      case 'doc':
      case 'docx':
        return Colors.blue.shade200;
      case 'xls':
      case 'xlsx':
        return Colors.green.shade200;
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade200;
      case 'txt':
        return colorScheme.surfaceVariant;
      case 'zip':
      case 'rar':
      case '7z':
        return Colors.amber.shade200;
      default:
        return colorScheme.surfaceVariant;
    }
  }
}

class _ErrorThumbnail extends StatelessWidget {
  final String fileExtension;

  const _ErrorThumbnail({required this.fileExtension});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.errorContainer.withOpacity(0.5),
      ),
      child: Stack(
        children: [
          Center(
            child: FileIconHelper.getIconForFileType(false, fileExtension),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.error_outline,
              size: 16,
              color: colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilePatternPainter extends CustomPainter {
  final Color color;

  _FilePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Desenha linhas horizontais
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(0, 10 + i * 10),
        Offset(size.width * 0.7, 10 + i * 10),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
