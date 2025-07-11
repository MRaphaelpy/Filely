import 'package:filely/screens/folder/folder.dart';
import 'package:filely/utils/color_extensions.dart';
import 'package:filely/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class StorageItem extends StatelessWidget {
  final double percent;
  final String title;
  final String path;
  final Color color;
  final IconData icon;
  final int usedSpace;
  final int totalSpace;
  const StorageItem({
    super.key,
    required this.percent,
    required this.title,
    required this.path,
    required this.color,
    required this.icon,
    required this.usedSpace,
    required this.totalSpace,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToFolder(context),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStorageIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStorageInfo(textTheme, theme),
              const SizedBox(height: 8),
              _buildStorageBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStorageIcon() {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
      ),
      child: Center(child: Icon(icon, color: color, size: 24)),
    );
  }

  Widget _buildStorageInfo(TextTheme textTheme, ThemeData theme) {
    final usedSpaceFormatted = FileUtils.formatBytes(usedSpace, 2);
    final totalSpaceFormatted = FileUtils.formatBytes(totalSpace, 2);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$usedSpaceFormatted / $totalSpaceFormatted',
          style: textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          '${(percent * 100).toStringAsFixed(0)}%',
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStorageBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearPercentIndicator(
        padding: EdgeInsets.zero,
        lineHeight: 8,
        animation: true,
        animationDuration: 800,
        backgroundColor: Colors.grey.withValues(alpha: 0.2),
        percent: percent.clamp(0.0, 1.0),
        progressColor: color,
        barRadius: const Radius.circular(8),
      ),
    );
  }

  void _navigateToFolder(BuildContext context) {
    Navigate.pushPage(context, Folder(title: title, path: path));
  }
}
