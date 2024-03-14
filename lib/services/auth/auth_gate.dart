import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/navigation_menu.dart';
import 'package:powerstone/pages/welcome_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          //if user has aready logged in
         return const NavigationMenu();
        }else{
          //if the user has not logged in
          return const StartPage();
        }
      },
    );
  }
}
