import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorconnect_app/pages/landing_page.dart';
import 'package:tutorconnect_app/pages/login_or_register.dart';

class AuthPage  extends StatelessWidget{
  const AuthPage({super.key});
  
  @override
  Widget build(BuildContext context) {
   return Scaffold(
    body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context,snapshot){

          // user is logged in 
          if(snapshot.hasData){
            return LandingPage();

          }
          // user is NOT logged in
          else{
            return LoginOrRegisterPage();

          }
      }
    ),
   );
  }
}

