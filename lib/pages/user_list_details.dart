import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/common/logout_confirmation.dart';
import 'package:powerstone/common/notification.dart';
import 'package:powerstone/common/view_user_list.dart';
import 'package:powerstone/pages/loginPage.dart';
import 'package:powerstone/pages/create_user.dart';
import 'package:powerstone/services/user_managment/users.dart';

class UserListDetails extends StatefulWidget {
  const UserListDetails({super.key});

  @override
  State<UserListDetails> createState() => _UserListDetailsState();
}

class _UserListDetailsState extends State<UserListDetails> {
  final FirestoreServices firestoreServices = FirestoreServices();
  final TextEditingController searchController = TextEditingController();
  String search = "";
  //for dropdownbutton
  String selectedGender = 'All'; 
  String selectedAgeRange = 'All'; 
  String selectedJob='All';
  String selectedBloodGroup='All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 20),
            addUserSection(context),
            const SizedBox(height: 20),
            //ddb for gender , blodgroup, age, job
            const Placeholder(
              fallbackHeight: 150,
            ),
            const SizedBox(height: 20),
            ViewUserList(
                firestoreServices: firestoreServices,
                search: search,
                searchController: searchController,
            )
          ],
        ),
      ),
    );
  }

  Row addUserSection(BuildContext context) {
    return Row(
      children: [
        Text(
          "Add Users",
          style: Theme.of(context).textTheme.labelLarge,
        ),
        IconButton(
          icon: const Icon(Icons.add_box_rounded),
          iconSize: 32,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const CreateUser()));
          },
        )
      ],
    );
  }

  AppBar customAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 65,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () async {
          // ignore: use_build_context_synchronously
          final logoutConfirmed = await showLogoutConfirmation(context);
          if (logoutConfirmed!) {
            await FirebaseAuth.instance.signOut();
            // ignore: use_build_context_synchronously
            Navigator.of(context).push(MaterialPageRoute(builder: ((context) => const LoginPage())));
          }
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
