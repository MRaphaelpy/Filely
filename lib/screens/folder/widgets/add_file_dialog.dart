import 'dart:io';
import 'package:Filely/shared/shared.dart';
import 'package:Filely/utils/utils.dart';
import 'package:flutter/material.dart';

class AddFileDialog extends StatefulWidget {
  final String path;

  const AddFileDialog({Key? key, required this.path}) : super(key: key);

  @override
  _AddFileDialogState createState() => _AddFileDialogState();
}

class _AddFileDialogState extends State<AddFileDialog> {
  final TextEditingController nameController = TextEditingController();
  bool _isCreating = false;
  String? _errorText;

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _createFolder() async {
    if (nameController.text.isEmpty) {
      setState(() {
        _errorText = 'Por favor, insira um nome para a pasta';
      });
      return;
    }

    setState(() {
      _isCreating = true;
      _errorText = null;
    });

    try {
      final folderPath = '${widget.path}/${nameController.text}';
      final directory = Directory(folderPath);

      if (directory.existsSync()) {
        setState(() {
          _errorText = 'Uma pasta com esse nome já existe.';
          _isCreating = false;
        });
        return;
      }

      await directory.create();
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isCreating = false;
        if (e.toString().contains('Permission denied')) {
          _errorText =
              'Nao foi possível criar a pasta. Verifique as permissões.';
        } else {
          _errorText = 'Um erro ocorreu ao criar a pasta: ${e.toString()}';
        }
      });

      Dialogs.showToast(_errorText ?? 'Falha ao criar pasta');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(top: 24, left: 24, right: 24),
              child: Column(
                children: [
                  Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(36),
                    ),
                    child: Icon(
                      Icons.create_new_folder_rounded,
                      size: 36,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Criar Nova Pasta',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Nome da Pasta',
                  hintText: 'Digite o nome da nova pasta',
                  errorText: _errorText,
                  prefixIcon: Icon(Icons.folder_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.outline,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (_) => _createFolder(),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isCreating
                          ? null
                          : () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: _isCreating
                              ? colorScheme.onSurface.withValues(alpha: 0.38)
                              : colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isCreating ? null : _createFolder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isCreating
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CustomLoader(),
                            )
                          : Text(
                              'Criar Pasta',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
