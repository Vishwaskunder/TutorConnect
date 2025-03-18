import 'package:flutter/material.dart';

class SquareTitle extends StatelessWidget {
  final Function()? onTap;
  final String imagePath;

  const SquareTitle({super.key, required this.onTap, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Image.asset(
          imagePath,
          height: 30,
          width: 30,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// class SquareTitle extends StatelessWidget {
//   final VoidCallback onTap;
//   final String imagePath;
//
//   const SquareTitle({super.key, required this.onTap, required this.imagePath});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(15),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(10),
//           color: Colors.white,
//         ),
//         child: Image.asset(
//           imagePath,
//           height: 30,
//           width: 30,
//         ),
//       ),
//     );
//   }
// }
//

// import 'package:flutter/material.dart';
//
// class SquareTitle extends StatelessWidget {
//   final String imagePath;
//   final Function()? onTap;
//
//   const SquareTitle({
//     Key? key,
//     required this.imagePath,
//     this.onTap, // Optional onTap callback
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap, // Executes onTap function if not null
//       child: Container(
//         padding: const EdgeInsets.all(20), // Padding around the content
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.white), // White border
//           borderRadius: BorderRadius.circular(16), // Rounded corners
//           color: Colors.grey[400], // Background color
//         ),
//         child: Image.asset(
//           imagePath, // Image path passed as argument
//           height: 40, // Image height
//         ),
//       ),
//     );
//   }
// }
//
//
