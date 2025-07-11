import 'package:audio_service/audio_service.dart';
import '../models/playlist_models.dart';

class AudioUtils {

  static MediaItem playlistItemToMediaItem(PlaylistItem item) {
    return MediaItem(
      id: item.filePath,
      title: item.title,
      artist: item.artist,
      artUri: item.albumArt != null ? Uri.tryParse(item.albumArt!) : null,
      duration: item.duration,
    );
  }


  static List<MediaItem> playlistItemsToMediaItems(List<PlaylistItem> items) {
    return items.map(playlistItemToMediaItem).toList();
  }


  static PlaylistItem mediaItemToPlaylistItem(MediaItem item) {
    return PlaylistItem(
      id: '${item.id}_${DateTime.now().millisecondsSinceEpoch}',
      title: item.title,
      artist: item.artist ?? 'Artista Desconhecido',
      filePath: item.id,
      albumArt: item.artUri?.toString(),
      duration: item.duration,
    );
  }


  static List<PlaylistItem> mediaItemsToPlaylistItems(List<MediaItem> items) {
    return items.map(mediaItemToPlaylistItem).toList();
  }


  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }


  static String extractTitle(String filePath) {
    final fileName = filePath.split('/').last;
    final nameWithoutExtension = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    return nameWithoutExtension;
  }


  static bool isAudioFile(String filePath) {
    final extensions = [
      '.mp3',
      '.wav',
      '.aac',
      '.m4a',
      '.ogg',
      '.flac',
      '.opus',
      '.wma',
    ];

    final lowerPath = filePath.toLowerCase();
    return extensions.any((ext) => lowerPath.endsWith(ext));
  }


  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }


  static PlaylistItem createPlaylistItem({
    required String title,
    required String artist,
    required String filePath,
    String? albumArt,
    Duration? duration,
  }) {
    return PlaylistItem(
      id: '${filePath}_${generateUniqueId()}',
      title: title,
      artist: artist,
      filePath: filePath,
      albumArt: albumArt,
      duration: duration,
    );
  }
}
