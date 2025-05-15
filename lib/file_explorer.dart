// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:io';
import 'package:filely/fileList/file_list_view.dart';
import 'package:filely/widgets/custom_drawer.dart';
import 'package:filely/widgets/empty_folder_view.dart';
import 'package:filely/widgets/permission_waiting_view.dart';
import 'package:flutter/material.dart';
import 'fileList/file_explorer_controller.dart';
import 'utils/permission_manager.dart';

class FileExplorer extends StatefulWidget {
  const FileExplorer({super.key});

  @override
  _FileExplorerState createState() => _FileExplorerState();
}

class _FileExplorerState extends State<FileExplorer> {
  final FileExplorerController _controller = FileExplorerController();
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _hasPermission = await PermissionManager().ensurePermissions();

    if (_hasPermission) {
      await _controller.initialize();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissão necessária para acessar arquivos'),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (_controller.currentPath.isEmpty || !_controller.canNavigateUp()) {
      return true;
    }
    _controller.navigateUp();
    setState(() {});
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Explorador de Arquivos'),
              if (_controller.currentPath.isNotEmpty)
                Text(
                  _controller.currentPath,
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                if (_hasPermission) {
                  await _controller.listFiles();
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Permissão necessária para atualizar'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : !_hasPermission
                ? PermissionWaitingView(onRetry: _initialize)
                : ValueListenableBuilder<List<FileSystemEntity>>(
                  valueListenable: _controller.filesNotifier,
                  builder: (context, files, _) {
                    return files.isEmpty
                        ? EmptyFolderView(onRetry: _controller.initDirectory)
                        : FileListView(
                          files: files,
                          controller: _controller,
                          onFileTap: (fileEntity, isDirectory) {
                            if (isDirectory) {
                              if (_controller.isNavigationSafe(
                                fileEntity.path,
                              )) {
                                _controller.navigateToDirectory(fileEntity);
                                setState(() {});
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Acesso a este diretório não é permitido',
                                    ),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Arquivo: ${fileEntity.path.split('/').last}',
                                  ),
                                ),
                              );
                            }
                          },
                          onFileLongPress: (fileEntity, isDirectory) {
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              builder: (context) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.drive_file_rename_outline,
                                      ),
                                      title: const Text('Renomear'),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.content_copy),
                                      title: const Text('Copiar'),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.folder_open),
                                      title: const Text('Mover'),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text('Excluir'),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.share),
                                      title: const Text('Compartilhar'),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.info_outline),
                                      title: const Text('Propriedades'),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                  },
                ),
      ),
    );
  }
}
