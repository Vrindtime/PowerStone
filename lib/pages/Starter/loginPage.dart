// ignore: file_names
// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:powerstone/common/logo.dart';
import 'package:powerstone/navigation_menu.dart';
import 'package:powerstone/pages/Starter/welcome_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController passController = TextEditingController();
  //global
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
            body: Center(
                child: Lottie.asset(
            'assets/lottie/security_walking.json',
            fit: BoxFit.contain,
          )))
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const StartPage()));
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                ),
                color: Theme.of(context).primaryColor,
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: GymLogo()),
                      Text("Login",
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 10, width: double.infinity),
                      Text("Please sign in to continue",
                          style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 30, width: double.infinity),
                      EmailInput(emailController: emailController),
                      const SizedBox(height: 20, width: double.infinity),
                      PasswordInput(passController: passController),
                      const SizedBox(height: 30, width: double.infinity),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              isLoading = true;
                            });
                            const Duration(seconds: 1);
                            final String email = emailController.text;
                            final String password = passController.text;
                            await signInLogic(email, password, context);
                          },
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                "Login",
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20, width: double.infinity),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Future<void> signInLogic(
      String email, String password, BuildContext context) async {
        debugPrint('DEBUG: email: $email , password: $password');
    // Email validation regex pattern
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    // Password validation regex pattern
    final passwordPattern = RegExp(
      r'^(?=.*\d).{6,}$',
    );

    // Check if email is valid
    if (!emailPattern.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Invalid email format',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
      return; // Exit the function if email is invalid
    }

    // Check if password meets the criteria
    if (password.length < 5 || !passwordPattern.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password must be at least 5 characters long and contain at least 2 numbers',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
      return; // Exit the function if password is invalid
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('DEBUG: credential : $credential');
      // ignore: unnecessary_null_comparison
      if (credential != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
        );
        setState(() {
          isLoading = false;
        });
      } else {
        // Handle if credential is null
        setState(() {
          isLoading = false;
        });
      }
    } on Exception {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'An Error Occurred',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class EmailInput extends StatelessWidget {
  const EmailInput({
    super.key,
    required this.emailController,
  });

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextField(
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
        style: Theme.of(context).textTheme.labelMedium,
        decoration: InputDecoration(
          label: const Text("Email Address"),
          labelStyle: Theme.of(context).textTheme.labelSmall,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.0),
              borderSide: const BorderSide(color: Colors.white, width: 0.5)),
          prefixIcon: const Icon(
            Icons.email,
            color: Colors.white,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color:
                  Theme.of(context).primaryColor, // Border color when focused
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    super.key,
    required this.passController,
  });

  final TextEditingController passController; //local

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextField(
        obscureText: true,
        controller: passController,
        style: Theme.of(context).textTheme.labelMedium,
        decoration: InputDecoration(
          label: const Text("Password"),
          labelStyle: Theme.of(context).textTheme.labelSmall,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18.0),
              borderSide: const BorderSide(color: Colors.white, width: 0.5)),
          prefixIcon: const Icon(
            Icons.lock,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
