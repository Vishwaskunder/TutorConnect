import 'package:flutter/material.dart';
import 'dart:async';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();

    // Redirect to HomePage after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home'); // Navigate to home page
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set the background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular logo
            ClipOval(
              child: Image.asset(
                'assets/images/logo1.webp',
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to TutorConnect',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 60),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:async';

// class LandingPage extends StatefulWidget {
//   const LandingPage({super.key});

//   @override
//   _LandingPageState createState() => _LandingPageState();
// }

// class _LandingPageState extends State<LandingPage> {
//   @override
//   void initState() {
//     super.initState();

//     // Redirect to HomePage after 3 seconds
//     Timer(const Duration(seconds: 3), () {
//       Navigator.pushReplacementNamed(context, '/home'); // Navigate to home page
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Set the background color
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Circular logo
//             ClipOval(
//               child: Image.asset(
//                 'assets/images/logo1.webp',
//                 height: 300,
//                 width: 300,
//                 fit: BoxFit.cover, 
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Welcome to TutorConnect',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),

//             const SizedBox(height: 60),
//             const Text(
//                 'loading......',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.grey,
//                 ),

//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
