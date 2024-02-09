import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/pages/auth/loginPage.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () async{
            await FirebaseAuth.instance.signOut();
            // ignore: use_build_context_synchronously
            Navigator.of(context).push(MaterialPageRoute(builder: ((context) => LoginPage())));
          },
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: const Center(
        child: Text("Welcome USer"),
      ),
    );
  }
}
