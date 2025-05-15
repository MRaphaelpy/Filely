import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import 'package:flutter/foundation.dart';
import 'dart:async';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final rxdart.BehaviorSubject<List<MediaItem>> _recentMediaItems = rxdart
      .BehaviorSubject.seeded([]);
  final rxdart.BehaviorSubject<double> _volume = rxdart.BehaviorSubject.seeded(
    1.0,
  );
  final rxdart.BehaviorSubject<double> _equalizer = rxdart
      .BehaviorSubject.seeded(0.0);
  Timer? _positionTimer;

  final rxdart.BehaviorSubject<double> _animatedPlaybackProgress = rxdart
      .BehaviorSubject.seeded(0.0);

  Stream<double> get volumeStream => _volume.stream;

  Stream<double> get equalizerStream => _equalizer.stream;

  Stream<double> get animatedPlaybackProgressStream =>
      _animatedPlaybackProgress.stream;

  Stream<List<MediaItem>> get recentMediaItemsStream =>
      _recentMediaItems.stream;

  Stream<Duration> get enhancedPositionStream =>
      rxdart.Rx.combineLatest2<Duration, PlaybackEvent, Duration>(
        _player.positionStream,
        _player.playbackEventStream,
        (position, event) => position,
      ).distinct();

  Stream<PlaybackState> get enrichedPlaybackStateStream =>
      rxdart.Rx.combineLatest3<PlaybackState, Duration, double, PlaybackState>(
        playbackState.stream,
        enhancedPositionStream,
        _animatedPlaybackProgress.stream,
        (state, position, progress) => state.copyWith(updatePosition: position),
      );

  MyAudioHandler() {
    _initializePlayer();
    _setupPlaybackStateStream();
    _startProgressAnimation();
  }

  void _initializePlayer() {
    AudioSession.instance.then((session) {
      session.configure(const AudioSessionConfiguration.music());
    });

    _player.setLoopMode(LoopMode.off);
    _player.setVolume(_volume.value);

    _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace stackTrace) {
        if (kDebugMode) {}

        playbackState.add(
          playbackState.value.copyWith(
            processingState: AudioProcessingState.error,
          ),
        );
      },
    );
  }

  void _setupPlaybackStateStream() {
    _player.playbackEventStream.listen((event) {
      final processingState =
          {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!;

      final controls = _createDynamicControls();

      playbackState.add(
        playbackState.value.copyWith(
          controls: controls,
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
            MediaAction.skipToPrevious,
            MediaAction.skipToNext,
            MediaAction.setRepeatMode,
            MediaAction.setShuffleMode,
            MediaAction.stop,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: processingState,
          playing: _player.playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: _player.currentIndex ?? 0,
        ),
      );

      if (_player.processingState == ProcessingState.completed) {
        _onPlaybackCompleted();
      }
    });
  }

  List<MediaControl> _createDynamicControls() {
    final isPlaying = _player.playing;
    final isBuffering = _player.processingState == ProcessingState.buffering;
    final isLoading = _player.processingState == ProcessingState.loading;

    return [
      MediaControl.skipToPrevious,
      if (isBuffering || isLoading)
        MediaControl.stop
      else
        isPlaying ? MediaControl.pause : MediaControl.play,
      MediaControl.skipToNext,
    ];
  }

  void _startProgressAnimation() {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_player.playing &&
          _player.duration != null &&
          _player.duration!.inMilliseconds > 0) {
        final progress =
            _player.position.inMilliseconds / _player.duration!.inMilliseconds;
        _animatedPlaybackProgress.add(progress.clamp(0.0, 1.0));
      }
    });
  }

  void _onPlaybackCompleted() {
    if (queue.value.isNotEmpty && queue.value.length > 1) {
      final currentIndex = _player.currentIndex ?? 0;
      if (currentIndex < queue.value.length - 1) {
        skipToNext();
      }
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;

    await _player.setVolume(0.3);

    await _player.seek(Duration.zero, index: index);

    mediaItem.add(queue.value[index]);

    await _player.setVolume(_volume.value);

    if (playbackState.value.playing) {
      await _player.play();
    }
  }

  @override
  Future<void> play() async {
    await _player.setVolume(_volume.value * 0.8);
    await _player.play();
    await Future.delayed(const Duration(milliseconds: 200));
    await _player.setVolume(_volume.value);
    _startProgressAnimation();
  }

  @override
  Future<void> pause() async {
    await _player.setVolume(_volume.value * 0.6);
    await Future.delayed(const Duration(milliseconds: 150));
    await _player.pause();
    await _player.setVolume(_volume.value);
    _positionTimer?.cancel();
  }

  @override
  Future<void> stop() async {
    for (var i = 10; i > 0; i--) {
      await _player.setVolume(_volume.value * i / 10);
      await Future.delayed(const Duration(milliseconds: 30));
    }
    await _player.stop();
    await _player.setVolume(_volume.value);
    _positionTimer?.cancel();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    if (_player.duration != null && _player.duration!.inMilliseconds > 0) {
      final progress =
          position.inMilliseconds / _player.duration!.inMilliseconds;
      _animatedPlaybackProgress.add(progress.clamp(0.0, 1.0));
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    final currentSpeed = _player.speed;
    final speedDifference = speed - currentSpeed;
    if (speedDifference.abs() > 0.3) {
      const steps = 5;
      for (int i = 1; i <= steps; i++) {
        final intermediateSpeed = currentSpeed + (speedDifference * i / steps);
        await _player.setSpeed(intermediateSpeed);
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } else {
      await _player.setSpeed(speed);
    }

    playbackState.add(playbackState.value.copyWith(speed: speed));
  }

  // Enhanced volume control with animation
  Future<void> setVolume(double volume) async {
    final currentVolume = _player.volume;
    final steps = 8;
    for (int i = 1; i <= steps; i++) {
      final newVolume = currentVolume + ((volume - currentVolume) * i / steps);
      await _player.setVolume(newVolume.clamp(0.0, 1.0));
      await Future.delayed(const Duration(milliseconds: 30));
    }

    _volume.add(volume);
  }

  // Enhanced media item setter with transitions
  Future<void> setMediaItem(MediaItem mediaItem) async {
    try {
      this.mediaItem.add(
        mediaItem.copyWith(
          id: mediaItem.id,
          artUri: mediaItem.artUri,
          title: mediaItem.title,
          artist: mediaItem.artist,
        ),
      );

      final audioSource = await _createAudioSource(mediaItem);
      await _player.setAudioSource(audioSource);

      if (_player.duration != null) {
        this.mediaItem.add(mediaItem.copyWith(duration: _player.duration));
      }

      _updateRecentItems(mediaItem);
    } catch (e) {
      if (kDebugMode) {}
    }
  }

  // Set multiple items with proper queue management
  Future<void> setMediaItems(List<MediaItem> mediaItems) async {
    try {
      queue.add(mediaItems);
      final audioSources = await Future.wait(
        mediaItems.map(_createAudioSource),
      );
      // ignore: deprecated_member_use
      final playlist = ConcatenatingAudioSource(
        children: audioSources,
        useLazyPreparation: true,
      );

      await _player.setAudioSource(playlist);

      if (mediaItems.isNotEmpty && _player.currentIndex != null) {
        mediaItem.add(mediaItems[_player.currentIndex!]);
      }
    // ignore: empty_catches
    } catch (e) {}
  }

  Future<AudioSource> _createAudioSource(MediaItem mediaItem) async {
    return AudioSource.uri(Uri.parse(mediaItem.id), tag: mediaItem);
  }

  // Track recently played items
  void _updateRecentItems(MediaItem item) {
    final currentItems = _recentMediaItems.valueOrNull ?? [];
    final filteredItems = currentItems.where((i) => i.id != item.id).toList();
    final updatedItems = [item, ...filteredItems];
    _recentMediaItems.add(updatedItems.take(10).toList());
  }

  Future<void> setEqualizerEffect(double value) async {
    _equalizer.add(value);
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
    _positionTimer?.cancel();
    super.onTaskRemoved();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
    _positionTimer?.cancel();
    _volume.close();
    _equalizer.close();
    _animatedPlaybackProgress.close();
    _recentMediaItems.close();
    // super.dispose();
  }
}
