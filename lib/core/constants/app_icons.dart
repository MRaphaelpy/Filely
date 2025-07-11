import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppIcons {
  static const IconData folder = Icons.folder_rounded;
  static const IconData folderOutlined = Icons.folder_outlined;
  static const IconData share = Icons.share_rounded;
  static const IconData shareOutlined = Icons.share_outlined;
  static const IconData settings = Icons.settings_rounded;
  static const IconData settingsOutlined = Icons.settings_outlined;

  static const IconData download = Icons.download;
  static const IconData image = Icons.image;
  static const IconData musicNote = Icons.music_note;
  static const IconData headphones = Icons.headphones;
  static const IconData android = Icons.android;
  static const IconData phoneAndroid = Icons.phone_android;

  static const IconData play = Icons.play_arrow;
  static const IconData pause = Icons.pause;
  static const IconData skipNext = Icons.skip_next;
  static const IconData skipPrevious = Icons.skip_previous;
  static const IconData fastForward = Icons.fast_forward;
  static const IconData fastRewind = Icons.fast_rewind;

  static const IconData search = Icons.search;
  static const IconData sort = Icons.sort;
  static const IconData moreVert = Icons.more_vert;
  static const IconData close = Icons.close;
  static const IconData refresh = Icons.refresh;


  static const IconData playlist = Icons.playlist_play;
  static const IconData queueMusic = Icons.queue_music_rounded;
  static const IconData playCircle = Icons.play_circle_filled;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData add = Icons.add;
}

class AppCategories {
  static final List<Map<String, dynamic>> categories = [
    {
      'title': 'Downloads',
      'icon': AppIcons.download,
      'path': '',
      'color': AppColors.purple,
    },
    {
      'title': 'Images',
      'icon': AppIcons.image,
      'path': '',
      'color': AppColors.blue,
    },
    {
      'title': 'Videos',
      'icon': AppIcons.musicNote,
      'path': '',
      'color': AppColors.red,
    },
    {
      'title': 'Audio',
      'icon': AppIcons.headphones,
      'path': '',
      'color': AppColors.teal,
    },
    {
      'title': 'Documents & Others',
      'icon': AppIcons.folder,
      'path': '',
      'color': AppColors.pink,
    },
    {
      'title': 'Apps',
      'icon': AppIcons.android,
      'path': '',
      'color': AppColors.green,
    },
    {
      'title': 'Whatsapp Statuses',
      'icon': AppIcons.phoneAndroid,
      'path': '',
      'color': AppColors.green,
    },
  ];
}
