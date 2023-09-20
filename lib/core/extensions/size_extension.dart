import 'package:flutter/material.dart';

extension SizeExtension on BuildContext {
  double get deviceWidht => MediaQuery.of(this).size.width;
  double get deviceHeight => MediaQuery.of(this).size.height;
  Size get fullSize => MediaQuery.of(this).size;
}
