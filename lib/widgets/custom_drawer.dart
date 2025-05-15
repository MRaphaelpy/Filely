import 'package:filely/drawer/drawer_itens.dart';
import 'package:filely/drawer/search_bar_custom.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.only(topRight: Radius.circular(16)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.folder_copy_rounded,
                        color: colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filely Explorer',
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gerencie seus arquivos',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SearchBarCustom(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  'ARQUIVOS',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(child: Divider(color: colorScheme.outlineVariant)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 8),
              children: [
                DrawerItens(
                  icon: Icons.folder_rounded,
                  title: 'Meus Arquivos',
                  subtitle: 'Arquivos armazenados localmente',
                  index: 0,
                  onTap: (index) {
                    setState(() {});
                  },
                ),
                DrawerItens(
                  icon: Icons.download_rounded,
                  title: 'Downloads',
                  subtitle: 'Arquivos baixados da internet',
                  index: 1,
                  onTap: (index) {
                    setState(() {});
                  },
                ),
                DrawerItens(
                  icon: Icons.image_rounded,
                  title: 'Images',
                  subtitle: 'Fotos e imagens',
                  index: 2,
                  onTap: (index) {
                    setState(() {});
                  },
                ),
                DrawerItens(
                  icon: Icons.video_library_rounded,
                  title: 'Vídeos',
                  subtitle: 'Vídeos',
                  index: 3,
                  onTap: (index) {
                    setState(() {});
                  },
                ),
                DrawerItens(
                  icon: Icons.music_note_rounded,
                  title: 'Musica',
                  subtitle: 'Músicas e áudios',
                  index: 4,
                  onTap: (index) {
                    setState(() {});
                  },
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'OPCÕES',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Divider(color: colorScheme.outlineVariant),
                      ),
                    ],
                  ),
                ),
                DrawerItens(
                  icon: Icons.star_rounded,
                  title: 'Favoritos',
                  subtitle: 'Seus arquivos favoritos',
                  index: 5,
                  onTap: (index) {
                    setState(() {});
                  },
                ),
                DrawerItens(
                  icon: Icons.settings_rounded,
                  title: 'Configurações',
                  subtitle: 'Ajustes do aplicativo',
                  index: 6,
                  onTap: (index) {
                    setState(() {});
                    Navigator.pop(context);
                  },
                ),
                DrawerItens(
                  icon: Icons.help_rounded,
                  title: 'Ajuda',
                  subtitle: 'Suporte e perguntas frequentes',
                  index: 7,
                  onTap: (index) {
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'App Version 1.0.0',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}
