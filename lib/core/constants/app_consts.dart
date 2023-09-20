import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextConstants {
  TextStyle smallTitleTextStyle({
    double fsize = 20,
    color = Colors.black,
  }) {
    //textStyle for only small titles like choose your age
    return GoogleFonts.aldrich(
        fontSize: fsize, color: color, fontWeight: FontWeight.bold);
  }
}
