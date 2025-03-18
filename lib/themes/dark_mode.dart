import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(  // Using ColorScheme.dark for dark mode
    surface: Colors.grey.shade900,
    primary: Colors.grey.shade600,  // Fixed typo 'gery' to 'grey'
    secondary: const Color.fromARGB(255, 57, 57, 57), // Fixed typo 'secoundary' to 'secondary'
    onPrimary: Colors.white,  // Define text color on primary color
    onSurface: Colors.white,  // Define text color on background
  ),
);


// import 'package:flutter/material.dart';

// ThemeData darkMode = ThemeData(
//   colorScheme: ColorScheme.light(
//     background: Colors.grey.shade900,
//     primary:Colors.gery.shade600,
//     secoundary:const Color.fromARGB(255,57,57,57),
//     tertiary:Coors.grey.shade800,
//     inversePrimary:Colors.gery.shade300,
//   ),
// );