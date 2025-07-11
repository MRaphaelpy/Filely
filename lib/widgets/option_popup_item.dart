import 'package:flutter/material.dart';
class OptionPopupItem extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const OptionPopupItem({
    super.key,
    required this.text,
    required this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(text),
      onTap: onTap,
      dense: true,
      minLeadingWidth: 0,
    );
  }
}
