import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: Colors.grey.shade500, // Fixed typo 'gery' to 'grey'
    secondary: Colors.grey.shade200, // Fixed typo 'secoundary' to 'secondary'
    onPrimary: Colors.white, // Fixed typo 'Coors' to 'Colors'
    onSurface: Colors.black, // Added for proper contrast on background
  ),
);


// import 'package:flutter/material.dart';

// ThemeData lightMode = ThemeData(
//   colorScheme: ColorScheme.light(
//     background: Colors.grey.shade300,
//     primary:Colors.gery.shade500,
//     secoundary:Colors.gery.shade200,
//     tertiary:Coors.grey.white,
//     inversePrimary:Colors.gery.shade900,
//   ),
// );