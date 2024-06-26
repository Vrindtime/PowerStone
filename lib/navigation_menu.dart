import 'package:flutter/material.dart';
import 'package:powerstone_admin/common/logout_confirmation.dart';
import 'package:powerstone_admin/pages/Starter/home_page.dart';
import 'package:powerstone_admin/pages/chat/chat_page.dart';
import 'package:powerstone_admin/pages/payment_page.dart';
import 'package:powerstone_admin/pages/user/user_list_details.dart';
import 'package:powerstone_admin/services/notifications/push_notifications.dart';

class NavigationMenu extends StatefulWidget {
  const NavigationMenu({super.key});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  //creating an object for PushNoti
  FCMNotificationServices fcmNotificationServices = FCMNotificationServices();
  @override
  void initState() {
    super.initState();
    fcmNotificationServices.requestNotificationPermission();
    fcmNotificationServices.getDeviceToken();
    // fcmNotificationServices.isTokenRefresh();
    fcmNotificationServices.firebaseInit(context);
    fcmNotificationServices.setupInteractMessage(context);
  }

  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didpop) {
        showLogoutConfirmation(context);
      },
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          height: 65,
          elevation: 0,
          onDestinationSelected: (value) {
            setState(() {
              currentPage = value;
            });
          },
          selectedIndex: currentPage,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: Theme.of(context).primaryColor,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.people), label: 'User'),
            NavigationDestination(
                icon: Icon(Icons.payment_rounded), label: 'Payment'),
            NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          ],
        ),
        body: [
          const HomePage(),
          const UserListDetails(),
          const PaymentPage(),
          const ChatPage(),
        ][currentPage],
      ),
    );
  }
}
