import 'dart:io';
import 'package:filely/screens/folder/widgets/functions.dart';
import 'package:filely/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as pathlib;

class RenameFileDialog extends StatefulWidget {
  final String path;
  final String type;

  const RenameFileDialog({Key? key, required this.path, required this.type})
    : super(key: key);

  @override
  _RenameFileDialogState createState() => _RenameFileDialogState();
}

class _RenameFileDialogState extends State<RenameFileDialog> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _originalName = '';
  String _extension = '';
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final fullName = pathlib.basename(widget.path);

    if (widget.type == 'file') {
      final lastDotIndex = fullName.lastIndexOf('.');
      if (lastDotIndex > 0) {
        _originalName = fullName.substring(0, lastDotIndex);
        _extension = fullName.substring(lastDotIndex);
      } else {
        _originalName = fullName;
        _extension = '';
      }
    } else {
      _originalName = fullName;
    }

    _nameController.text = _originalName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _nameController.text.length,
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _renameItem() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'O nome não pode estar vazio';
      });
      return;
    }

    if (_nameController.text.contains('/') ||
        _nameController.text.contains('\\') ||
        _nameController.text.contains(':') ||
        _nameController.text.contains('*') ||
        _nameController.text.contains('?') ||
        _nameController.text.contains('"') ||
        _nameController.text.contains('<') ||
        _nameController.text.contains('>') ||
        _nameController.text.contains('|')) {
      setState(() {
        _errorMessage = 'Nome contém caracteres inválidos';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    final directory = pathlib.dirname(widget.path);
    final newName =
        _nameController.text + (widget.type == 'file' ? _extension : '');
    final newPath = pathlib.join(directory, newName);

    try {
      if (widget.type == 'file') {
        final file = File(widget.path);
        if (File(newPath).existsSync()) {
          setState(() {
            _errorMessage = 'Já existe um arquivo com este nome';
            _isProcessing = false;
          });
          return;
        }

        await file.rename(newPath);
      } else {
        final dir = Directory(widget.path);
        if (Directory(newPath).existsSync()) {
          setState(() {
            _errorMessage = 'Já existe uma pasta com este nome';
            _isProcessing = false;
          });
          return;
        }

        await dir.rename(newPath);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        if (e.toString().contains('Permission denied')) {
          _errorMessage = 'Permissão negada para este dispositivo';
        } else {
          _errorMessage = 'Erro ao renomear: ${e.toString()}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFile = widget.type == 'file';
    final iconData = isFile ? getFileIcon(_extension) : Icons.folder_rounded;
    final iconColor = isFile
        ? getFileColor(theme, _extension)
        : Colors.amber.shade700;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Renomear ${isFile ? "arquivo" : "pasta"}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        pathlib.basename(widget.path),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: 'Novo nome',
                hintText: 'Digite o novo nome',
                errorText: _errorMessage,
                prefixIcon: const Icon(Icons.edit_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                suffixText: isFile ? _extension : null,
                suffixStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              style: theme.textTheme.bodyLarge,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _renameItem(),
              enabled: !_isProcessing,
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isProcessing
                      ? null
                      : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                ElevatedButton(
                  onPressed: _isProcessing ? null : _renameItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CustomLoader(
                            primaryColor: theme.colorScheme.onPrimary,
                            secondaryColor: theme.colorScheme.onSecondary,
                          ),
                        )
                      : const Text('Renomear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
