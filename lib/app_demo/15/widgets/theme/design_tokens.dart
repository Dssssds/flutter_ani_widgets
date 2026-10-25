import 'package:flutter/material.dart';
import 'package:flutter_x_widgets/app_demo/15/widgets/theme/app_15_theme.dart';

class App15MapNodeToken {
  final double left;
  final double top;
  final double labelLeft;
  final double labelTop;
  final String label;

  const App15MapNodeToken({required this.left, required this.top, required this.labelLeft, required this.labelTop, required this.label});
}

class App15BirdToken {
  final double left;
  final double top;
  final double width;
  final double height;
  final double rotationDegrees;

  const App15BirdToken({required this.left, required this.top, required this.width, required this.height, required this.rotationDegrees});
}

/// 由 design_tokens.json 转换而来，页面与绘制器不再重复写魔法数字。
abstract final class App15Design {
  static const frameWidth = 390.0;
  static const frameHeight = 844.0;
  static const minFrameHeight = 740.0;
  static const contentMaxWidth = 430.0;

  static const buttonRadius = 18.0;
  static const cardRadius = 18.0;
  static const panelRadius = 22.0;
  static const sheetRadius = 28.0;
  static const modalRadius = 24.0;
  static const chipRadius = 12.0;

  static const nodeWidth = 76.0;
  static const nodeHeight = 61.0;
  static const currentNodeWidth = 86.0;
  static const currentNodeHeight = 69.0;
  static const nodeBorderWidth = 2.0;

  static const screenPadding = 24.0;
  static const pathSidePadding = 25.0;
  static const quizSidePadding = 24.0;
  static const sectionGap = 20.0;
  static const cardGap = 12.0;
  static const navHeight = 81.0;
  static const topBarHeight = 90.0;
  static const unitBannerPaddingX = 24.0;
  static const quizTopHeight = 77.0;

  static const buttonShadow = <BoxShadow>[BoxShadow(color: App15Theme.ink, offset: Offset(0, 6))];
  static const cardShadow = <BoxShadow>[BoxShadow(color: App15Theme.neutralShadow, offset: Offset(0, 4))];
  static const neutralButtonShadow = <BoxShadow>[BoxShadow(color: App15Theme.neutralBorder, offset: Offset(0, 4))];
  static const lockedShadow = <BoxShadow>[BoxShadow(color: App15Theme.lockedBorder, offset: Offset(0, 6))];
  static const completedShadow = <BoxShadow>[BoxShadow(color: App15Theme.mintDark, offset: Offset(0, 6))];
  static const currentNodeShadow = <BoxShadow>[BoxShadow(color: App15Theme.ink, offset: Offset(0, 8))];

  static const mapDesignWidth = 350.0;
  static const mapDesignHeight = 425.0;

  static const Map<String, App15MapNodeToken> mapNodes = {
    'greeting': App15MapNodeToken(left: 135, top: 17, labelLeft: 223, labelTop: 35, label: '打个招呼'),
    'menu': App15MapNodeToken(left: 67, top: 100, labelLeft: 157, labelTop: 116, label: '看懂菜单'),
    'coffee': App15MapNodeToken(left: 122, top: 173, labelLeft: 137, labelTop: 259, label: '点杯咖啡'),
    'directions': App15MapNodeToken(left: 209, top: 274, labelLeft: 302, labelTop: 290, label: '问个方向'),
    'challenge': App15MapNodeToken(left: 136, top: 352, labelLeft: 244, labelTop: 368, label: '单元挑战'),
  };

  static const bird = App15BirdToken(left: 232, top: 137, width: 112, height: 122, rotationDegrees: 7);

  static const baseTrailPath = 'M173 49C169 89 100 91 105 126S146 174 163 209s91 48 87 96-77 44-77 84';
  static const afterCoffeeTrailPath = 'M173 49C169 89 100 91 105 126s20 53 58 83';
  static const afterDirectionsTrailPath = 'M173 49C169 89 100 91 105 126S146 174 163 209s91 48 87 96';
  static const afterChallengeTrailPath = 'M173 49C169 89 100 91 105 126S146 174 163 209s91 48 87 96-77 44-77 84';
}
