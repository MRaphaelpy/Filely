import 'package:flutter/material.dart';

class OptionItem {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  final String? subtitle;

  const OptionItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.subtitle,
  });
}

class OptionTile extends StatelessWidget {
  final OptionItem option;

  const OptionTile({Key? key, required this.option}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: option.color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(option.icon, color: option.color),
      ),
      title: Text(option.title),
      subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
      onTap: option.onTap,
    );
  }
}

class CreateOptionsSheet extends StatelessWidget {
  final List<OptionItem> options;
  final String? title;

  const CreateOptionsSheet({Key? key, required this.options, this.title})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              itemBuilder: (context, index) {
                return OptionTile(option: options[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
