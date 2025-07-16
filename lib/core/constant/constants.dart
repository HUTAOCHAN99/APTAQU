import 'package:flutter/material.dart';

class CrosswordConstants {
  static const int defaultGridSize = 5;
  static const double defaultCellPadding = 0.5;
  static const double defaultBorderWidth = 0.5;
  static const double minCellSize = 25.0;
  static const double maxCellSize = 50.0;
  
  static const double maxGridWidthPercentage = 0.95;
  static const double maxGridHeightPercentage = 0.6;
  static const double cellBorderWidth = 0.5;
  static const double smallDeviceThreshold = 360.0;
  
  static double getCellSize(BuildContext context, int gridSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final baseSize = screenWidth / (gridSize + 2);
    return baseSize.clamp(
      gridSize <= 3 ? 30.0 : 25.0,
      gridSize <= 3 ? 50.0 : 40.0
    );
  }
}