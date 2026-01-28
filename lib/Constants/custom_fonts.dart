import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomFonts{


  static TextStyle mainHeadingStyle = GoogleFonts.openSans(
    textStyle: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.black, letterSpacing: .5),
  );


  static TextStyle headingStyle = GoogleFonts.roboto(
    textStyle: const TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: Colors.black, letterSpacing: .5),
  );

  static TextStyle subHeadingStyle = GoogleFonts.montserrat(
    textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w300,
        color: Colors.black,),
  );
}