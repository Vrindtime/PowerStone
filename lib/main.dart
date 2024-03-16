import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:powerstone/common/notification.dart';
import 'package:powerstone/pages/Starter/home_page.dart';
import 'package:powerstone/pages/chat/chat_page.dart';
import 'package:powerstone/pages/payment_page.dart';
import 'package:powerstone/pages/user/user_list_details.dart';
import 'package:powerstone/services/auth/auth_gate.dart';
import 'package:powerstone/services/theme.dart';
import 'services/firebase_options.dart';

//function to listen to background changes
@pragma('vm:entry-point')
Future _firebaseNotificationBackgroudMessage(RemoteMessage message)async{
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
  //listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseNotificationBackgroudMessage);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
     
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: apptheme,
      routes: {
        '/': (context) => const AuthGate(),
        '/home': (context) => const HomePage(),
        '/user': (context) => const UserListDetails(),
        '/payment': (context) => const PaymentPage(),
        '/chat': (context) => const ChatPage(),
        '/notification': (context) => const NotificationPage(),
      },
    );
  }
}
