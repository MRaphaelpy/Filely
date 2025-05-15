import 'package:filely/app.dart';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:filely/utils/my_audio_handler.dart';

late MyAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.filely.audio',
      androidNotificationChannelName: 'Música',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
      androidNotificationClickStartsActivity: true,
      notificationColor: Color(0xFF9C27B0),
      artDownscaleWidth: 300,
      artDownscaleHeight: 300,
      preloadArtwork: true,
      fastForwardInterval: Duration(seconds: 10),
      rewindInterval: Duration(minutes: 1),
    ),
  );
  runApp(const FilelyApp());
}
