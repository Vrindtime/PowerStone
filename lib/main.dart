import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:powerstone/pages/HomePage_toNav.dart';
import 'package:powerstone/pages/welcome_page.dart';
import 'package:powerstone/services/theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: apptheme,
      home: user!=null ? const AdminHomePage() : const StartPage(),
    );
  }
}
