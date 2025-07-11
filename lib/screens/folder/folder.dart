import 'dart:io';

import 'package:filely/providers/providers.dart';
import 'package:filely/screens/file_info_screen.dart';
import 'package:filely/screens/folder/widgets/widgets.dart';
import 'package:filely/utils/utils.dart';
import 'package:filely/widgets/file_operation_status_bar.dart';
import 'package:filely/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as pathlib;
import 'package:provider/provider.dart';

import '../../widgets/empty_state.dart';

class Folder extends StatefulWidget {
  final String title;
  final String path;

  const Folder({super.key, required this.title, required this.path});

  @override
  _FolderState createState() => _FolderState();
}

class _FolderState extends State<Folder> with WidgetsBindingObserver {
  late String _currentPath;
  final List<String> _navigationStack = <String>[];

  List<FileSystemEntity> _files = [];
  List<FileSystemEntity> _filteredFiles = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showHidden = false;
  bool _isSearching = false;
  bool _isRecursiveSearch = false;
  bool _isSearchLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentPath = widget.path;
    _navigationStack.add(widget.path);
    _filteredFiles = [];
    _searchController.addListener(_onSearchChanged);
    _loadFiles();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshFiles();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      _showHidden = provider.showHidden;

      final dir = Directory(_currentPath);
      final dirContents = await _getDirectoryContents(dir);

      final filteredFiles = _showHidden
          ? dirContents
          : dirContents
                .where((file) => !pathlib.basename(file.path).startsWith('.'))
                .toList();

      final sortedFiles = FileUtils.sortList(filteredFiles, provider.sort);

