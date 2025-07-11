import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/constants.dart';
import 'core/themes/themes.dart';
import 'l10n/app_localizations.dart';
import 'main.dart';
import 'Audio_Player/audio_player_screen.dart';
import 'providers/app_provider.dart';
import 'providers/language_provider.dart';
import 'screens/ios_error.dart';
import 'screens/splash.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _hasNavigatedToPlayer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && !_hasNavigatedToPlayer) {
      _checkAndNavigateToPlayer();
    }
  }

  void _checkAndNavigateToPlayer() async {
    try {
      final mediaItem = audioHandler.mediaItem.value;
      final playbackState = audioHandler.playbackState.value;

      if (mediaItem != null &&
          (playbackState.playing ||
              playbackState.processingState == AudioProcessingState.ready)) {
        await Future.delayed(const Duration(milliseconds: 500));

        final navContext = Provider.of<AppProvider>(
          context,
          listen: false,
        ).navigatorKey.currentContext;
        if (navContext != null && mounted) {
          _hasNavigatedToPlayer = true;

          Navigator.of(navContext)
              .push(
                MaterialPageRoute(
                  builder: (context) => AudioPlayerScreen(
                    title: mediaItem.title,
                    artist:
                        mediaItem.artist ?? AppStrings.unknownArtist(context),
                    albumArtUrl: mediaItem.artUri?.toString() ?? '',
                    audioUrl: mediaItem.id,
                    syncWithCurrentTrack: true,
                  ),
                ),
              )
              .then((_) {
                _hasNavigatedToPlayer = false;
              });
        }
      }
    } catch (e) {
      print('Erro ao verificar estado da música: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, LanguageProvider>(
      builder:
          (
            BuildContext context,
            AppProvider appProvider,
            LanguageProvider languageProvider,
            Widget? child,
          ) {
            return MaterialApp(
              key: appProvider.key,
              debugShowCheckedModeBanner: false,
              navigatorKey: appProvider.navigatorKey,
              title: AppStrings.appName,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              locale: languageProvider.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('pt'),
                Locale('en'),
                Locale('es'),
              ],
              home: Platform.isIOS ? IosError() : Splash(),
            );
          },
    );
  }
}
