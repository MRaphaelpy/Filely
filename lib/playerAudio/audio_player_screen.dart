import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:filely/main.dart';
import 'package:filely/providers/playlist_provider.dart';
import 'package:filely/screens/playlists/playlists_screen.dart';
import 'package:filely/widgets/album_art_widget.dart';
import 'package:filely/widgets/app_bar_widget.dart';
import 'package:filely/widgets/music_info_widget.dart';
import 'package:filely/widgets/player_controls_widget.dart';
import 'package:filely/widgets/progress_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerScreen extends StatefulWidget {
  final String title;
  final String artist;
  final String albumArtUrl;
  final String audioUrl;
  final bool syncWithCurrentTrack;

  const AudioPlayerScreen({
    super.key,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
    required this.audioUrl,
    this.syncWithCurrentTrack = false,
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

  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.syncWithCurrentTrack) {
        _configureStreams();

        final currentState = audioHandler.playbackState.value;
        final currentMediaItem = audioHandler.mediaItem.value;

        if (mounted) {
          setState(() {
            _isPlaying = currentState.playing;
            _position = currentState.updatePosition;
            _duration = currentMediaItem?.duration ?? Duration.zero;
          });
        }
      } else {
        final mediaItem = MediaItem(
          id: widget.audioUrl,
          title: widget.title,
          artist: widget.artist,
          artUri: Uri.tryParse(widget.albumArtUrl),
          duration: await _getDuration(),
        );

        await audioHandler.setMediaItem(mediaItem);

        _configureStreams();

        await audioHandler.play();
      }
    } catch (e) {
      debugPrint('Error initializing player: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<Duration?> _getDuration() async {
    return null;
  }

  void _configureStreams() {
    _playbackStateSubscription = audioHandler.playbackState
        .distinct()
        .listen((state) {
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

              if (!_isSeeking) {
                _position = state.position;
              }
            });
          }
        });

    _mediaItemSubscription = audioHandler.mediaItem.distinct().listen((item) {
      if (item != null && mounted) {
        setState(() {
          _duration = item.duration ?? Duration.zero;
        });
      }
    });

    _positionSubscription = AudioService.position
        .debounceTime(
          const Duration(milliseconds: 200),
        ) 
        .listen((pos) {
          if (mounted && !_isSeeking) {
            setState(() {
              _position = pos;
            });
          }
        });

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
    try {
      if (_isPlaying) {
        await audioHandler.pause();
      } else {
        await audioHandler.play();
      }
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
    }
  }

  void _seekToPosition(Duration position) async {
    debugPrint('Seeking to position: ${position.inMilliseconds}ms');

    setState(() {
      _isSeeking = true;
      _position = position;
    });

    await audioHandler.seek(position);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _isSeeking = false;
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

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AudioAppBarWidget(
              onBack: () => Navigator.pop(context),
              actions: [
                IconButton(
                  icon: const Icon(Icons.playlist_play),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PlaylistsScreen(),
                      ),
                    );
                  },
                  tooltip: 'Playlists',
                ),
              ],
            ),
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
                onSeek: _seekToPosition,
                accentColor: colorScheme.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Consumer<PlaylistProvider>(
                builder: (context, playlistProvider, child) {
                  return PlayerControlsWidget(
                    isPlaying: _isPlaying,
                    isBuffering: _isBuffering,
                    playbackSpeed: _playbackSpeed,
                    onPlayPause: _togglePlayPause,
                    onRewind: () {
                      _seekToPosition(Duration.zero);
                    },
                    onFastForward: () {
                      final newPosition =
                          _position + const Duration(seconds: 10);
                      _seekToPosition(
                        newPosition > _duration ? _duration : newPosition,
                      );
                    },
                    onSpeedChange: _changePlaybackSpeed,
                    onPrevious: playlistProvider.hasPrevious
                        ? () => playlistProvider.previousTrack()
                        : null,
                    onNext: playlistProvider.hasNext
                        ? () => playlistProvider.nextTrack()
                        : null,
                    onShuffle: () => playlistProvider.toggleShuffle(),
                    onRepeat: () => playlistProvider.toggleRepeat(),
                    isShuffleEnabled: playlistProvider.isShuffleEnabled,
                    isRepeatEnabled: playlistProvider.isRepeatEnabled,
                  );
                },
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
