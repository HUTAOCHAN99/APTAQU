import 'package:flutter/material.dart';
import 'package:al_quran/core/constant/colors.dart';

class CrosswordTheme {
  final Color gridBackgroundColor;
  final Color gridLinesColor;
  final Color emptySpaceColor;
  final Color activeCellColor;
  final Color inactiveCellColor;
  final Color inputTextColor;
  final Color cellHighlightColor;
  final Color clueNumberColor;
  final double borderWidth;

  const CrosswordTheme({
    this.gridBackgroundColor = const Color(0xFFF5F5F5),
    this.gridLinesColor = AppColors.lightGrey,
    this.emptySpaceColor = Colors.white,
    this.activeCellColor = Colors.white,
    this.inactiveCellColor = Colors.black,
    this.inputTextColor = Colors.black,
    this.cellHighlightColor = const Color(0xFFFFECB3),
    this.clueNumberColor = Colors.black,
    this.borderWidth = 1.5,
  });

  static const CrosswordTheme light = CrosswordTheme();
  
  static const CrosswordTheme dark = CrosswordTheme(
    gridBackgroundColor: AppColors.darkGrey,
    gridLinesColor: AppColors.mediumGrey,
    emptySpaceColor: Color(0xFF303030),
    activeCellColor: Color(0xFF545454),
    inactiveCellColor: Color(0xFF212121),
    inputTextColor: Colors.white,
    cellHighlightColor: AppColors.mediumGrey,
    clueNumberColor: Colors.white,
  );
}