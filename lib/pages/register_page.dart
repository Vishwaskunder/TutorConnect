import 'package:flutter/material.dart';
import 'package:tutorconnect_app/components/my_button.dart';
import 'package:tutorconnect_app/components/mytestfield.dart';
import 'package:tutorconnect_app/components/square_title.dart';
import 'package:tutorconnect_app/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Method to sign up the user
  void signUserUp() async {
    // Show loading dialog
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Check if passwords match
      if (passwordController.text == confirmPasswordController.text) {
        // Register user
        await AuthService()
            .signUpWithEmailPassword(emailController.text, passwordController.text);

        // Close loading dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        // Navigate to login page
        widget.onTap?.call();
      } else {
        // Close loading dialog
        Navigator.pop(context);

        // Show error message for mismatched passwords
        _showErrorMessage("Passwords don't match!");
      }
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      _showErrorMessage(e.toString());
    }
  }

  // Method for Google Sign-In
  void signInWithGoogle() async {
    try {
      await AuthService().signInWithGoogle();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in with Google successfully!')),
      );

      // Navigate to login page
      widget.onTap?.call();
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

  // Show error message dialog
  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.redAccent,
          title: const Text(
            'Error',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),

                // Icon
                const Icon(Icons.lock, size: 100),

                const SizedBox(height: 30),

                // Welcome text
                const Text(
                  "Let's create an account for you!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // Email text field
                Mytestfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // Password text field
                Mytestfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // Confirm password text field
                Mytestfield(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // Sign up button
                MyButton(
                  text: "Sign up",
                  onTap: signUserUp,
                ),

                const SizedBox(height: 25),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Google sign-in button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTitle(
                      onTap: signInWithGoogle, // Fixed onTap
                      imagePath: 'assets/images/google.png',
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Already have an account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        'Login now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:tutorconnect_app/components/my_button.dart';
// import 'package:tutorconnect_app/components/mytestfield.dart';
// import 'package:tutorconnect_app/components/square_title.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:tutorconnect_app/services/auth_service.dart';
//
// // import 'package:tutor_connect/srevices/auth_services.dart';
//
// class RegisterPage extends StatefulWidget {
//   final Function()? onTap;
//
//   const RegisterPage({super.key, required this.onTap});
//
//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }
//
// class _RegisterPageState extends State<RegisterPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//
//   void signUserUp() async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );
//
//     try {
//       if (passwordController.text == confirmPasswordController.text) {
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: emailController.text,
//           password: passwordController.text,
//         );
//       } else {
//         Navigator.pop(context);
//         showErrorMessage("Passwords don't match!");
//       }
//
//       Navigator.pop(context);
//     } on FirebaseAuthException catch (e) {
//       Navigator.pop(context);
//       showErrorMessage(e.code);
//     }
//   }
//
//   void showErrorMessage(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.deepPurple,
//           title: Text(
//             message,
//             style: const TextStyle(color: Colors.white),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 30),
//                 const Icon(
//                   Icons.lock,
//                   size: 100,
//                 ),
//                 const SizedBox(height: 30),
//                 const Text(
//                   'Let\'s create an account for you!',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Mytestfield(
//                   controller: emailController,
//                   hintText: 'Email',
//                   obscureText: false,
//                 ),
//                 const SizedBox(height: 10),
//                 Mytestfield(
//                   controller: passwordController,
//                   hintText: 'Password',
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 10),
//                 Mytestfield(
//                   controller: confirmPasswordController,
//                   hintText: 'Confirm Password',
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 10),
//                 MyButton(
//                   text: "Sign up",
//                   onTap: signUserUp,
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Divider(
//                         thickness: 0.5,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 10.0),
//                       child: Text(
//                         'Or continue with',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                     Expanded(
//                       child: Divider(
//                         thickness: 0.5,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//                 const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SquareTitle(
//                       onTap: ()=>AuthService().signInWithGoogle(),
//                       imagePath: 'assets/images/google.png'),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Already have an account?',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(width: 4),
//                     GestureDetector(
//                       onTap: widget.onTap,
//                       child: const Text(
//                         'Login now',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:tutorconnect_app/components/my_button.dart';
// import 'package:tutorconnect_app/components/mytestfield.dart';
// import 'package:tutorconnect_app/components/square_title.dart';
// import 'package:tutorconnect_app/services/auth_service.dart';

// class RegisterPage extends StatefulWidget {
//   final Function()? onTap;
//   const RegisterPage({super.key, required this.onTap});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();

//   void signUserUp() async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return const Center(child: CircularProgressIndicator());
//       },
//     );

//     try {
//       if (passwordController.text == confirmPasswordController.text) {
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: emailController.text.trim(),
//           password: passwordController.text.trim(),
//         );
//         Navigator.pop(context);
//       } else {
//         Navigator.pop(context);
//         showErrorMessage("Passwords don't match!");
//       }
//     } on FirebaseAuthException catch (e) {
//       Navigator.pop(context);
//       showErrorMessage(e.message ?? "An error occurred.");
//     }
//   }

//   void showErrorMessage(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.deepPurple,
//           title: Text(
//             message,
//             style: const TextStyle(color: Colors.white),
//           ),
//         );
//       },
//     );
//   }

//   void signInWithGoogle() async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return const Center(child: CircularProgressIndicator());
//       },
//     );

//     try {
//       UserCredential? userCredential = await AuthService().signInWithGoogle();
//       Navigator.pop(context);

//       if (userCredential != null) {
//         Navigator.pushReplacementNamed(context, '/home');
//       } else {
//         showErrorMessage("Google sign-in failed");
//       }
//     } catch (e) {
//       Navigator.pop(context);
//       showErrorMessage("Error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.background,
//       // backgroundColor: Colors.grey[200],
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 30),
//                 const Icon(Icons.lock, size: 100),
//                 const SizedBox(height: 30),
//                 const Text(
//                   'Let\'s create an account for you!',
//                   style: TextStyle(color: Colors.black, fontSize: 16),
//                 ),
//                 const SizedBox(height: 25),
//                 Mytestfield(
//                   controller: emailController,
//                   hintText: 'Email',
//                   obscureText: false,
//                 ),
//                 const SizedBox(height: 10),
//                 Mytestfield(
//                   controller: passwordController,
//                   hintText: 'Password',
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 10),
//                 Mytestfield(
//                   controller: confirmPasswordController,
//                   hintText: 'Confirm Password',
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 10),
//                 MyButton(
//                   text: "Sign up",
//                   onTap: signUserUp,
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Divider(
//                         thickness: 0.5,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 10.0),
//                       child: Text(
//                         'Or continue with',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                     Expanded(
//                       child: Divider(
//                         thickness: 0.5,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SquareTitle(
//                       onTap: signInWithGoogle,
//                       imagePath: 'assets/images/google.png',
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Already have an account?',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(width: 4),
//                     GestureDetector(
//                       onTap: widget.onTap,
//                       child: const Text(
//                         'Login now',
//                         style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:tutorconnect_app/components/my_button.dart';
// import 'package:tutorconnect_app/components/mytestfield.dart';
// import 'package:tutorconnect_app/components/square_title.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:tutorconnect_app/services/auth_service.dart';
//
// class RegisterPage extends StatefulWidget {
//   final Function()? onTap;
//
//   const RegisterPage({super.key, required this.onTap});
//
//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }
//
// class _RegisterPageState extends State<RegisterPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//
//   void signUserUp() async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return const Center(child: CircularProgressIndicator());
//       },
//     );
//
//     try {
//       if (passwordController.text == confirmPasswordController.text) {
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//           email: emailController.text,
//           password: passwordController.text,
//         );
//         Navigator.pop(context);
//       } else {
//         Navigator.pop(context);
//         showErrorMessage("Passwords don't match!");
//       }
//     } on FirebaseAuthException catch (e) {
//       Navigator.pop(context);
//       showErrorMessage(e.message ?? "An error occurred.");
//     }
//   }
//
//   void showErrorMessage(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.deepPurple,
//           title: Text(
//             message,
//             style: const TextStyle(color: Colors.white),
//           ),
//         );
//       },
//     );
//   }
//
//   void signInWithGoogle() async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return const Center(child: CircularProgressIndicator());
//       },
//     );
//
//     try {
//       UserCredential? userCredential = await AuthService().signInWithGoogle();
//       Navigator.pop(context); // Dismiss progress indicator
//
//       if (userCredential != null) {
//         Navigator.pushReplacementNamed(context, '/home');
//       } else {
//         showErrorMessage("Google sign-in failed");
//       }
//     } catch (e) {
//       Navigator.pop(context);
//       showErrorMessage("Error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 30),
//                 const Icon(Icons.lock, size: 100),
//                 const SizedBox(height: 30),
//                 const Text(
//                   'Let\'s create an account for you!',
//                   style: TextStyle(color: Colors.black, fontSize: 16),
//                 ),
//                 const SizedBox(height: 25),
//                 Mytestfield(
//                   controller: emailController,
//                   hintText: 'Email',
//                   obscureText: false,
//                 ),
//                 const SizedBox(height: 10),
//                 Mytestfield(
//                   controller: passwordController,
//                   hintText: 'Password',
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 10),
//                 Mytestfield(
//                   controller: confirmPasswordController,
//                   hintText: 'Confirm Password',
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 10),
//                 MyButton(
//                   text: "Sign up",
//                   onTap: signUserUp,
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Divider(
//                         thickness: 0.5,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 10.0),
//                       child: Text(
//                         'Or continue with',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                     Expanded(
//                       child: Divider(
//                         thickness: 0.5,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SquareTitle(
//                       onTap: signInWithGoogle,
//                       imagePath: 'assets/images/google.png',
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Already have an account?',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(width: 4),
//                     GestureDetector(
//                       onTap: widget.onTap,
//                       child: const Text(
//                         'Login now',
//                         style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:tutorconnect_app/components/my_button.dart';
// import 'package:tutorconnect_app/components/mytestfield.dart';
// import 'package:tutorconnect_app/components/square_title.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:tutorconnect_app/services/auth_service.dart';
//
// class RegisterPage extends StatefulWidget {
//   final Function()? onTap;
//
//   const RegisterPage({super.key, required this.onTap});
//
//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }
//
// class _RegisterPageState extends State<RegisterPage> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//
//   // Function to register the user
//   void signUserUp() async {
//     // Show loading indicator
//     showDialog(
//       context: context,
//       builder: (context) {
//         return const Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );
//
//     try {
//       if (passwordController.text != confirmPasswordController.text) {
//         Navigator.pop(context);
//         showErrorMessage("Passwords don't match!");
//         return;
//       }
//
//       if (emailController.text.isEmpty || passwordController.text.isEmpty) {
//         Navigator.pop(context);
//         showErrorMessage("Please fill in all fields!");
//         return;
//       }
//
//       // Create user with email and password
//       await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );
//
//       Navigator.pop(context);
//     } on FirebaseAuthException catch (e) {
//       Navigator.pop(context);
//       showErrorMessage(e.message ?? "An error occurred.");
//     }
//   }
//
//   // Function to show error messages
//   void showErrorMessage(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           backgroundColor: Colors.deepPurple,
//           title: Text(
//             message,
//             style: const TextStyle(color: Colors.white),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 30),
//                 const Icon(
//                   Icons.lock,
//                   size: 100,
//                 ),
//                 const SizedBox(height: 30),
//                 const Text(
//                   'Let\'s create an account for you!',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 25),
//                 Mytestfield(
//                   controller: emailController,
//                   hintText: 'Email',
//                   obscureText: false,
//                 ),
//                 const SizedBox(height: 10),
//                 Mytestfield(
//                   controller: passwordController,
//                   hintText: 'Password',
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 10),
//                 Mytestfield(
//                   controller: confirmPasswordController,
//                   hintText: 'Confirm Password',
//                   obscureText: true,
//                 ),
//                 const SizedBox(height: 10),
//                 MyButton(
//                   text: "Sign up",
//                   onTap: signUserUp,
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Divider(
//                         thickness: 0.5,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 10.0),
//                       child: Text(
//                         'Or continue with',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                     Expanded(
//                       child: Divider(
//                         thickness: 0.5,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//                 // Remove const to allow dynamic behavior for onTap
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SquareTitle(
//                       onTap: () => AuthService().signInWithGoogle(),
//                       imagePath: 'assets/images/google.png', // Correct image path
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 25),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       'Already have an account?',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(width: 4),
//                     GestureDetector(
//                       onTap: widget.onTap,
//                       child: const Text(
//                         'Login now',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// //
// //
// // import 'package:flutter/material.dart';
// // import 'package:tutorconnect_app/components/my_button.dart';
// // import 'package:tutorconnect_app/components/mytestfield.dart';
// // import 'package:tutorconnect_app/components/square_title.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:tutorconnect_app/services/auth_service.dart';
// //
// // // import 'package:tutor_connect/srevices/auth_services.dart';
// //
// // class RegisterPage extends StatefulWidget {
// //   final Function()? onTap;
// //
// //   const RegisterPage({super.key, required this.onTap});
// //
// //   @override
// //   State<RegisterPage> createState() => _RegisterPageState();
// // }
// //
// // class _RegisterPageState extends State<RegisterPage> {
// //   final emailController = TextEditingController();
// //   final passwordController = TextEditingController();
// //   final confirmPasswordController = TextEditingController();
// //
// //   void signUserUp() async {
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return const Center(
// //           child: CircularProgressIndicator(),
// //         );
// //       },
// //     );
// //
// //     try {
// //       if (passwordController.text == confirmPasswordController.text) {
// //         await FirebaseAuth.instance.createUserWithEmailAndPassword(
// //           email: emailController.text,
// //           password: passwordController.text,
// //         );
// //       } else {
// //         Navigator.pop(context);
// //         showErrorMessage("Passwords don't match!");
// //       }
// //
// //       Navigator.pop(context);
// //     } on FirebaseAuthException catch (e) {
// //       Navigator.pop(context);
// //       showErrorMessage(e.code);
// //     }
// //   }
// //
// //   void showErrorMessage(String message) {
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           backgroundColor: Colors.deepPurple,
// //           title: Text(
// //             message,
// //             style: const TextStyle(color: Colors.white),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[200],
// //       body: SafeArea(
// //         child: Center(
// //           child: SingleChildScrollView(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const SizedBox(height: 30),
// //                 const Icon(
// //                   Icons.lock,
// //                   size: 100,
// //                 ),
// //                 const SizedBox(height: 30),
// //                 const Text(
// //                   'Let\'s create an account for you!',
// //                   style: TextStyle(
// //                     color: Colors.black,
// //                     fontSize: 16,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 25),
// //                 Mytestfield(
// //                   controller: emailController,
// //                   hintText: 'Email',
// //                   obscureText: false,
// //                 ),
// //                 const SizedBox(height: 10),
// //                 Mytestfield(
// //                   controller: passwordController,
// //                   hintText: 'Password',
// //                   obscureText: true,
// //                 ),
// //                 const SizedBox(height: 10),
// //                 Mytestfield(
// //                   controller: confirmPasswordController,
// //                   hintText: 'Confirm Password',
// //                   obscureText: true,
// //                 ),
// //                 const SizedBox(height: 10),
// //                 MyButton(
// //                   text: "Sign up",
// //                   onTap: signUserUp,
// //                 ),
// //                 const SizedBox(height: 25),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: Divider(
// //                         thickness: 0.5,
// //                         color: Colors.grey,
// //                       ),
// //                     ),
// //                     const Padding(
// //                       padding: EdgeInsets.symmetric(horizontal: 10.0),
// //                       child: Text(
// //                         'Or continue with',
// //                         style: TextStyle(color: Colors.grey),
// //                       ),
// //                     ),
// //                     Expanded(
// //                       child: Divider(
// //                         thickness: 0.5,
// //                         color: Colors.grey,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 25),
// //                 const Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     SquareTitle(
// //                       onTap: ()=>AuthService().signInWithGoogle(),
// //                       imagePath: 'assets/images/google.png'),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 25),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     const Text(
// //                       'Already have an account?',
// //                       style: TextStyle(color: Colors.grey),
// //                     ),
// //                     const SizedBox(width: 4),
// //                     GestureDetector(
// //                       onTap: widget.onTap,
// //                       child: const Text(
// //                         'Login now',
// //                         style: TextStyle(
// //                           color: Colors.blue,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 )
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
