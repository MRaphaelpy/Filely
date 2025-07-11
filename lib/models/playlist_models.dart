class PlaylistItem {
  final String id;
  final String title;
  final String artist;
  final String filePath;
  final String? albumArt;
  final Duration? duration;
  final DateTime addedAt;

  PlaylistItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.filePath,
    this.albumArt,
    this.duration,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'filePath': filePath,
      'albumArt': albumArt,
      'duration': duration?.inMilliseconds,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      filePath: json['filePath'],
      albumArt: json['albumArt'],
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'])
          : null,
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  PlaylistItem copyWith({
    String? id,
    String? title,
    String? artist,
    String? filePath,
    String? albumArt,
    Duration? duration,
    DateTime? addedAt,
  }) {
    return PlaylistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      filePath: filePath ?? this.filePath,
      albumArt: albumArt ?? this.albumArt,
      duration: duration ?? this.duration,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaylistItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Playlist {
  final String id;
  final String name;
  final List<PlaylistItem> items;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String? description;
  final String? coverArt;

  Playlist({
    required this.id,
    required this.name,
    required this.items,
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.description,
    this.coverArt,
  }) : createdAt = createdAt ?? DateTime.now(),
       modifiedAt = modifiedAt ?? DateTime.now();

  Duration get totalDuration {
    return items.fold(Duration.zero, (total, item) {
      return total + (item.duration ?? Duration.zero);
    });
  }

  int get itemCount => items.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'description': description,
      'coverArt': coverArt,
    };
  }

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
      items: (json['items'] as List)
          .map((item) => PlaylistItem.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
      description: json['description'],
      coverArt: json['coverArt'],
    );
  }

  Playlist copyWith({
    String? id,
    String? name,
    List<PlaylistItem>? items,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? description,
    String? coverArt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      description: description ?? this.description,
      coverArt: coverArt ?? this.coverArt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
