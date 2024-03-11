import 'package:dropdown_button2/dropdown_button2.dart';
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
  String gender = "";
  String job = "";
  String blood = "";
  //for dropdownbutton
  String? selectgender;
  List<String> genders = ["male", "female", "other", "none"];

  String? selectjob;
  List<String> jobs = [
    "software engineer",
    "web developer",
    "data scientist",
    "ux/ui designer",
    "network engineer",
    "cloud architect",
    "none"
  ];

  String? selectedBloodGroup;
  List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    "none"
  ];

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
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: bloodgroupDDB(context),
                    ),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: jobDropdown(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: genderDrowdown(context),
                    ),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.45,
                      child: GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white, width: 0.3),
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'FILTER',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                        color: Theme.of(context).primaryColor),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Icon(
                                Icons.filter_alt,
                                size: 20,
                              )
                            ],
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            gender = selectgender ?? '';
                            job = selectjob ?? '';
                            blood = selectedBloodGroup ?? '';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ViewUserList(
              firestoreServices: firestoreServices,
              search: search,
              searchController: searchController,
              gender: gender,
              job: job,
              bloodGroup: blood,
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
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateUser()));
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
            Navigator.of(context).push(
                MaterialPageRoute(builder: ((context) => const LoginPage())));
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

  DropdownButtonHideUnderline genderDrowdown(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: false,
        hint: Text(
          "Gender",
          style: Theme.of(context).textTheme.labelSmall,
        ),
        value: selectgender,
        buttonStyleData: ButtonStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 0.3),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          elevation: 0,
        ),
        onChanged: (String? value) {
          setState(() {
            selectgender = value;
          });
        },
        items: genders
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ))
            .toList(),
      ),
    );
  }

  DropdownButtonHideUnderline jobDropdown(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        isExpanded: true,
        hint: Text(
          "Job",
          style: Theme.of(context).textTheme.labelSmall,
          overflow: TextOverflow.clip,
        ),
        value: selectjob,
        buttonStyleData: ButtonStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 0.3),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          elevation: 0,
        ),
        onChanged: (String? value) {
          setState(() {
            selectjob = value;
          });
        },
        items: jobs
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.clip,
                  ),
                ))
            .toList(),
        dropdownStyleData: DropdownStyleData(
          maxHeight: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          offset: const Offset(-10, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(3),
            thumbVisibility: MaterialStateProperty.all(true),
          ),
        ),
      ),
    );
  }

  DropdownButtonHideUnderline bloodgroupDDB(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        hint:
            Text("Blood Group", style: Theme.of(context).textTheme.labelSmall),
        value: selectedBloodGroup,
        buttonStyleData: ButtonStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 0.2),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          elevation: 0,
        ),
        onChanged: (String? value) {
          setState(() {
            selectedBloodGroup = value;
          });
        },
        items: bloodGroups
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ))
            .toList(),
        dropdownStyleData: DropdownStyleData(
          maxHeight: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          offset: const Offset(-20, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(3),
            thumbVisibility: MaterialStateProperty.all(true),
          ),
        ),
      ),
    );
  }
}
