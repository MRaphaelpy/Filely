import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PathBar extends StatefulWidget implements PreferredSizeWidget {
  final List<String> paths;
  final Function(int) onChanged;
  final IconData? icon;

  const PathBar({
    Key? key,
    required this.paths,
    required this.onChanged,
    this.icon,
  }) : super(key: key);

  @override
  State<PathBar> createState() => _PathBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class _PathBarState extends State<PathBar> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    );
    _animationController!.forward();
  }

  @override
  void didUpdateWidget(PathBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paths != widget.paths) {
      _animationController?.reset();
      _animationController?.forward();


      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation!,
      child: Container(
        height: widget.preferredSize.height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(isDark ? 0.2 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
          child: Stack(
            children: [

              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 30,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),


              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 30,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.paths.length * 2 - 1,
                  itemBuilder: (context, index) {
                    if (index % 2 == 0) {
                      final pathIndex = index ~/ 2;
                      return _buildPathItem(context, pathIndex, theme);
                    } else {
                      return _buildSeparator(theme);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathItem(BuildContext context, int index, ThemeData theme) {
    final isSelected = index == widget.paths.length - 1;
    final path = widget.paths[index];
    final accentColor = theme.colorScheme.primary;
    final textColor = theme.colorScheme.onSurface;


    if (index == 0) {
      return _buildRootItem(context, isSelected, accentColor, textColor);
    }


    final pathName = _getPathName(path);

    final bool isLast = index == widget.paths.length - 1;

    return Padding(
      padding: EdgeInsets.only(left: 2.0, right: isLast ? 12.0 : 2.0),
      child: Material(
        color: isSelected ? accentColor.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onChanged(index);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 6.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0 && isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Icon(
                      _getIconForPath(pathName),
                      size: 16,
                      color: accentColor,
                    ),
                  ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 15 : 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? accentColor
                        : textColor.withOpacity(0.75),
                    letterSpacing: isSelected ? 0.2 : 0.0,
                  ),
                  child: Text(pathName),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRootItem(
    BuildContext context,
    bool isSelected,
    Color accentColor,
    Color textColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 2.0),
      child: Material(
        color: isSelected ? accentColor.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onChanged(0);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              widget.icon ?? Icons.smartphone_rounded,
              size: 20,
              color: isSelected ? accentColor : textColor.withOpacity(0.8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }

  String _getPathName(String path) {
    final parts = path.split('/');
    String name = parts.last.isEmpty && parts.length > 1
        ? parts[parts.length - 2]
        : parts.last;


    name = name.replaceAll('_', ' ');


    switch (name.toLowerCase()) {
      case 'dcim':
        return 'Câmera';
      case 'pictures':
      case 'picture':
        return 'Imagens';
      case 'movies':
      case 'videos':
      case 'video':
        return 'Vídeos';
      case 'music':
      case 'audio':
        return 'Músicas';
      case 'documents':
      case 'docs':
        return 'Documentos';
      case 'downloads':
        return 'Downloads';
      default:

        if (name.length > 18) {
          return '${name.substring(0, 15)}...';
        }
        return name;
    }
  }

  IconData _getIconForPath(String pathName) {
    final lowercasePath = pathName.toLowerCase();

    if (lowercasePath.contains('imagens') || lowercasePath.contains('foto')) {
      return Icons.photo_outlined;
    } else if (lowercasePath.contains('vídeo') ||
        lowercasePath.contains('filme')) {
      return Icons.movie_outlined;
    } else if (lowercasePath.contains('música') ||
        lowercasePath.contains('audio')) {
      return Icons.music_note_outlined;
    } else if (lowercasePath.contains('documento')) {
      return Icons.description_outlined;
    } else if (lowercasePath.contains('download')) {
      return Icons.download_outlined;
    } else if (lowercasePath.contains('câmera')) {
      return Icons.camera_alt_outlined;
    } else  {
      return Icons.folder_outlined;
    }
  }
}
