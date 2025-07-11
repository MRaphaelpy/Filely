import 'dart:io';
import 'package:Filely/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:mime_type/mime_type.dart';
import 'package:intl/intl.dart';
import '../utils/file_utils.dart';
import '../widgets/file_icon.dart';
import '../widgets/empty_state.dart';

class FileInfoScreen extends StatefulWidget {
  final String filePath;

  const FileInfoScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  State<FileInfoScreen> createState() => _FileInfoScreenState();
}

class _FileInfoScreenState extends State<FileInfoScreen> {
  FileSystemEntity? _fileEntity;
  FileStat? _fileStat;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _fileInfo = {};

  @override
  void initState() {
    super.initState();
    _loadFileInfo();
  }

  Future<void> _loadFileInfo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final type = await FileSystemEntity.type(widget.filePath);

      if (type == FileSystemEntityType.file) {
        _fileEntity = File(widget.filePath);
      } else if (type == FileSystemEntityType.directory) {
        _fileEntity = Directory(widget.filePath);
      } else {
        throw Exception('Arquivo ou pasta não encontrado');
      }

      _fileStat = await _fileEntity!.stat();

      await _collectFileInfo();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _collectFileInfo() async {
    final fileName = path.basename(widget.filePath);
    final isDirectory = _fileEntity is Directory;

    _fileInfo = {
      'name': fileName,
      'path': widget.filePath,
      'isDirectory': isDirectory,
      'size': _fileStat!.size,
      'formattedSize': FileUtils.formatBytes(_fileStat!.size, 2),
      'modified': _fileStat!.modified,
      'accessed': _fileStat!.accessed,
      'changed': _fileStat!.changed,
      'mode': _fileStat!.mode,
      'type': _fileStat!.type,
    };

    if (!isDirectory) {
      final extension = path.extension(fileName);
      final mimeType = mime(fileName);

      _fileInfo.addAll({
        'extension': extension.isNotEmpty
            ? extension.substring(1).toUpperCase()
            : 'Sem extensão',
        'mimeType': mimeType ?? 'Desconhecido',
        'basename': path.basenameWithoutExtension(fileName),
      });
    } else {
      await _collectDirectoryInfo();
    }

    _fileInfo.addAll({
      'permissions': _getPermissionsString(_fileStat!.mode),
      'readable': _fileStat!.mode & 0x100 != 0,
      'writable': _fileStat!.mode & 0x080 != 0,
      'executable': _fileStat!.mode & 0x040 != 0,
    });

    _fileInfo.addAll({
      'parentDirectory': path.dirname(widget.filePath),
      'absolutePath': path.absolute(widget.filePath),
      'isHidden': fileName.startsWith('.'),
    });
  }

  Future<void> _collectDirectoryInfo() async {
    try {
      final directory = _fileEntity as Directory;
      final contents = await directory.list().toList();

      int fileCount = 0;
      int directoryCount = 0;
      int totalSize = 0;

      for (final entity in contents) {
        if (entity is File) {
          fileCount++;
          try {
            final stat = await entity.stat();
            totalSize += stat.size;
          } catch (e) {}
        } else if (entity is Directory) {
          directoryCount++;
        }
      }

      _fileInfo.addAll({
        'fileCount': fileCount,
        'directoryCount': directoryCount,
        'totalItems': fileCount + directoryCount,
        'directorySize': totalSize,
        'formattedDirectorySize': FileUtils.formatBytes(totalSize, 2),
      });
    } catch (e) {
      _fileInfo.addAll({
        'fileCount': 0,
        'directoryCount': 0,
        'totalItems': 0,
        'directorySize': 0,
        'formattedDirectorySize': '0 B',
        'error': 'Não foi possível acessar o conteúdo da pasta',
      });
    }
  }

