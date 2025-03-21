
import 'package:flutter/material.dart';

/// 用于像 CSS 一样定义 margin，支持 1-4 个参数
EdgeInsets cssMargin([double? top, double? right, double? bottom, double? left]) {
  if (top != null && right == null && bottom == null && left == null) {
    return EdgeInsets.all(top); // margin: 10px;
  } else if (top != null && right != null && bottom == null && left == null) {
    return EdgeInsets.symmetric(vertical: top, horizontal: right); // margin: 10px 20px;
  } else if (top != null && right != null && bottom != null && left == null) {
    return EdgeInsets.only(top: top, right: right, bottom: bottom, left: right); // margin: 10px 20px 30px;
  } else if (top != null && right != null && bottom != null && left != null) {
    return EdgeInsets.only(top: top, right: right, bottom: bottom, left: left); // margin: 10px 20px 30px 40px;
  }
  return EdgeInsets.zero; // 默认无边距
}


/// 用于像 CSS 一样定义 padding，支持 1-4 个参数
EdgeInsets cssPadding([double? top, double? right, double? bottom, double? left]) {
  if (top != null && right == null && bottom == null && left == null) {
    return EdgeInsets.all(top); // padding: 10px;
  } else if (top != null && right != null && bottom == null && left == null) {
    return EdgeInsets.symmetric(vertical: top, horizontal: right); // padding: 10px 20px;
  } else if (top != null && right != null && bottom != null && left == null) {
    return EdgeInsets.only(top: top, right: right, bottom: bottom, left: right); // padding: 10px 20px 30px;
  } else if (top != null && right != null && bottom != null && left != null) {
    return EdgeInsets.only(top: top, right: right, bottom: bottom, left: left); // padding: 10px 20px 30px 40px;
  }
  return EdgeInsets.zero; // 默认无内边距
}


/// 用于像 CSS 一样定义 border-radius
BorderRadius cssBorderRadius([double? topLeft, double? topRight, double? bottomRight, double? bottomLeft]) {
  if (topLeft != null && topRight == null && bottomRight == null && bottomLeft == null) {
    return BorderRadius.circular(topLeft); // border-radius: 10px;
  } else if (topLeft != null && topRight != null && bottomRight == null && bottomLeft == null) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
    ); // border-radius: 10px 20px;
  } else if (topLeft != null && topRight != null && bottomRight != null && bottomLeft == null) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomRight: Radius.circular(bottomRight),
    ); // border-radius: 10px 20px 30px;
  } else if (topLeft != null && topRight != null && bottomRight != null && bottomLeft != null) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft),
      topRight: Radius.circular(topRight),
      bottomRight: Radius.circular(bottomRight),
      bottomLeft: Radius.circular(bottomLeft),
    ); // border-radius: 10px 20px 30px 40px;
  }
  return BorderRadius.zero; // 默认无圆角
}


/// 用于像 CSS 一样定义 box-shadow
List<BoxShadow> cssBoxShadow({
  double x = 0,
  double y = 2,
  double blur = 4,
  double spread = 0,
  Color color = Colors.black26,
}) {
  return [
    BoxShadow(
      offset: Offset(x, y),
      blurRadius: blur,
      spreadRadius: spread,
      color: color,
    ),
  ];
}
