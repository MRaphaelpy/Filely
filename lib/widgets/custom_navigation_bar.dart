import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final List<Map<String, dynamic>> items;
  final Function(int) onTap;
  final double height;

  const CustomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    this.height = 65,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: NavigationBar(
          height: height,
          elevation: 0,
          selectedIndex: selectedIndex,
          onDestinationSelected: onTap,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          indicatorColor: items[selectedIndex]['color'].withValues(alpha: 0.2),
          backgroundColor: Colors.transparent,
          animationDuration: const Duration(milliseconds: 300),
          destinations: _buildDestinations(),
        ),
      ),
    );
  }

  List<NavigationDestination> _buildDestinations() {
    final List<NavigationDestination> destinations = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isActive = i == selectedIndex;

      destinations.add(
        NavigationDestination(
          icon: Icon(
            isActive ? item['icon'] : item['inactiveIcon'],
            color: isActive ? item['color'] : null,
          ),
          label: item['title'],
        ),
      );
    }

    return destinations;
  }
}
