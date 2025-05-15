import 'package:flutter/material.dart';

class PermissionWaitingView extends StatelessWidget {
  final VoidCallback onRetry;

  const PermissionWaitingView({required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Aguardando permissão de acesso...'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}
