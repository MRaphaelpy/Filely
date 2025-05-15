import 'package:flutter/material.dart';
import 'package:filely/widgets/app_bar_widget.dart';
import 'package:filely/widgets/album_art_widget.dart';
import 'package:filely/widgets/music_info_widget.dart';
import 'package:filely/widgets/progress_bar_widget.dart';
import 'package:filely/widgets/player_controls_widget.dart';
import 'package:audio_service/audio_service.dart';
import 'package:filely/utils/my_audio_handler.dart';
import 'package:filely/main.dart'; // para acessar o audioHandler global
import 'dart:async';

class AudioPlayerScreen extends StatefulWidget {
  final String title;
  final String artist;
  final String albumArtUrl;
  final String audioUrl;

  const AudioPlayerScreen({
    super.key,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
    required this.audioUrl,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with WidgetsBindingObserver {
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isBuffering = false;
  double _playbackSpeed = 1.0;

  late StreamSubscription<PlaybackState> _playbackStateSubscription;
  late StreamSubscription<MediaItem?> _mediaItemSubscription;
  late StreamSubscription<Duration> _positionSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Configura media item
      final mediaItem = MediaItem(
        id: widget.audioUrl,
        title: widget.title,
        artist: widget.artist,
        artUri: Uri.tryParse(widget.albumArtUrl),
        duration: await _getDuration(),
      );

      // Configura e inicia reprodução
      await audioHandler.setMediaItem(mediaItem);

      // Configure streams antes de iniciar a reprodução
      _configureStreams();

      // Iniciar reprodução após configuração
      await audioHandler.play();
    } catch (e) {
      debugPrint('Erro ao inicializar o player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reproduzir o áudio: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<Duration?> _getDuration() async {
    // Implemente lógica para obter duração se disponível
    return null;
  }

  void _configureStreams() {
    // Listen to playback state changes
    _playbackStateSubscription = audioHandler.playbackState.listen((state) {
      debugPrint(
        'PlaybackState update: playing=${state.playing}, '
        'processingState=${state.processingState}',
      );

      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isBuffering =
              state.processingState == AudioProcessingState.buffering ||
              state.processingState == AudioProcessingState.loading;
          _playbackSpeed = state.speed;
        });
      }
    });

    // Listen to media item changes (for duration updates)
    _mediaItemSubscription = audioHandler.mediaItem.listen((item) {
      if (item != null && mounted) {
        setState(() {
          _duration = item.duration ?? Duration.zero;
        });
      }
    });

    // Listen to position updates
    _positionSubscription = AudioService.position.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    // Synchronize with current state
    final currentState = audioHandler.playbackState.value;
    final currentMediaItem = audioHandler.mediaItem.value;

    if (mounted) {
      setState(() {
        _isPlaying = currentState.playing;
        _position = currentState.position;
        _duration = currentMediaItem?.duration ?? Duration.zero;
      });
    }
  }

  void _togglePlayPause() async {
    debugPrint('Toggle play/pause. Current state: $_isPlaying');

    if (_isPlaying) {
      await audioHandler.pause();
    } else {
      await audioHandler.play();
    }

    // Verifica o estado após a ação para garantir consistência
    Future.delayed(const Duration(milliseconds: 100), () {
      final newState = audioHandler.playbackState.value;
      if (_isPlaying != newState.playing && mounted) {
        setState(() {
          _isPlaying = newState.playing;
        });
      }
    });
  }

  void _changePlaybackSpeed() {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    int currentIndex = speeds.indexOf(_playbackSpeed);
    int nextIndex = (currentIndex + 1) % speeds.length;
    _playbackSpeed = speeds[nextIndex];
    audioHandler.setSpeed(_playbackSpeed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cappedPosition = _position > _duration ? _duration : _position;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AudioAppBarWidget(onBack: () => Navigator.pop(context)),
            Expanded(child: AlbumArtWidget(albumArtUrl: widget.albumArtUrl)),
            MusicInfoWidget(
              title: widget.title,
              artist: widget.artist,
              isPlaying: _isPlaying,
            ),
            if (_isBuffering)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: LinearProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ProgressBarWidget(
                position: cappedPosition,
                duration: _duration,
                onSeek: (value) => audioHandler.seek(value),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: PlayerControlsWidget(
                isPlaying: _isPlaying,
                isBuffering: _isBuffering,
                playbackSpeed: _playbackSpeed,
                onPlayPause: _togglePlayPause,
                onRewind: () {
                  audioHandler.seek(Duration.zero);
                },
                onFastForward: () {
                  final newPosition = _position + const Duration(seconds: 10);
                  audioHandler.seek(
                    newPosition > _duration ? _duration : newPosition,
                  );
                },
                onSpeedChange: _changePlaybackSpeed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reconfigurar streams quando o app volta para o foreground
      _playbackStateSubscription.cancel();
      _mediaItemSubscription.cancel();
      _positionSubscription.cancel();

      _configureStreams();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _playbackStateSubscription.cancel();
    _mediaItemSubscription.cancel();
    _positionSubscription.cancel();
    super.dispose();
  }
}
