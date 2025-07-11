import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_service/audio_service.dart';
import '../models/playlist_models.dart';
import '../main.dart';
import 'dart:convert';

class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];
  Playlist? _currentPlaylist;
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.none;

  static const String _playlistsKey = 'saved_playlists';
  static const String _currentPlaylistKey = 'current_playlist';
  static const String _shuffleKey = 'shuffle_enabled';
  static const String _repeatKey = 'repeat_mode';


  List<Playlist> get playlists => _playlists;
  Playlist? get currentPlaylist => _currentPlaylist;
  int get currentIndex => _currentIndex;
  bool get isShuffleEnabled => _isShuffleEnabled;
  bool get isRepeatEnabled => _repeatMode != RepeatMode.none;
  RepeatMode get repeatMode => _repeatMode;

  PlaylistProvider() {
    _loadPlaylists();
    _loadSettings();
  }


  Future<void> _loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = prefs.getString(_playlistsKey);

      if (playlistsJson != null) {
        final List<dynamic> playlistsList = json.decode(playlistsJson);
        _playlists = playlistsList
            .map((json) => Playlist.fromJson(json))
            .toList();
      }


      final currentPlaylistJson = prefs.getString(_currentPlaylistKey);
      if (currentPlaylistJson != null) {
        final playlistData = json.decode(currentPlaylistJson);
        _currentPlaylist = Playlist.fromJson(playlistData['playlist']);
        _currentIndex = playlistData['currentIndex'] ?? 0;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar playlists: $e');
    }
  }


  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isShuffleEnabled = prefs.getBool(_shuffleKey) ?? false;
      final repeatIndex = prefs.getInt(_repeatKey) ?? 0;
      _repeatMode = RepeatMode.values[repeatIndex];
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar configurações: $e');
    }
  }


  Future<void> _savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final playlistsJson = json.encode(
        _playlists.map((playlist) => playlist.toJson()).toList(),
      );
      await prefs.setString(_playlistsKey, playlistsJson);
    } catch (e) {
      debugPrint('Erro ao salvar playlists: $e');
    }
  }



  Future<void> updatePlaylist(
    String id,
    String name,
    String description,
  ) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updatedPlaylist = _playlists[index].copyWith(
        name: name,
        description: description,
      );
      _playlists[index] = updatedPlaylist;


      if (_currentPlaylist?.id == id) {
        _currentPlaylist = updatedPlaylist;
        await _saveCurrentPlaylist();
      }

      await _savePlaylists();
      notifyListeners();
    }
  }


  Future<void> _saveCurrentPlaylist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentPlaylist != null) {
        final currentPlaylistData = {
          'playlist': _currentPlaylist!.toJson(),
          'currentIndex': _currentIndex,
        };
        await prefs.setString(
          _currentPlaylistKey,
          json.encode(currentPlaylistData),
        );
      } else {
        await prefs.remove(_currentPlaylistKey);
      }
    } catch (e) {
      debugPrint('Erro ao salvar playlist atual: $e');
    }
  }


  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_shuffleKey, _isShuffleEnabled);
      await prefs.setInt(_repeatKey, _repeatMode.index);
    } catch (e) {
      debugPrint('Erro ao salvar configurações: $e');
    }
  }


  Future<void> createPlaylist(String name, {String? description}) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      items: [],
      description: description,
    );

    _playlists.add(playlist);
    await _savePlaylists();
    notifyListeners();
  }


  Future<void> deletePlaylist(String playlistId) async {
    _playlists.removeWhere((playlist) => playlist.id == playlistId);


    if (_currentPlaylist?.id == playlistId) {
      _currentPlaylist = null;
      _currentIndex = 0;
      await _saveCurrentPlaylist();
    }

    await _savePlaylists();
    notifyListeners();
  }


  Future<void> renamePlaylist(String playlistId, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index] = _playlists[index].copyWith(name: newName);


      if (_currentPlaylist?.id == playlistId) {
        _currentPlaylist = _playlists[index];
        await _saveCurrentPlaylist();
      }

      await _savePlaylists();
      notifyListeners();
    }
  }


  Future<void> addItemToPlaylist(String playlistId, PlaylistItem item) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {

      if (!_playlists[index].items.any(
        (existingItem) => existingItem.id == item.id,
      )) {
        final updatedItems = [..._playlists[index].items, item];
        _playlists[index] = _playlists[index].copyWith(items: updatedItems);


        if (_currentPlaylist?.id == playlistId) {
          _currentPlaylist = _playlists[index];
          await _saveCurrentPlaylist();
        }

        await _savePlaylists();
        notifyListeners();
      }
    }
  }


  Future<void> removeItemFromPlaylist(String playlistId, String itemId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final updatedItems = _playlists[index].items
          .where((item) => item.id != itemId)
          .toList();

      _playlists[index] = _playlists[index].copyWith(items: updatedItems);


      if (_currentPlaylist?.id == playlistId) {
        _currentPlaylist = _playlists[index];

        if (_currentIndex >= _currentPlaylist!.items.length) {
          _currentIndex = _currentPlaylist!.items.length - 1;
          if (_currentIndex < 0) _currentIndex = 0;
        }
        await _saveCurrentPlaylist();
      }

      await _savePlaylists();
      notifyListeners();
    }
  }


  Future<void> reorderPlaylistItems(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      final items = [..._playlists[index].items];
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);

      _playlists[index] = _playlists[index].copyWith(items: items);


      if (_currentPlaylist?.id == playlistId) {
        _currentPlaylist = _playlists[index];

        if (_currentIndex == oldIndex) {
          _currentIndex = newIndex;
        } else if (_currentIndex > oldIndex && _currentIndex <= newIndex) {
          _currentIndex--;
        } else if (_currentIndex < oldIndex && _currentIndex >= newIndex) {
          _currentIndex++;
        }
        await _saveCurrentPlaylist();
      }

      await _savePlaylists();
      notifyListeners();
    }
  }


  Future<void> playPlaylist(Playlist playlist, {int startIndex = 0}) async {
    if (playlist.items.isEmpty) return;

    _currentPlaylist = playlist;
    _currentIndex = startIndex.clamp(0, playlist.items.length - 1);


    final mediaItems = playlist.items.map((item) {
      return MediaItem(
        id: item.filePath,
        title: item.title,
        artist: item.artist,
        artUri: item.albumArt != null ? Uri.parse(item.albumArt!) : null,
        duration: item.duration,
      );
    }).toList();


    await audioHandler.setMediaItems(mediaItems);


    if (startIndex < mediaItems.length) {
      await audioHandler.skipToQueueItem(startIndex);
      await audioHandler.play();
    }

    await _saveCurrentPlaylist();
    notifyListeners();
  }


  Future<void> nextTrack() async {
    if (_currentPlaylist == null || _currentPlaylist!.items.isEmpty) return;

    if (_isShuffleEnabled) {

      final availableIndices = List.generate(
        _currentPlaylist!.items.length,
        (i) => i,
      );
      availableIndices.remove(_currentIndex);
      if (availableIndices.isNotEmpty) {
        _currentIndex = (availableIndices..shuffle()).first;
      }
    } else {

      _currentIndex++;
      if (_currentIndex >= _currentPlaylist!.items.length) {
        if (_repeatMode == RepeatMode.all) {
          _currentIndex = 0;
        } else {
          _currentIndex = _currentPlaylist!.items.length - 1;
          return;
        }
      }
    }

    await audioHandler.skipToQueueItem(_currentIndex);
    await _saveCurrentPlaylist();
    notifyListeners();
  }


  Future<void> previousTrack() async {
    if (_currentPlaylist == null || _currentPlaylist!.items.isEmpty) return;

    if (_isShuffleEnabled) {

      final availableIndices = List.generate(
        _currentPlaylist!.items.length,
        (i) => i,
      );
      availableIndices.remove(_currentIndex);
      if (availableIndices.isNotEmpty) {
        _currentIndex = (availableIndices..shuffle()).first;
      }
    } else {

      _currentIndex--;
      if (_currentIndex < 0) {
        if (_repeatMode == RepeatMode.all) {
          _currentIndex = _currentPlaylist!.items.length - 1;
        } else {
          _currentIndex = 0;
          return;
        }
      }
    }

    await audioHandler.skipToQueueItem(_currentIndex);
    await _saveCurrentPlaylist();
    notifyListeners();
  }


  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _saveSettings();
    notifyListeners();
  }


  Future<void> toggleRepeat() async {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        break;
    }
    await _saveSettings();
    notifyListeners();
  }


  Future<void> playTrackAt(int index) async {
    if (_currentPlaylist == null ||
        index < 0 ||
        index >= _currentPlaylist!.items.length)
      return;

    _currentIndex = index;
    await audioHandler.skipToQueueItem(_currentIndex);
    await audioHandler.play();
    await _saveCurrentPlaylist();
    notifyListeners();
  }


  Future<void> setShuffle(bool enabled) async {
    _isShuffleEnabled = enabled;
    await _saveSettings();
    notifyListeners();
  }


  PlaylistItem? get currentItem {
    if (_currentPlaylist == null ||
        _currentIndex < 0 ||
        _currentIndex >= _currentPlaylist!.items.length) {
      return null;
    }
    return _currentPlaylist!.items[_currentIndex];
  }


  bool get hasNext {
    if (_currentPlaylist == null) return false;
    if (_isShuffleEnabled || _repeatMode == RepeatMode.all) return true;
    return _currentIndex < _currentPlaylist!.items.length - 1;
  }


  bool get hasPrevious {
    if (_currentPlaylist == null) return false;
    if (_isShuffleEnabled || _repeatMode == RepeatMode.all) return true;
    return _currentIndex > 0;
  }
}

enum RepeatMode { none, all, one }
