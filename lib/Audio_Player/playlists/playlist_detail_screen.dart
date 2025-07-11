import 'package:filely/Audio_Player/playlists/playlists_overview/widgets/playlists_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/playlist_models.dart';
import '../../providers/playlist_provider.dart';
import 'dialogs/playlist_detail_edit_dialog.dart';
import 'playlist_detail/widgets/playlist_detail_control_buttons.dart';
import 'playlist_detail/widgets/playlist_detail_header.dart';
import 'playlist_detail/widgets/playlist_detail_options_sheet.dart';
import 'playlist_detail/widgets/playlist_detail_section_divider.dart';
import 'playlist_detail/widgets/playlist_detail_sliver_app_bar.dart';
import 'playlist_detail/widgets/playlist_detail_song_options_sheet.dart';
import 'playlist_detail/widgets/playlist_detail_songs_list.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  late Playlist _playlist;
  late ScrollController _scrollController;
  bool _showTitle = false;
  Color? _appBarColor;

  @override
  void initState() {
    super.initState();
    _playlist = widget.playlist;
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _appBarColor = Colors.transparent;
  }

  void _scrollListener() {
    if (_scrollController.offset > 140 && !_showTitle) {
      setState(() => _showTitle = true);
    } else if (_scrollController.offset <= 140 && _showTitle) {
      setState(() => _showTitle = false);
    }

    if (_scrollController.offset > 180 && _appBarColor == Colors.transparent) {
      setState(() => _appBarColor = Theme.of(context).colorScheme.surface);
    } else if (_scrollController.offset <= 180 &&
        _appBarColor != Colors.transparent) {
      setState(() => _appBarColor = Colors.transparent);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<PlaylistProvider>(
      builder: (context, provider, child) {
        final updatedPlaylist = provider.playlists.firstWhere(
          (p) => p.id == _playlist.id,
          orElse: () => _playlist,
        );
        _playlist = updatedPlaylist;

        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              PlaylistDetailSliverAppBar(
                playlist: _playlist,
                appBarColor: _appBarColor,
                showTitle: _showTitle,
                onEdit: () => _showEditDialog(provider),
                onShowOptions: () => _showOptionsBottomSheet(provider),
                onShuffle: () {
                  provider.setShuffle(true);
                  provider.playPlaylist(_playlist);
                  _showSnackMessage('Reprodução aleatória iniciada');
                },
              ),
              PlaylistDetailHeader(playlist: _playlist),
              PlaylistDetailControlButtons(
                playlist: _playlist,
                onPlay: () {
                  provider.setShuffle(false);
                  provider.playPlaylist(_playlist);
                  _showSnackMessage('Reproduzindo "${_playlist.name}"');
                },
                onShuffle: () {
                  provider.setShuffle(true);
                  provider.playPlaylist(_playlist);
                  _showSnackMessage('Reprodução aleatória ativada');
                },
              ),
              PlaylistDetailSectionDivider(title: 'Músicas'),
              if (_playlist.items.isEmpty)
                EmptyStateWidget(onAction: () => Navigator.pop(context))
              else
                PlaylistDetailSongsList(
                  playlist: _playlist,
                  provider: provider,
                  onReorder: (oldIndex, newIndex) {
                    provider.reorderPlaylistItems(
                      _playlist.id,
                      oldIndex,
                      newIndex,
                    );
                  },
                  onPlayFromHere: (index) => _playFromHere(provider, index),
                  onShowSongOptions: (item, index) =>
                      _showSongOptionsBottomSheet(theme, provider, item, index),
                ),
            ],
          ),
          floatingActionButton: _playlist.items.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () => _playFromHere(provider, 0),
                  child: const Icon(Icons.play_arrow),
                )
              : null,
        );
      },
    );
  }

  void _playFromHere(PlaylistProvider provider, int index) {
    provider.playPlaylist(_playlist, startIndex: index);
    _showSnackMessage('Reproduzindo "${_playlist.items[index].title}"');
  }

  void _showSnackMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        action: action,
      ),
    );
  }

  void _showEditDialog(PlaylistProvider provider) {
    showDialog(
      context: context,
      builder: (context) =>
          PlaylistDetailEditDialog(playlist: _playlist, provider: provider),
    ).then((result) {
      if (result == true) {
        _showSnackMessage('Playlist atualizada com sucesso');
      }
    });
  }

  void _showOptionsBottomSheet(PlaylistProvider provider) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return PlaylistDetailOptionsSheet(
          playlist: _playlist,
          provider: provider,
          showSnackMessage: _showSnackMessage,
        );
      },
    );
  }

  void _showSongOptionsBottomSheet(
    ThemeData theme,
    PlaylistProvider provider,
    PlaylistItem item,
    int index,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return PlaylistDetailSongOptionsSheet(
          item: item,
          index: index,
          playlist: _playlist,
          provider: provider,
          onPlayFromHere: (index) => _playFromHere(provider, index),
          showSnackMessage: _showSnackMessage,
        );
      },
    );
  }
}
