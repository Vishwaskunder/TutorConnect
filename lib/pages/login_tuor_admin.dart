import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore package
import 'package:firebase_core/firebase_core.dart'; // Add Firebase package
import 'package:tutorconnect_app/pages/admin_board_page.dart';
import 'package:tutorconnect_app/pages/tutor_board_page.dart';
// import 'package:crypto/crypto.dart';
// import 'dart:convert';

class LoginTutorAdminPage extends StatefulWidget {
  const LoginTutorAdminPage({super.key});

  @override
  State<LoginTutorAdminPage> createState() => _LoginTutorAdminPageState();
}

class _LoginTutorAdminPageState extends State<LoginTutorAdminPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isAdminLogin = false; // Toggle between Tutor and Admin Login

  // Mock admin database for login validation
  final Map<String, String> adminDatabase = {
    'admin1': 'adminpass123',
    'vishu': '4444',
  };

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp(); // Initialize Firebase
  }

  // Function to validate tutor credentials from Firestore
  Future<bool> _validateTutorCredentials(String username, String password) async {
    

    try {

      // var hashedPassword = sha256.convert(utf8.encode(password)).toString();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('tutor_credential')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error validating credentials: $e');
      return false;
    }
  }

  // Function to validate login
  void _checkLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (_isAdminLogin) {
      // Validate Admin Login
      if (adminDatabase.containsKey(username) && adminDatabase[username] == password) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, Admin $username! Login successful.'),
            backgroundColor: Colors.green,
          ),
        );
        // Redirect to AdminBoard
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminBoard(username: username)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid admin username or password. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Validate Tutor Login
      final isValid = await _validateTutorCredentials(username, password);
      if (isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome, $username! Login successful.'),
            backgroundColor: Colors.green,
          ),
        );
        // Redirect to TutorBoard
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TutorBoard(username: username)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid tutor username or password. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Function to open Gmail directly for requesting credentials
  Future<void> _openGmail() async {
    const String email = 'vishwaskunder1@gmail.com';
    const String subject = 'Requesting Login Credentials';
    const String body =
        'Dear Admin,%0D%0A%0D%0AI would like to request login credentials for TutorConnect. '
        'Please find my details below.%0D%0A%0D%0AName: %0D%0AContact: %0D%0ADocuments: %0D%0A%0D%0AThank you!';
    const String gmailUrl =
        'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=$subject&body=$body';

    if (await canLaunchUrl(Uri.parse(gmailUrl))) {
      await launchUrl(Uri.parse(gmailUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open Gmail. Please install the Gmail app or check your settings.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Center(
                child: Text(
                  _isAdminLogin ? 'Admin Login' : 'Tutor Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter your credentials',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _checkLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.deepPurple,
                ),
                child: Text(
                  _isAdminLogin ? 'Login as Admin' : 'Login as Tutor',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              if (!_isAdminLogin) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.info, color: Colors.deepPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Don’t have login credentials? Request credentials by sending your tutor details and documents to vishwaskunder1@gmail.com.',
                          style: TextStyle(color: Colors.deepPurple[800]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _openGmail,
                  icon: const Icon(Icons.email_outlined, color: Colors.deepPurple),
                  label: const Text(
                    'Request Credentials',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.deepPurple),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isAdminLogin = !_isAdminLogin;
                  });
                },
                child: Text(
                  _isAdminLogin
                      ? 'Switch to Tutor Login'
                      : 'Switch to Admin Login',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:tutorconnect_app/pages/admin_board_page.dart';
// import 'package:tutorconnect_app/pages/tutor_board_page.dart';

// class LoginTutorAdminPage extends StatefulWidget {
//   const LoginTutorAdminPage({Key? key}) : super(key: key);

//   @override
//   State<LoginTutorAdminPage> createState() => _LoginTutorAdminPageState();
// }

// class _LoginTutorAdminPageState extends State<LoginTutorAdminPage> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isAdminLogin = false; // Toggle between Tutor and Admin Login

//   // Mock database for login validation
//   final Map<String, String> tutorDatabase = {
//     'tutor1': 'password123',
//     'tutor2': 'securepass',
//     'tutor3': 'tutorpass',
//   };

//   final Map<String, String> adminDatabase = {
//     'admin1': 'adminpass123',
//     'superadmin': 'supersecure',
//   };

//   // Function to validate login
//   void _checkLogin() {
//     final username = _usernameController.text;
//     final password = _passwordController.text;

//     if (_isAdminLogin) {
//       // Validate Admin Login
//       if (adminDatabase.containsKey(username) && adminDatabase[username] == password) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Welcome, Admin $username! Login successful.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         // Redirect to AdminBoard
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => AdminBoard(username: username)),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Invalid admin username or password. Please try again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } else {
//       // Validate Tutor Login
//       if (tutorDatabase.containsKey(username) && tutorDatabase[username] == password) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Welcome, $username! Login successful.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         // Redirect to TutorBoard
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => TutorBoard(username: username)),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Invalid tutor username or password. Please try again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Function to open Gmail directly for requesting credentials
//   Future<void> _openGmail() async {
//     const String email = 'vishwaskunder1@gmail.com';
//     const String subject = 'Requesting Login Credentials';
//     const String body =
//         'Dear Admin,%0D%0A%0D%0AI would like to request login credentials for TutorConnect. '
//         'Please find my details below.%0D%0A%0D%0AName: %0D%0AContact: %0D%0ADocuments: %0D%0A%0D%0AThank you!';
//     const String gmailUrl =
//         'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=$subject&body=$body';

//     if (await canLaunchUrl(Uri.parse(gmailUrl))) {
//       await launchUrl(Uri.parse(gmailUrl), mode: LaunchMode.externalApplication);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Unable to open Gmail. Please install the Gmail app or check your settings.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 30),
//               Center(
//                 child: Text(
//                   _isAdminLogin ? 'Admin Login' : 'Tutor Login',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.deepPurple,
//                   ),
//                 ),
//               ),
         
//               const SizedBox(height: 20),
//               const Text(
//                 'Enter your credentials',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _usernameController,
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Icons.person),
//                   labelText: 'Username',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Icons.lock),
//                   labelText: 'Password',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(12)),
//                   ),
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _checkLogin,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   backgroundColor: Colors.deepPurple,
//                 ),
//                 child: Text(
//                   _isAdminLogin ? 'Login as Admin' : 'Login as Tutor',
//                   style: const TextStyle(fontSize: 18),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               if (!_isAdminLogin) ...[
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.deepPurple[50],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.info, color: Colors.deepPurple),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           'Don’t have login credentials? Request credentials by sending your tutor details and documents to vishwaskunder1@gmail.com.',
//                           style: TextStyle(color: Colors.deepPurple[800]),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 OutlinedButton.icon(
//                   onPressed: _openGmail,
//                   icon: const Icon(Icons.email_outlined, color: Colors.deepPurple),
//                   label: const Text(
//                     'Request Credentials',
//                     style: TextStyle(color: Colors.deepPurple),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     side: BorderSide(color: Colors.deepPurple),
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 24),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _isAdminLogin = !_isAdminLogin;
//                   });
//                 },
//                 child: Text(
//                   _isAdminLogin
//                       ? 'Switch to Tutor Login'
//                       : 'Switch to Admin Login',
//                   style: TextStyle(color: Colors.deepPurple),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// // import 'package:flutter/material.dart';
// // import 'package:url_launcher/url_launcher.dart';

