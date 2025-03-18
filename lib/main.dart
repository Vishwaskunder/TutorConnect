import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:tutorconnect_app/pages/landing_page.dart';
import 'package:tutorconnect_app/pages/login_page.dart';
import 'package:tutorconnect_app/pages/register_page.dart';
import 'package:tutorconnect_app/pages/home_page.dart';
import 'package:provider/provider.dart'; // Import the provider package
import 'package:tutorconnect_app/themes/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding for async calls
  await Firebase.initializeApp(); // Initialize Firebase here
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context); // Access ThemeProvider
          return MaterialApp(
            title: 'TutorConnect',
            theme: themeProvider.themeData, // Dynamically use theme from ThemeProvider
            initialRoute: '/landing', // Set LandingPage as the initial route
            routes: {
              '/login': (context) => LoginPage(onTap: () {
                    Navigator.pushNamed(context, '/register');
                  }),
              '/register': (context) => RegisterPage(onTap: () {
                    Navigator.pushNamed(context, '/login');
                  }),
              '/landing': (context) => const LandingPage(),
              '/home': (context) => const HomePage(),

              
            },
          );
        },
      ),
    );
  }
}

