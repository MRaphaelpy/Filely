// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously
import 'dart:io';
import 'package:filely/fileList/file_list_view.dart';
import 'package:filely/imageViewer/options_bottom_sheet_widget.dart';
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
  final FileSystemController _controller = FileSystemController();
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
      await _controller.init();
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
                        ? EmptyFolderView(onRetry: _controller.init)
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
                            if (!isDirectory) {
                              final file = fileEntity as File;

                              final mediaItem = MediaItem(
                                id: file.path,
                                title: file.uri.pathSegments.last,
                                filePath: file.path,
                                createdAt: file.lastModifiedSync(),
                                description: null,
                                thumbnailPath: null,
                              );

                              showOptionsBottomSheet(
                                context,
                                item: mediaItem,
                                onDelete: (item) {
                                  _controller.deleteFile(
                                    File(item.filePath) as String,
                                  );
                                },
                                onDeleteComplete: () async {
                                  await _controller.listFiles();
                                  setState(() {});
                                },
                              );
                            }
                          },
                        );
                  },
                ),
      ),
    );
  }
}
