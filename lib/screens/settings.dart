import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:Filely/l10n/app_localizations.dart';
import 'package:Filely/providers/providers.dart';
import 'package:Filely/screens/about.dart';
import 'package:Filely/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int sdkVersion = 0;
  String appVersion = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    setState(() => isLoading = true);

    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      sdkVersion = androidInfo.version.sdkInt;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      appVersion = 'Desconhecida';
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(l10n.settingsTitle),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(l10n.appearance, Icons.palette_outlined),
                  _buildThemeSettings(colorScheme, l10n),

                  const SizedBox(height: 24),
                  _buildSectionHeader(l10n.language, Icons.language_outlined),
                  _buildLanguageSettings(colorScheme, l10n),

                  const SizedBox(height: 24),
                  _buildSectionHeader(l10n.files, Icons.folder_outlined),
                  _buildFileSettings(colorScheme, l10n),

                  const SizedBox(height: 24),
                  _buildSectionHeader(l10n.aboutApp, Icons.info_outline),
                  _buildAboutSettings(colorScheme, l10n),

                  if (!isLoading) ...[
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        '${l10n.version} $appVersion',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSettings(ColorScheme colorScheme, AppLocalizations l10n) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDarkMode = appProvider.isDarkTheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: Text(l10n.toggleTheme),
            subtitle: Text(isDarkMode ? l10n.darkTheme : l10n.lightTheme),
            leading: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: isDarkMode ? Colors.amber : Colors.orange,
            ),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                appProvider.toggleTheme();
              },
              activeColor: colorScheme.primary,
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            title: Text(
              l10n.colorCustomization,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            subtitle: Text(
              l10n.colorCustomizationSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            leading: const Icon(Icons.color_lens_outlined),
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFileSettings(ColorScheme colorScheme, AppLocalizations l10n) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(l10n.showHiddenFiles),
            subtitle: Text(l10n.showHiddenFilesSubtitle),
            secondary: Icon(
              categoryProvider.showHidden
                  ? Icons.visibility
                  : Icons.visibility_off,
              color: categoryProvider.showHidden ? colorScheme.primary : null,
            ),
            value: categoryProvider.showHidden,
            onChanged: (value) {
              categoryProvider.setHidden(value);
            },
            activeColor: colorScheme.primary,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            title: Text(l10n.sortFilesBy),
            subtitle: Text(_getSortMethodText(categoryProvider.sort, l10n)),
            leading: const Icon(Icons.sort),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showSortOptionsDialog(categoryProvider, l10n),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            title: Text(l10n.clearCache),
            subtitle: Text(l10n.clearCacheSubtitle),
            leading: const Icon(Icons.delete_outline),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              await categoryProvider.clearCache();
              _showSnackBar(l10n.cacheCleared);
            },
          ),
        ],
      ),
    );
  }

  String _getSortMethodText(int sortMethod, AppLocalizations l10n) {
    switch (sortMethod) {
      case 0:
        return l10n.sortByName;
      case 1:
        return l10n.sortByNameDesc;
      case 2:
        return l10n.sortByDateNew;
      case 3:
        return l10n.sortByDateOld;
      case 4:
        return l10n.sortBySizeLarge;
      case 5:
        return l10n.sortBySizeSmall;
      case 6:
        return l10n.sortByType;
      default:
        return l10n.sortByName;
    }
  }

  Future<void> _showSortOptionsDialog(
    CategoryProvider provider,
    AppLocalizations l10n,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.sortBy),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSortOption(provider, l10n.sortByName, 0),
                _buildSortOption(provider, l10n.sortByNameDesc, 1),
                _buildSortOption(provider, l10n.sortByDateNew, 2),
                _buildSortOption(provider, l10n.sortByDateOld, 3),
                _buildSortOption(provider, l10n.sortBySizeLarge, 4),
                _buildSortOption(provider, l10n.sortBySizeSmall, 5),
                _buildSortOption(provider, l10n.sortByType, 6),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSortOption(CategoryProvider provider, String title, int value) {
    return RadioListTile<int>(
      title: Text(title),
      value: value,
      groupValue: provider.sort,
      onChanged: (newValue) {
        provider.setSort(newValue!);
        Navigator.pop(context);
      },
      dense: true,
    );
  }

  Widget _buildAboutSettings(ColorScheme colorScheme, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: Text(l10n.aboutFilely),
            subtitle: Text(l10n.aboutFilelySubtitle),
            leading: const Icon(Icons.info_outline),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigate.pushPage(context, About()),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            title: Text(l10n.rateApp),
            subtitle: Text(l10n.rateAppSubtitle),
            leading: const Icon(Icons.star_outline),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _launchUrl('market://details?id=com.mraphaelpy.filely'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            title: Text(l10n.openSourceLicenses),
            subtitle: Text(l10n.openSourceLicensesSubtitle),
            leading: const Icon(Icons.account_balance_outlined),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Filely',
              applicationVersion: appVersion,
              applicationIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 48,
                  height: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSettings(
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(languageProvider.currentLanguageName),
            leading: const Icon(Icons.language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguageDialog(languageProvider, l10n),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(
    LanguageProvider provider,
    AppLocalizations l10n,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: provider.supportedLanguages.map((language) {
                return RadioListTile<String>(
                  title: Row(
                    children: [
                      Text(language['flag']!),
                      const SizedBox(width: 8),
                      Text(language['name']!),
                    ],
                  ),
                  value: language['code']!,
                  groupValue: provider.locale.languageCode,
                  onChanged: (newValue) {
                    provider.setLanguage(newValue!);
                    Navigator.pop(context);
                    _showSnackBar(l10n.languageChanged);
                  },
                  dense: true,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('Não foi possível abrir: $url');
      }
    } catch (e) {
      _showSnackBar('Erro ao abrir link');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class ClipRoundedRectangle extends StatelessWidget {
  final Widget child;
  final double radius;

  const ClipRoundedRectangle({Key? key, required this.child, this.radius = 4.0})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}
