import 'package:filely/providers/providers.dart';
import 'package:filely/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class SortSheet extends StatelessWidget {
  const SortSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSheetHeader(theme),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'ORDENAR POR',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildSortOptionsList(context, categoryProvider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetHeader(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSortOptionsList(
    BuildContext context,
    CategoryProvider categoryProvider,
  ) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;

    return ListView.builder(
      itemCount: Constants.sortList.length,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemBuilder: (context, index) {
        final isSelected = index == categoryProvider.sort;

        return _SortOptionTile(
          title: Constants.sortList[index],
          isSelected: isSelected,
          selectedColor: selectedColor,
          onTap: () => _selectSortOption(context, index),
        );
      },
    );
  }

  Future<void> _selectSortOption(BuildContext context, int index) async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    HapticFeedback.lightImpact();

    await categoryProvider.setSort(index);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

class _SortOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.title,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            dense: true,
            title: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? selectedColor : theme.colorScheme.onSurface,
              ),
            ),
            trailing: AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.check_circle_rounded,
                color: selectedColor,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
