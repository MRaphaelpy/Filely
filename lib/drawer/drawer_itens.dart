import 'package:flutter/material.dart';

class DrawerItens extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int index;
  final Function(int) onTap;

  const DrawerItens({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.index,
    required this.onTap,
  });

  @override
  State<DrawerItens> createState() => _DrawerItensState();
}

class _DrawerItensState extends State<DrawerItens> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedIndex == widget.index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: Material(
        color: isSelected ? colorScheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {
            setState(() {
              _selectedIndex = widget.index;
            });
            widget.onTap(widget.index);
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
             
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? colorScheme.secondary
                            : colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color:
                        isSelected
                            ? colorScheme.onSecondary
                            : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
          
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color:
                              isSelected
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              isSelected
                                  ? colorScheme.onSecondaryContainer
                                      .withOpacity(0.8)
                                  : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
           
                if (isSelected)
                  Icon(Icons.circle, size: 8, color: colorScheme.secondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
