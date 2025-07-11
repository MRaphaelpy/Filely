import 'package:audio_service/audio_service.dart';
import 'package:filely/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/providers.dart';

late MyAudioHandler audioHandler;
bool shouldNavigateToPlayer = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.filely.audio',
        androidNotificationChannelName: 'Filely Audio Player',
        androidNotificationChannelDescription: 'Controls for music playback',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
        androidNotificationClickStartsActivity: true,
        fastForwardInterval: Duration(seconds: 10),
        rewindInterval: Duration(seconds: 10),
      ),
    );
  } catch (e) {
    audioHandler = MyAudioHandler();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => CoreProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
        ChangeNotifierProvider(create: (_) => FileOperationsProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: MyApp(),
    ),
  );
}
