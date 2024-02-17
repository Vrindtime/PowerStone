import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/common/notification.dart';
import 'package:powerstone/pages/loginPage.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  TextEditingController searchController = TextEditingController();

  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text("Monthly Income: XXXX",style: Theme.of(context).textTheme.labelLarge,),
          )
        ],
      ),
    );
  }

  //appbar
   AppBar customAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 65,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(
              MaterialPageRoute(builder: ((context) => const LoginPage())));
        },
        icon: const Icon(
          Icons.logout_rounded,
          size: 32,
        ),
        color: Theme.of(context).primaryColor,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: 250,
            child: searchTextField(context),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.notifications),
            color: Theme.of(context).primaryColor,
            iconSize: 36,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => const NotificationWidget())));
            },
          ),
        )
      ],
    );
  }

  TextField searchTextField(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        label: const Text("Search"),
        labelStyle: Theme.of(context).textTheme.labelSmall,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(color: Colors.white, width: 0.5)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor, // Border color when focused
            width: 0.5,
          ),
        ),
        suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                search = searchController.text;
              });
            },
            icon: Icon(
              Icons.search,
              color: Theme.of(context).primaryColor,
            )),
      ),
    );
  }
}