import 'package:flutter/material.dart';

class EmptyFolderView extends StatelessWidget {
  final VoidCallback onRetry;

  const EmptyFolderView({required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 80, color: Colors.grey),
          const Text('Esta pasta está vazia'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Voltar para o diretório inicial'),
          ),
        ],
      ),
    );
  }
}
