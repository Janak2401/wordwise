class AppDimensions {
  // Tile grid
  static const double tileGap = 5.0;
  static const double maxTileSize = 62.0;

  // Keyboard: key height scales with screen height between these bounds.
  static const double keyHeightMin = 40.0;
  static const double keyHeightMax = 52.0;
  static const double keyHeightScreenRatio = 0.06;
  static const double keyGapH = 5.0;
  static const double keyGapV = 7.0;

  /// Height of the strip under the grid holding the guess counter or SEE RESULTS button.
  static const double statusStripHeight = 40.0;

  /// Game content stays this wide at most on tablets.
  static const double contentMaxWidth = 500.0;

  /// Upper bound for the system font scale on tiles and keys, which size their own text.
  static const double maxGameTextScale = 1.2;
}
