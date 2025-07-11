import 'package:Filely/models/FileOperationType.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/file_operations_provider.dart';

class FileOperationStatusBar extends StatelessWidget {
  const FileOperationStatusBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FileOperationsProvider>(
      builder: (context, provider, child) {
        if (!provider.hasPendingOperation) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final operationInfo = provider.getPendingOperationInfo();

        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                provider.pendingOperation!.type == FileOperationType.copy
                    ? Icons.copy
                    : Icons.content_cut,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      operationInfo ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Toque em "Colar" para concluir a operação',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: provider.cancelOperation,
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
