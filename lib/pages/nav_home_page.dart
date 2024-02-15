import 'package:flutter/material.dart';
import 'package:powerstone/navigation_menu.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: NavigationMenu(),
    );
  }
}
