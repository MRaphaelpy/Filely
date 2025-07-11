import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/providers.dart';
import '../../utils/dialogs.dart';
import '../../widgets/app_icon_header.dart';
import '../../widgets/custom_navigation_bar.dart';
import '../../Audio_Player/mini_player.dart';
import '../browse/browse.dart';
import '../settings.dart';
import '../share.dart';
import '../../Audio_Player/playlists/playlists_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _page = 0;
  late AnimationController _animationController;

  final List<Widget> _pageWidgets = [Browse(), Share(), Settings()];

  List<Map<String, dynamic>> _getPageMetadata(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'title': l10n.explorerTitle,
        'icon': Icons.folder_rounded,
        'inactiveIcon': Icons.folder_outlined,
        'color': Colors.blue,
      },
      {
        'title': l10n.ftpTitle,
        'icon': Icons.share_rounded,
        'inactiveIcon': Icons.share_outlined,
        'color': Colors.orange,
      },
      {
        'title': l10n.settingsTitle,
        'icon': Icons.settings_rounded,
        'inactiveIcon': Icons.settings_outlined,
        'color': Colors.teal,
      },
    ];
  }

  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    await Provider.of<CoreProvider>(context, listen: false).checkSpace();
    _updateSystemUI();
  }

  void _updateSystemUI() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Theme.of(context).colorScheme.surface,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageMetadata = _getPageMetadata(context);
    final currentPageData = pageMetadata[_page];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          if (_exiting) return;
          setState(() {
            _exiting = true;
          });
          final shouldExit = await Dialogs.showExitDialog(context);
          if (mounted) {
            setState(() {
              _exiting = false;
            });

            if (shouldExit) {
              Navigator.pop(context);
            }
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: AppIconHeader(
            icon: currentPageData['icon'],
            title: currentPageData['title'],
            color: currentPageData['color'],
          ),
          actions: _buildAppBarActions(),
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: theme.brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
          ),
        ),
        body: Stack(
          children: [
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _pageWidgets,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MiniPlayer(),
                  CustomNavigationBar(
                    selectedIndex: _page,
                    items: pageMetadata,
                    onTap: _navigationTapped,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    final List<Widget> actions = [];

    actions.add(
      IconButton(
        icon: const Icon(Icons.playlist_play),
        tooltip: 'Playlists',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const PlaylistsScreen()),
          );
        },
      ),
    );

    if (_page == 0) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Pesquisar',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Atualizar',
          onPressed: () {
            Provider.of<CoreProvider>(context, listen: false).checkSpace();
          },
        ),
      ]);
    } else if (_page == 1) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.info_outline_rounded),
          tooltip: 'Informações FTP',
          onPressed: () {},
        ),
      );
    }

    return actions;
  }

  void _navigationTapped(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int page) {
    setState(() {
      _page = page;
      _updateSystemUI();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
