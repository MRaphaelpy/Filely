import 'package:flutter/material.dart';

class FilePopup extends StatelessWidget {
  final String path;
  final Function popTap;

  FilePopup({Key? key, required this.path, required this.popTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      onSelected: (val) => popTap(val),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(Icons.edit, size: 18),
              SizedBox(width: 8),
              Text('Renomear'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(Icons.delete, size: 18),
              SizedBox(width: 8),
              Text('Excluir'),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.copy, size: 18),
              SizedBox(width: 8),
              Text('Copiar'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(Icons.content_cut, size: 18),
              SizedBox(width: 8),
              Text('Recortar'),
            ],
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 4,
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18),
              SizedBox(width: 8),
              Text('Informações'),
            ],
          ),
        ),
      ],
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).textTheme.titleLarge!.color,
      ),
      color: Theme.of(context).scaffoldBackgroundColor,
      offset: Offset(0, 30),
    );
  }
}
