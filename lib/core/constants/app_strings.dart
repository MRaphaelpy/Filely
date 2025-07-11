import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class AppStrings {
  static const String appName = 'FileX';


  static String explorerTitle(BuildContext context) =>
      AppLocalizations.of(context)!.explorerTitle;
  static String ftpTitle(BuildContext context) =>
      AppLocalizations.of(context)!.ftpTitle;
  static String settingsTitle(BuildContext context) =>
      AppLocalizations.of(context)!.settingsTitle;
  static String downloadsTitle(BuildContext context) =>
      AppLocalizations.of(context)!.downloadsTitle;
  static String imagesTitle(BuildContext context) =>
      AppLocalizations.of(context)!.imagesTitle;
  static String videosTitle(BuildContext context) =>
      AppLocalizations.of(context)!.videosTitle;
  static String audioTitle(BuildContext context) =>
      AppLocalizations.of(context)!.audioTitle;
  static String documentsTitle(BuildContext context) =>
      AppLocalizations.of(context)!.documentsTitle;
  static String appsTitle(BuildContext context) =>
      AppLocalizations.of(context)!.appsTitle;
  static String whatsappStatusTitle(BuildContext context) =>
      AppLocalizations.of(context)!.whatsappStatusTitle;
  static String playlistsTitle(BuildContext context) =>
      AppLocalizations.of(context)!.playlistsTitle;

  static String unknownArtist(BuildContext context) =>
      AppLocalizations.of(context)!.unknownArtist;

  static const String audioPlayerChannelId = 'com.mraphaelpy.filely.audio';
  static const String audioPlayerChannelName = 'Filely Audio Player';
  static const String audioPlayerChannelDescription =
      'Controls for music playback';

  static String sortByNameAZ(BuildContext context) =>
      AppLocalizations.of(context)!.sortByNameAZ;
  static String sortByNameZA(BuildContext context) =>
      AppLocalizations.of(context)!.sortByNameZA;
  static String sortByDateNewest(BuildContext context) =>
      AppLocalizations.of(context)!.sortByDateNewest;
  static String sortByDateOldest(BuildContext context) =>
      AppLocalizations.of(context)!.sortByDateOldest;
  static String sortBySize(BuildContext context) =>
      AppLocalizations.of(context)!.sortBySize;

  static String permissionDeniedTitle(BuildContext context) =>
      AppLocalizations.of(context)!.permissionDeniedTitle;
  static String permissionDeniedMessage(BuildContext context) =>
      AppLocalizations.of(context)!.permissionDeniedMessage;
  static String permissionPermanentlyDeniedMessage(BuildContext context) =>
      AppLocalizations.of(context)!.permissionPermanentlyDeniedMessage;

  static String loading(BuildContext context) =>
      AppLocalizations.of(context)!.loading;
  static String retry(BuildContext context) =>
      AppLocalizations.of(context)!.retry;
  static String openSettings(BuildContext context) =>
      AppLocalizations.of(context)!.openSettings;
  static String cancel(BuildContext context) =>
      AppLocalizations.of(context)!.cancel;
  static String ok(BuildContext context) => AppLocalizations.of(context)!.ok;

  static String playlistRenamedSuccess(BuildContext context) =>
      AppLocalizations.of(context)!.playlistRenamedSuccess;
  static String playlistDeletedSuccess(BuildContext context) =>
      AppLocalizations.of(context)!.playlistDeletedSuccess;
  static String playlistEmptyMessage(BuildContext context) =>
      AppLocalizations.of(context)!.playlistEmptyMessage;
  static String playingPlaylist(BuildContext context) =>
      AppLocalizations.of(context)!.playingPlaylist;
  static String renamePlaylist(BuildContext context) =>
      AppLocalizations.of(context)!.renamePlaylist;
  static String deletePlaylist(BuildContext context) =>
      AppLocalizations.of(context)!.deletePlaylist;
  static String playPlaylist(BuildContext context) =>
      AppLocalizations.of(context)!.playPlaylist;
  static String deleteConfirmMessage(BuildContext context) =>
      AppLocalizations.of(context)!.deleteConfirmMessage;
  static String actionCannotBeUndone(BuildContext context) =>
      AppLocalizations.of(context)!.actionCannotBeUndone;
  static String undo(BuildContext context) =>
      AppLocalizations.of(context)!.undo;
  static const String featureNotAvailable = 'Recurso não disponível';
  //criar o de cancelar
  static String cancelAction(BuildContext context) =>
      AppLocalizations.of(context)!.cancel;
  
  static String deleteAction(BuildContext context) =>
      AppLocalizations.of(context)!.deleteConfirmMessage;
}
