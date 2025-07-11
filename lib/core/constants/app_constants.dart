class AppConstants {
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashDelay = Duration(seconds: 1);
  static const Duration longAnimationDuration = Duration(milliseconds: 1500);
  static const Duration shortDelay = Duration(milliseconds: 500);

  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 6.0;
  static const double largeBorderRadius = 16.0;

  static const double iconSize = 24.0;
  static const double largeIconSize = 32.0;
  static const double smallIconSize = 16.0;

  static const int fastForwardSeconds = 10;
  static const int rewindSeconds = 10;

  static List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  static const List<String> sortOptions = [
    'File name (A to Z)',
    'File name (Z to A)',
    'Date (Newest first)',
    'Date (Oldest first)',
    'Size',
  ];
}
