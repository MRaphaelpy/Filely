import 'package:flutter/material.dart';

class AppBarImageWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;
  final bool immersiveMode;
  final VoidCallback onBackPressed;
  final VoidCallback onMoreOptionsPressed;

  const AppBarImageWidget({
    super.key,
    this.title,
    this.subtitle,
    required this.immersiveMode,
    required this.onBackPressed,
    required this.onMoreOptionsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          immersiveMode
              ? Colors.transparent
              : Theme.of(context).colorScheme.surface,
      elevation: 0,
      centerTitle: false,
      leading: _buildIconButton(
        icon: Icons.arrow_back,
        tooltip: 'Voltar',
        onPressed: onBackPressed,
      ),
      title:
          title != null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          immersiveMode
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            immersiveMode
                                ? Colors.white70
                                : Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              )
              : null,
      actions: [
        _buildIconButton(
          icon: Icons.more_vert,
          tooltip: 'Mais opções',
          onPressed: onMoreOptionsPressed,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: immersiveMode ? Colors.black45 : Colors.transparent,
      ),
      child: IconButton(
        icon: Icon(icon, color: immersiveMode ? Colors.white : null),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