// // class LoginTutorAdminPage extends StatefulWidget {
// //   const LoginTutorAdminPage({Key? key}) : super(key: key);

// //   @override
// //   State<LoginTutorAdminPage> createState() => _LoginTutorAdminPageState();
// // }

// // class _LoginTutorAdminPageState extends State<LoginTutorAdminPage> {
// //   final TextEditingController _usernameController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //   bool _isAdminLogin = false; // Toggle between Tutor and Admin Login

// //   // Mock database for login validation
// //   final Map<String, String> tutorDatabase = {
// //     'tutor1': 'password123',
// //     'tutor2': 'securepass',
// //     'tutor3': 'tutorpass',
// //   };

// //   final Map<String, String> adminDatabase = {
// //     'admin1': 'adminpass123',
// //     'superadmin': 'supersecure',
// //   };

// //   // Function to validate login
// //   void _checkLogin() {
// //     final username = _usernameController.text;
// //     final password = _passwordController.text;

// //     if (_isAdminLogin) {
// //       // Validate Admin Login
// //       if (adminDatabase.containsKey(username) && adminDatabase[username] == password) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Welcome, Admin $username! Login successful.'),
// //             backgroundColor: Colors.green,
// //           ),
// //         );
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('Invalid admin username or password. Please try again.'),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     } else {
// //       // Validate Tutor Login
// //       if (tutorDatabase.containsKey(username) && tutorDatabase[username] == password) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Welcome, $username! Login successful.'),
// //             backgroundColor: Colors.green,
// //           ),
// //         );
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('Invalid tutor username or password. Please try again.'),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   // Function to open Gmail directly
// //   Future<void> _openGmail() async {
// //     const String email = 'vishwaskunder1@gmail.com';
// //     const String subject = 'Requesting Login Credentials';
// //     const String body =
// //         'Dear Admin,%0D%0A%0D%0AI would like to request login credentials for TutorConnect. '
// //         'Please find my details below.%0D%0A%0D%0AName: %0D%0AContact: %0D%0ADocuments: %0D%0A%0D%0AThank you!';
// //     const String gmailUrl =
// //         'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=$subject&body=$body';

// //     if (await canLaunchUrl(Uri.parse(gmailUrl))) {
// //       await launchUrl(Uri.parse(gmailUrl), mode: LaunchMode.externalApplication);
// //     } else {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text('Unable to open Gmail. Please install the Gmail app or check your settings.'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
       
// //       ),
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               const SizedBox(height: 30),
// //               Center(
// //                 child: Text(
// //                   _isAdminLogin ? 'Admin Login' : 'Tutor Login',
// //                   style: TextStyle(
// //                     fontSize: 28,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.deepPurple,
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Center(
// //                 child: Text(
// //                   _isAdminLogin
// //                       ? 'Login to access your admin dashboard'
// //                       : 'Login to access your tutor dashboard',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     color: Colors.grey[600],
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 30),
// //               const Text(
// //                 'Enter your credentials',
// //                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
// //               ),
// //               const SizedBox(height: 16),
// //               TextField(
// //                 controller: _usernameController,
// //                 decoration: const InputDecoration(
// //                   prefixIcon: Icon(Icons.person),
// //                   labelText: 'Username',
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.all(Radius.circular(12)),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 16),
// //               TextField(
// //                 controller: _passwordController,
// //                 decoration: const InputDecoration(
// //                   prefixIcon: Icon(Icons.lock),
// //                   labelText: 'Password',
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.all(Radius.circular(12)),
// //                   ),
// //                 ),
// //                 obscureText: true,
// //               ),
// //               const SizedBox(height: 24),
// //               ElevatedButton(
// //                 onPressed: _checkLogin,
// //                 style: ElevatedButton.styleFrom(
// //                   padding: const EdgeInsets.symmetric(vertical: 16),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   backgroundColor: Colors.deepPurple,
// //                 ),
// //                 child: Text(
// //                   _isAdminLogin ? 'Login as Admin' : 'Login as Tutor',
// //                   style: const TextStyle(fontSize: 18),
// //                 ),
// //               ),
// //               const SizedBox(height: 20),
// //               if (!_isAdminLogin)
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     color: Colors.deepPurple[50],
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   padding: const EdgeInsets.all(16),
// //                   child: Row(
// //                     children: [
// //                       const Icon(Icons.info, color: Colors.deepPurple),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: Text(
// //                           'Don’t have login credentials? Request credentials by sending your tutor details and documents to vishwaskunder1@gmail.com.',
// //                           style: TextStyle(color: Colors.deepPurple[800]),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               if (!_isAdminLogin) const SizedBox(height: 16),
// //               if (!_isAdminLogin)
// //                 OutlinedButton.icon(
// //                   onPressed: _openGmail,
// //                   icon: const Icon(Icons.email_outlined, color: Colors.deepPurple),
// //                   label: const Text(
// //                     'Request Credentials',
// //                     style: TextStyle(color: Colors.deepPurple),
// //                   ),
// //                   style: OutlinedButton.styleFrom(
// //                     side: BorderSide(color: Colors.deepPurple),
// //                     padding: const EdgeInsets.symmetric(vertical: 14),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                   ),
// //                 ),
// //               const SizedBox(height: 24),
// //               TextButton(
// //                 onPressed: () {
// //                   setState(() {
// //                     _isAdminLogin = !_isAdminLogin;
// //                   });
// //                 },
// //                 child: Text(
// //                   _isAdminLogin
// //                       ? 'Switch to Tutor Login'
// //                       : 'Switch to Admin Login',
// //                   style: TextStyle(color: Colors.deepPurple),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

