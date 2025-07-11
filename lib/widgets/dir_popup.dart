import 'package:flutter/material.dart';

class DirPopup extends StatelessWidget {
  final String path;

  final Function? popTap;

  final List<PopupMenuItem<int>>? additionalOptions;

  final IconData? customIcon;

  const DirPopup({
    Key? key,
    required this.path,
    this.popTap,
    this.additionalOptions,
    this.customIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: PopupMenuButton<int>(
        onSelected: (val) {
          if (popTap != null) popTap!(val);
        },
        tooltip: 'Opções de pasta',
        position: PopupMenuPosition.under,
        offset: const Offset(0, 10),
        icon: Icon(
          customIcon ?? Icons.more_vert_rounded,
          color: theme.colorScheme.primary,
          size: 22,
        ),
        color: theme.colorScheme.surface,
        elevation: 4,
        splashRadius: 24,
        enableFeedback: true,
        itemBuilder: (context) => [
          _buildPopupMenuItem(
            context,
            0,
            'Renomear',
            Icons.drive_file_rename_outline_rounded,
            theme.colorScheme.primary,
          ),
          _buildPopupMenuItem(
            context,
            1,
            'Excluir',
            Icons.delete_outline_rounded,
            theme.colorScheme.error,
          ),
          ..._buildDivider(),
          _buildPopupMenuItem(
            context,
            2,
            'Copiar',
            Icons.copy_rounded,
            Colors.blue.shade600,
          ),
          _buildPopupMenuItem(
            context,
            3,
            'Recortar',
            Icons.content_cut_rounded,
            Colors.orange.shade600,
          ),
          ..._buildDivider(),
          _buildPopupMenuItem(
            context,
            4,
            'Informações',
            Icons.info_outline_rounded,
            theme.colorScheme.secondary,
          ),
          _buildPopupMenuItem(
            context,
            5,
            'Compartilhar',
            Icons.share_rounded,
            Colors.green.shade600,
          ),
          if (additionalOptions != null) ..._buildDivider(),
          if (additionalOptions != null) ...additionalOptions!,
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  PopupMenuItem<int> _buildPopupMenuItem(
    BuildContext context,
    int value,
    String text,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return PopupMenuItem<int>(
      value: value,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: value == 1 ? theme.colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<int>> _buildDivider() {
    return [const PopupMenuDivider(height: 1)];
  }
}
