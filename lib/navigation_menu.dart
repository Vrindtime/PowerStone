import 'package:flutter/material.dart';
import 'package:powerstone/pages/chat_page.dart';
import 'package:powerstone/pages/userdetails.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 65,
        elevation: 0,
        onDestinationSelected: (value){
          setState(() {
            currentPage = value;
          });
        },
        selectedIndex: currentPage,
        labelBehavior:  NavigationDestinationLabelBehavior.alwaysShow,
        indicatorColor: Theme.of(context).primaryColor,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people), label: 'User'),
          NavigationDestination(icon: Icon(Icons.payment_rounded), label: 'Payment'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
      body: [
        const UserDetails(),
        const UserDetails(),
        const UserDetails(),
        const ChatPage(),
      ][currentPage],
    );
  }
}