      if (mounted) {
        setState(() {
          _files = sortedFiles;
          _filteredFiles = sortedFiles;
          _isLoading = false;
        });
        _applySearchFilter();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = _getErrorMessage(e);
        });
      }

      if (e.toString().contains('Permission denied')) {
        Dialogs.showToast(
          'Permissão negada! Não é possível acessar este diretório!',
        );
        _navigateBack();
      }
    }
  }

  Future<List<FileSystemEntity>> _getDirectoryContents(Directory dir) async {
    try {
      return await dir.list().toList();
    } catch (e) {
      if (e is PathNotFoundException) {
        throw Exception('Diretório não encontrado');
      } else if (e is FileSystemException &&
          e.message.contains('Permission denied')) {
        throw Exception('Permissão negada');
      }
      rethrow;
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Permission denied')) {
      return 'Sem permissão para acessar este diretório';
    } else if (error.toString().contains('Directory not found')) {
      return 'Diretório não encontrado';
    } else {
      return 'Erro ao carregar arquivos: ${error.toString()}';
    }
  }

  void _refreshFiles() {
    _loadFiles();
  }

  void _onSearchChanged() {
    _applySearchFilter();
  }

  void _applySearchFilter() async {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _filteredFiles = _files;
        _isSearching = false;
        _isSearchLoading = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchLoading = _isRecursiveSearch;
    });

    List<FileSystemEntity> searchResults = [];

    if (_isRecursiveSearch) {
      searchResults = await _performRecursiveSearch(query);
    } else {
      searchResults = _files.where((file) {
        final fileName = pathlib.basename(file.path).toLowerCase();
        return fileName.contains(query);
      }).toList();
    }

    setState(() {
      _filteredFiles = searchResults;
      _isSearchLoading = false;
    });
  }

  Future<List<FileSystemEntity>> _performRecursiveSearch(String query) async {
    final List<FileSystemEntity> results = [];

    try {
      await _searchInDirectory(_currentPath, query, results, 0);
    } catch (e) {
      print('Erro na busca recursiva: $e');
    }

    return results;
  }

  Future<void> _searchInDirectory(
    String dirPath,
    String query,
    List<FileSystemEntity> results,
    int depth,
  ) async {
    if (depth > 3) return;

    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) return;

      final entities = dir.listSync();

      for (final entity in entities) {
        final fileName = pathlib.basename(entity.path).toLowerCase();
        if (fileName.contains(query)) {
          results.add(entity);
        }

        if (entity is Directory &&
            !pathlib.basename(entity.path).startsWith('.')) {
          await _searchInDirectory(entity.path, query, results, depth + 1);
        }

        if (results.length >= 100) break;
      }
    } catch (e) {}
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredFiles = _files;
        _searchFocusNode.unfocus();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _isSearching = false;
      _isRecursiveSearch = false;
      _isSearchLoading = false;
      _filteredFiles = _files;
    });
  }

  void _navigateBack() {
    if (_navigationStack.length <= 1) {
      Navigator.pop(context);
      return;
    }

    _navigationStack.removeLast();
    _currentPath = _navigationStack.last;
    _loadFiles();
  }

  void _navigateToPath(String newPath) {
    _navigationStack.add(newPath);
    _currentPath = newPath;
    _loadFiles();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: _navigationStack.length <= 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _navigationStack.length > 1) {
          _navigateBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
          elevation: 2,
          title: _isSearching
              ? Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Buscar arquivos...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                _isRecursiveSearch
                                    ? Icons.folder_open
                                    : Icons.folder,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isRecursiveSearch = !_isRecursiveSearch;
                                });
                                _applySearchFilter();
                              },
                              tooltip: _isRecursiveSearch
                                  ? 'Buscar apenas nesta pasta'
                                  : 'Buscar em subpastas',
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: _clearSearch,
                              ),
                          ],
                        ),
                      ),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    if (_isRecursiveSearch)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Buscando em subpastas...',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.title),
                    Text(
                      _currentPath,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
          bottom: PathBar(
            paths: _navigationStack,
            icon: widget.path.toString().contains('emulated')
                ? Icons.smartphone
                : Icons.sd_card,
            onChanged: (index) {
              _currentPath = _navigationStack[index];
              if (_navigationStack.length > index + 1) {
                _navigationStack.removeRange(
                  index + 1,
                  _navigationStack.length,
                );
              }
              _loadFiles();
            },
          ),
          actions: <Widget>[
            IconButton(
              onPressed: _toggleSearch,
              tooltip: 'Buscar arquivos',
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: _isSearching ? theme.colorScheme.primary : null,
              ),
            ),
            Consumer<FileOperationsProvider>(
              builder: (context, operationsProvider, child) {
                if (operationsProvider.hasPendingOperation) {
                  return IconButton(
                    onPressed: operationsProvider.isProcessing
                        ? null
                        : _pasteFile,
                    tooltip: 'Colar',
                    icon: Icon(
                      Icons.content_paste,
                      color: operationsProvider.isProcessing
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                          : theme.colorScheme.primary,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              onPressed: () async {
                final provider = Provider.of<CategoryProvider>(
                  context,
                  listen: false,
                );
                provider.toggleHiddenFiles();
                _showHidden = provider.showHidden;
                _refreshFiles();
              },
              tooltip: 'Mostrar arquivos ocultos',
              icon: Icon(
                _showHidden ? Icons.visibility : Icons.visibility_off,
                color: _showHidden ? theme.colorScheme.primary : null,
              ),
            ),
            IconButton(
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  builder: (context) => SortSheet(),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                );
                _refreshFiles();
              },
              tooltip: 'Ordenar por',
              icon: const Icon(Icons.sort),
            ),
          ],
        ),
        body: _buildBody(theme),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddDialog(_currentPath),
          tooltip: 'Adicionar',
          child: const Icon(Icons.add),
          backgroundColor: theme.colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CustomLoader());
    }

    if (_hasError) {
      return _buildErrorView(theme);
    }

    return Column(
      children: [
        const FileOperationStatusBar(),
        Expanded(
          child: _isSearchLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomLoader(),
                      SizedBox(height: 16),
                      Text('Buscando em subpastas...'),
                    ],
                  ),
                )
              : _filteredFiles.isEmpty
              ? _isSearching
                    ? _buildNoSearchResultsView(theme)
                    : _buildEmptyView(theme)
              : RefreshIndicator(
                  onRefresh: () async => _refreshFiles(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 8,
                      top: 8,
                      bottom: 80,
                    ),
                    itemCount: _filteredFiles.length,
                    itemBuilder: (BuildContext context, int index) {
                      final file = _filteredFiles[index];
                      return _buildFileItem(file, theme);
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return CustomDivider();
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildErrorView(ThemeData theme) {
    return EmptyState(
      icon: Icons.error_outline,
      iconSize: 60,
      iconColor: theme.colorScheme.error,
      title: _errorMessage,
      subtitle: null,
      titleStyle: theme.textTheme.titleMedium,
    );
  }

  Widget _buildEmptyView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Pasta vazia',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione arquivos ou pastas com o botão +',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResultsView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum arquivo encontrado',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente buscar com outros termos',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear),
            label: const Text('Limpar busca'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(FileSystemEntity file, ThemeData theme) {
    final bool isDirectory = FileSystemEntity.isDirectorySync(file.path);

    if (isDirectory) {
      return DirectoryItem(
        file: file,
        tap: () => _navigateToPath(file.path),
        popTap: (v) async {
          if (v == 0) {
            _showRenameDialog(file.path, 'dir');
          } else if (v == 1) {
            _showDeleteDialog(true, file);
          } else if (v == 2) {
            _copyFile(file.path);
          } else if (v == 3) {
            _cutFile(file.path);
          } else if (v == 4) {
            _showFileInfo(file.path);
          }
        },
      );
    }

    return FileItem(
      file: file,
      popTap: (v) async {
        if (v == 0) {
          _showRenameDialog(file.path, 'file');
        } else if (v == 1) {
          _showDeleteDialog(false, file);
        } else if (v == 2) {
          _copyFile(file.path);
        } else if (v == 3) {
          _cutFile(file.path);
        } else if (v == 4) {
          _showFileInfo(file.path);
        }
      },
    );
  }

  Future<void> _showDeleteDialog(
    bool isDirectory,
    FileSystemEntity file,
  ) async {
    final fileName = pathlib.basename(file.path);
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Excluir ${isDirectory ? 'pasta' : 'arquivo'}?'),
          content: Text(
            'Tem certeza que deseja excluir "$fileName"? Esta ação não pode ser desfeita.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('EXCLUIR'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _deleteFile(isDirectory, file);
    }
  }

  Future<void> _deleteFile(bool isDirectory, FileSystemEntity file) async {
    try {
      if (isDirectory) {
        await Directory(file.path).delete(recursive: true);
      } else {
        await File(file.path).delete(recursive: true);
      }
      Dialogs.showToast('Exclusão bem sucedida');
      _refreshFiles();
    } catch (e) {
      if (e.toString().contains('Permission denied')) {
        Dialogs.showToast(
          'Sem permissão para modificar este dispositivo de armazenamento!',
        );
      } else {
        Dialogs.showToast('Erro ao excluir: ${e.toString()}');
      }
    }
  }

  Future<void> _showAddDialog(String path) async {
    await showDialog(
      context: context,
      builder: (context) => AddFileDialog(path: path),
    );
    _refreshFiles();
  }

  Future<void> _showRenameDialog(String path, String type) async {
    await showDialog(
      context: context,
      builder: (context) => RenameFileDialog(path: path, type: type),
    );
    _refreshFiles();
  }

  void _copyFile(String filePath) {
    final provider = Provider.of<FileOperationsProvider>(
      context,
      listen: false,
    );
    provider.copyFile(filePath);

    final fileName = pathlib.basename(filePath);
    Dialogs.showToast('$fileName copiado');
  }

  void _cutFile(String filePath) {
    final provider = Provider.of<FileOperationsProvider>(
      context,
      listen: false,
    );
    provider.cutFile(filePath);

    final fileName = pathlib.basename(filePath);
    Dialogs.showToast('$fileName recortado');
  }

  void _showFileInfo(String filePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FileInfoScreen(filePath: filePath),
      ),
    );
  }

  Future<void> _pasteFile() async {
    final provider = Provider.of<FileOperationsProvider>(
      context,
      listen: false,
    );

    if (!provider.hasPendingOperation) {
      Dialogs.showToast('Nenhuma operação pendente');
      return;
    }

    try {
      final success = await provider.pasteFile(_currentPath);
      if (success) {
        Dialogs.showToast('Arquivo colado com sucesso');
        _refreshFiles();
      }
    } catch (e) {
      if (e.toString().contains('Permission denied')) {
        Dialogs.showToast('Sem permissão para colar neste local');
      } else {
        Dialogs.showToast('Erro ao colar arquivo: ${e.toString()}');
      }
    }
  }
}
