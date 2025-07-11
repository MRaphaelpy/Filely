import 'dart:io';

import 'package:filely/providers/providers.dart';
import 'package:filely/screens/category.dart';
import 'package:filely/utils/navigate.dart';
import 'package:filely/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentFiles extends StatefulWidget {
  const RecentFiles({super.key});

  @override
  State<RecentFiles> createState() => _RecentFilesState();
}

class _RecentFilesState extends State<RecentFiles> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshRecentFiles();
    });
  }

  Future<void> _refreshRecentFiles() async {
    final provider = Provider.of<CoreProvider>(context, listen: false);
    await provider.getRecentFiles();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Arquivos Recentes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Atualizar',
                  onPressed: _refreshRecentFiles,
                  iconSize: 20,
                ),
              ],
            ),
          ),
          const Divider(),
          _buildRecentFilesList(),
        ],
      ),
    );
  }

  Widget _buildRecentFilesList() {
    return Consumer<CoreProvider>(
      builder: (context, provider, _) {
        if (provider.recentLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  SizedBox(height: 120, width: 120, child: CustomLoader()),
                  const SizedBox(height: 8),
                  Text(
                    'Buscando arquivos recentes...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final validRecentFiles = provider.recentFiles
            .where((file) => file.existsSync())
            .take(5)
            .toList();

        if (validRecentFiles.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: validRecentFiles.length,
              itemBuilder: (context, index) {
                final file = validRecentFiles[index];
                return _buildFileItem(file, index);
              },
            ),
            _buildViewAllButton(provider.recentFiles.length),
          ],
        );
      },
    );
  }

  Widget _buildFileItem(FileSystemEntity file, int index) {
    return Dismissible(
      key: Key('recent_file_${file.path}'),
      background: Container(
        color: Colors.red.shade400,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeFromRecents(file),
      child: Container(
        decoration: BoxDecoration(
          border: index > 0
              ? Border(
                  top: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.2),
                  ),
                )
              : null,
        ),
        child: FileItem(file: file),
      ),
    );
  }

  Widget _buildViewAllButton(int totalCount) {
    if (totalCount <= 5) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToAllRecents(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ver todos os ${totalCount} arquivos recentes',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum arquivo recente encontrado',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Os arquivos que você abrir aparecerão aqui',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeFromRecents(FileSystemEntity file) {
    final provider = Provider.of<CoreProvider>(context, listen: false);
    setState(() {
      provider.recentFiles.removeWhere((f) => f.path == file.path);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Arquivo removido dos recentes'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              provider.recentFiles.add(file);

              provider.recentFiles.sort((a, b) {
                return b.statSync().modified.compareTo(a.statSync().modified);
              });
            });
          },
        ),
        behavior: SnackBarBehavior.floating,
        width: MediaQuery.of(context).size.width * 0.9,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _navigateToAllRecents() {
    Navigate.pushPage(context, Category(title: 'Todos os Arquivos Recentes'));
  }
}