  String _getPermissionsString(int mode) {
    String permissions = '';

    permissions += (mode & 0x100) != 0 ? 'r' : '-';
    permissions += (mode & 0x080) != 0 ? 'w' : '-';
    permissions += (mode & 0x040) != 0 ? 'x' : '-';

    permissions += (mode & 0x020) != 0 ? 'r' : '-';
    permissions += (mode & 0x010) != 0 ? 'w' : '-';
    permissions += (mode & 0x008) != 0 ? 'x' : '-';

    permissions += (mode & 0x004) != 0 ? 'r' : '-';
    permissions += (mode & 0x002) != 0 ? 'w' : '-';
    permissions += (mode & 0x001) != 0 ? 'x' : '-';

    return permissions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Informações'), elevation: 2),
      body: _isLoading
          ? const Center(child: CustomLoader())
          : _error != null
          ? _buildErrorView(theme)
          : _buildInfoView(theme),
    );
  }

  Widget _buildErrorView(ThemeData theme) {
    return EmptyState(
      icon: Icons.error_outline,
      iconSize: 64,
      iconColor: theme.colorScheme.error,
      title: 'Erro ao carregar informações',
      subtitle: _error,
      titleStyle: theme.textTheme.titleLarge,
      subtitleStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }

  Widget _buildInfoView(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(theme),
          const SizedBox(height: 24),
          _buildGeneralInfoSection(theme),
          const SizedBox(height: 24),
          if (_fileInfo['isDirectory']) _buildDirectoryInfoSection(theme),
          if (!_fileInfo['isDirectory']) _buildFileInfoSection(theme),
          const SizedBox(height: 24),
          _buildDatesSection(theme),
          const SizedBox(height: 24),
          _buildPermissionsSection(theme),
          const SizedBox(height: 24),
          _buildLocationSection(theme),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (_fileEntity != null)
            FileIcon(file: _fileEntity!, showBorder: false),
          const SizedBox(height: 16),
          Text(
            _fileInfo['name'] ?? '',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _fileInfo['isDirectory'] ? 'Pasta' : 'Arquivo',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoSection(ThemeData theme) {
    return _buildSection(theme, 'Informações Gerais', Icons.info_outline, [
      _buildInfoRow('Tamanho', _fileInfo['formattedSize']),
      if (_fileInfo['isDirectory'] && _fileInfo['totalItems'] > 0)
        _buildInfoRow('Itens', '${_fileInfo['totalItems']} items'),
      _buildInfoRow(
        'Tipo',
        _fileInfo['isDirectory'] ? 'Pasta' : _fileInfo['extension'],
      ),
      if (!_fileInfo['isDirectory'] && _fileInfo['mimeType'] != 'Desconhecido')
        _buildInfoRow('Tipo MIME', _fileInfo['mimeType']),
    ]);
  }

  Widget _buildDirectoryInfoSection(ThemeData theme) {
    return _buildSection(theme, 'Conteúdo da Pasta', Icons.folder_outlined, [
      _buildInfoRow('Arquivos', '${_fileInfo['fileCount']}'),
      _buildInfoRow('Pastas', '${_fileInfo['directoryCount']}'),
      _buildInfoRow('Total de itens', '${_fileInfo['totalItems']}'),
      if (_fileInfo['directorySize'] > 0)
        _buildInfoRow('Tamanho total', _fileInfo['formattedDirectorySize']),
      if (_fileInfo['error'] != null)
        _buildInfoRow('Erro', _fileInfo['error'], isError: true),
    ]);
  }

  Widget _buildFileInfoSection(ThemeData theme) {
    return _buildSection(
      theme,
      'Detalhes do Arquivo',
      Icons.description_outlined,
      [
        _buildInfoRow('Nome base', _fileInfo['basename']),
        _buildInfoRow('Extensão', _fileInfo['extension']),
        _buildInfoRow('Tipo MIME', _fileInfo['mimeType']),
        _buildInfoRow('Tamanho em bytes', '${_fileInfo['size']} bytes'),
      ],
    );
  }

  Widget _buildDatesSection(ThemeData theme) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');

    return _buildSection(theme, 'Datas', Icons.access_time, [
      _buildInfoRow('Modificado', dateFormat.format(_fileInfo['modified'])),
      _buildInfoRow('Acessado', dateFormat.format(_fileInfo['accessed'])),
      _buildInfoRow('Alterado', dateFormat.format(_fileInfo['changed'])),
    ]);
  }

  Widget _buildPermissionsSection(ThemeData theme) {
    return _buildSection(theme, 'Permissões', Icons.security, [
      _buildInfoRow('Permissões', _fileInfo['permissions']),
      _buildInfoRow('Leitura', _fileInfo['readable'] ? 'Permitida' : 'Negada'),
      _buildInfoRow('Escrita', _fileInfo['writable'] ? 'Permitida' : 'Negada'),
      _buildInfoRow(
        'Execução',
        _fileInfo['executable'] ? 'Permitida' : 'Negada',
      ),
      _buildInfoRow('Modo (octal)', '0${_fileInfo['mode'].toRadixString(8)}'),
    ]);
  }

  Widget _buildLocationSection(ThemeData theme) {
    return _buildSection(theme, 'Localização', Icons.folder_open, [
      _buildInfoRow('Pasta pai', _fileInfo['parentDirectory'], copyable: true),
      _buildInfoRow(
        'Caminho completo',
        _fileInfo['absolutePath'],
        copyable: true,
      ),
      _buildInfoRow('Arquivo oculto', _fileInfo['isHidden'] ? 'Sim' : 'Não'),
    ]);
  }

  Widget _buildSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool copyable = false,
    bool isError = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isError
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (copyable)
                  IconButton(
                    onPressed: () => _copyToClipboard(value),
                    icon: Icon(
                      Icons.copy,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: const EdgeInsets.all(4),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copiado para a área de transferência'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
