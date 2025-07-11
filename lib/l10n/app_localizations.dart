import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];
  String get appName;
  String get explorerTitle;
  String get ftpTitle;
  String get settingsTitle;
  String get downloadsTitle;
  String get imagesTitle;
  String get videosTitle;
  String get audioTitle;
  String get documentsTitle;
  String get appsTitle;
  String get whatsappStatusTitle;
  String get playlistsTitle;
  String get unknownArtist;
  String get audioPlayerChannelName;
  String get audioPlayerChannelDescription;
  String get sortByNameAZ;
  String get sortByNameZA;
  String get sortByDateNewest;
  String get sortByDateOldest;
  String get sortBySize;
  String get permissionDeniedTitle;
  String get permissionDeniedMessage;
  String get permissionPermanentlyDeniedMessage;
  String get loading;
  String get retry;
  String get openSettings;
  String get cancel;
  String get ok;
  String get playlistRenamedSuccess;
  String get playlistDeletedSuccess;
  String get playlistEmptyMessage;
  String get playingPlaylist;
  String get renamePlaylist;
  String get deletePlaylist;
  String get playPlaylist;
  String get deleteConfirmMessage;
  String get actionCannotBeUndone;
  String get undo;
  String get appearance;
  String get files;
  String get aboutApp;
  String get toggleTheme;
  String get lightTheme;
  String get darkTheme;
  String get colorCustomization;
  String get colorCustomizationSubtitle;
  String get showHiddenFiles;
  String get showHiddenFilesSubtitle;
  String get sortFilesBy;
  String get clearCache;
  String get clearCacheSubtitle;
  String get cacheCleared;
  String get aboutFilely;
  String get aboutFilelySubtitle;
  String get rateApp;
  String get rateAppSubtitle;
  String get openSourceLicenses;
  String get openSourceLicensesSubtitle;
  String get version;
  String get sortBy;
  String get close;
  String get sortByName;
  String get sortByNameDesc;
  String get sortByDateNew;
  String get sortByDateOld;
  String get sortBySizeLarge;
  String get sortBySizeSmall;
  String get sortByType;
  String get language;
  String get languageSubtitle;
  String get portuguese;
  String get english;
  String get spanish;
  String get languageChanged;
  String get restartRequired;
  String get selectLanguage;
  String get informationTitle;
  String get errorLoadingInfo;
  String get generalInfo;
  String get fileInfo;
  String get directoryInfo;
  String get dates;
  String get permissions;
  String get location;
  // String get size;
  // String get type;
  // String get name;
  // String get created;
  // String get modified;
  // String get accessed;
  // String get hidden;
  // String get readOnly;
  // String get writable;
  // String get executable;
  // String get notHidden;
  // String get notReadOnly;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
