import 'package:al_quran/core/constant/constants.dart';

class CrosswordConfig {
  final int gridSize;
  final double cellPadding;
  final double borderWidth;
  final bool showClueNumbers;
  final bool autoCapitalize;
  final bool highlightActiveCell;
  final bool showHints;
  final bool showTimer;
  final bool allowWrapAround;

  const CrosswordConfig({
    this.gridSize = CrosswordConstants.defaultGridSize,
    this.cellPadding = CrosswordConstants.defaultCellPadding,
    this.borderWidth = CrosswordConstants.defaultBorderWidth,
    this.showClueNumbers = true,
    this.autoCapitalize = true,
    this.highlightActiveCell = true,
    this.showHints = true,
    this.showTimer = true,
    this.allowWrapAround = false,
  });

  CrosswordConfig copyWith({
    int? gridSize,
    double? cellPadding,
    double? borderWidth,
    bool? showClueNumbers,
    bool? autoCapitalize,
    bool? highlightActiveCell,
    bool? showHints,
    bool? showTimer,
    bool? allowWrapAround,
  }) {
    return CrosswordConfig(
      gridSize: gridSize ?? this.gridSize,
      cellPadding: cellPadding ?? this.cellPadding,
      borderWidth: borderWidth ?? this.borderWidth,
      showClueNumbers: showClueNumbers ?? this.showClueNumbers,
      autoCapitalize: autoCapitalize ?? this.autoCapitalize,
      highlightActiveCell: highlightActiveCell ?? this.highlightActiveCell,
      showHints: showHints ?? this.showHints,
      showTimer: showTimer ?? this.showTimer,
      allowWrapAround: allowWrapAround ?? this.allowWrapAround,
    );
  }
}