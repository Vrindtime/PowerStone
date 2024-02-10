import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:powerstone/pages/onlineuser.dart';
import 'package:powerstone/pages/started.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  // FirebaseAuth.instance.setPersistence(Persistence.SESSION);
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});
  final User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        primaryColor: const Color.fromRGBO(39, 221, 127, 1),
        splashColor: const Color.fromRGBO(217, 217, 217, .25),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(39, 221, 127, 1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color.fromRGBO(42, 45, 44, 1),
        textTheme: TextTheme(
          labelLarge: GoogleFonts.inter(fontSize: 26,fontWeight: FontWeight.bold,color: Colors.white,), //use .copyWith(attribute) to 
          labelMedium: GoogleFonts.inter(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.white,), //change the properties, 
          labelSmall: GoogleFonts.inter(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.white,), // later on specific elements
        ),
      ),
      home: user!=null ? const AdminHomePage() : const StartPage(),
    );
  }
}
