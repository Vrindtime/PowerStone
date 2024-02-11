// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerstone/pages/HomePage_toNav.dart';
import 'package:powerstone/services/firestore.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  String imageUrl = "nil";
  String? temputl;

  final TextEditingController fnameController = TextEditingController();

  final TextEditingController lnameController = TextEditingController();

  final TextEditingController dobController = TextEditingController();

  final TextEditingController genderController = TextEditingController();

  final TextEditingController jobController = TextEditingController();

  final TextEditingController bloodController = TextEditingController();

  final TextEditingController heightController = TextEditingController();

  final TextEditingController weightController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController noteController = TextEditingController();

  final FirestoreServices firestoreServices = FirestoreServices();

  String getExtension(XFile file) {
    final path = file.path;
    return path.substring(path.lastIndexOf('.') + 1);
  }

  void selectImage() async {
    final source = await showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {}, // Prevent closing on outside tap
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera),
              title: Text('Camera'),
              onTap: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_album),
              title: Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
            )
          ],
        ),
      ),
    );

    if (source != null) {
      final file = await ImagePicker().pickImage(source: source);
      if (file == null) return;
      String fileName =
          '${DateTime.now().microsecondsSinceEpoch}.${getExtension(file)}';
      //ref to storage root
      Reference referenceRoot = FirebaseStorage.instance.ref();
      //imgFolder
      Reference referenceDireImages = referenceRoot.child('userPfp');

      //reference to uplaod img
      Reference referenceImageToUpload = referenceDireImages.child(fileName);
      try {
        await referenceImageToUpload.putFile(File(file.path));
        temputl = await referenceImageToUpload.getDownloadURL();
        setState(() {
          imageUrl = temputl!;
        });
      } catch (e) {
        if (imageUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                  child: Text(
                'Error in uploading Image to DB Storage',
                style: Theme.of(context).textTheme.labelMedium,
              )),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Theme.of(context).primaryColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Image Upload

                PfpImageUpload(context),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InputText(
                      controller: fnameController,
                      label: "First name",
                    ),
                    InputText(
                      controller: lnameController,
                      label: "Last name",
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 175,
                      child: genderDrowdown(context),
                    ),
                    SizedBox(
                      height: 50,
                      width: 175,
                      child: selectDOB(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 175,
                      child: bloodgroupDropDown(context),
                    ),
                    SizedBox(
                      height: 50,
                      width: 175,
                      child: jobDropdown(context),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InputText(
                      controller: heightController,
                      label: "Height",
                    ),
                    InputText(
                      controller: weightController,
                      label: "Weight",
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                //height
                LongInput(controller: phoneController, label: "Phone"),
                SizedBox(
                  height: 20,
                ),
                //weight
                LongInput(controller: passwordController, label: "Password"),
                SizedBox(
                  height: 20,
                ),
                //note
                NoteInput(controller: noteController, label: "Note"),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: createUserbtn(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector createUserbtn(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        const Duration(seconds: 1);
        final String firstName = fnameController.text;
        final String lastName = lnameController.text;
        final String dateOfBirth = dobController.text;
        final String gender = genderController.text;
        final String job = jobController.text;
        final String bloodGroup = bloodController.text;
        final String height = heightController.text;
        final String weight = weightController.text;
        final String email = phoneController.text;
        final String password = passwordController.text;
        final String note = noteController.text;

        await firestoreServices.addUser(
          firstName,
          lastName,
          dateOfBirth,
          gender,
          job,
          bloodGroup,
          height,
          weight,
          email,
          password,
          note,
          imageUrl,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text(
              'Success',
              style: Theme.of(context).textTheme.labelMedium,
            )),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => AdminHomePage()));
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
            "Create User",
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }

  DropdownMenu<Text> jobDropdown(BuildContext context) {
    return DropdownMenu(
      controller: jobController,
      label: Text(
        "Profession",
        style: Theme.of(context).textTheme.labelSmall,
      ),
      width: 175,
      enableFilter: true,
      textStyle: Theme.of(context).textTheme.labelSmall,
      dropdownMenuEntries: [
        DropdownMenuEntry(
            value: Text("Software Engineer"), label: "Software Engineer"),
        DropdownMenuEntry(value: Text("Web Developer"), label: "Web Developer"),
        DropdownMenuEntry(
            value: Text("Data Scientist"), label: "Data Scientist"),
        DropdownMenuEntry(
            value: Text("UX/UI Designer"), label: "UX/UI Designer"),
        DropdownMenuEntry(
            value: Text("Network Engineer"), label: "Network Engineer"),
        DropdownMenuEntry(
            value: Text("Cybersecurity Analyst"),
            label: "Cybersecurity Analyst"),
        DropdownMenuEntry(
            value: Text("Cloud Architect"), label: "Cloud Architect"),
        DropdownMenuEntry(
            value: Text("Database Administrator"),
            label: "Database Administrator"),
      ],
    );
  }

  DropdownMenu<Text> bloodgroupDropDown(BuildContext context) {
    return DropdownMenu(
      textStyle: TextStyle(fontSize: 16.0),
      controller: bloodController,
      label: Text(
        "Blood Group",
        style: Theme.of(context).textTheme.labelSmall,
      ),
      width: 175,
      enableFilter: true,
      dropdownMenuEntries: [
        DropdownMenuEntry(value: Text("A+"), label: "A+"),
        DropdownMenuEntry(value: Text("A-"), label: "A-"),
        DropdownMenuEntry(value: Text("B+"), label: "B+"),
        DropdownMenuEntry(value: Text("B-"), label: "B-"),
        DropdownMenuEntry(value: Text("AB+"), label: "AB+"),
        DropdownMenuEntry(value: Text("AB-"), label: "AB-"),
        DropdownMenuEntry(value: Text("O+"), label: "O+"),
        DropdownMenuEntry(value: Text("O-"), label: "O-"),
      ],
    );
  }

  TextField selectDOB(BuildContext context) {
    return TextField(
      onTap: () {
        _selectDate(context);
      },
      keyboardType: TextInputType.datetime,
      controller: dobController,
      style: Theme.of(context).textTheme.labelMedium,
      decoration: InputDecoration(
        label: const Text("D.O.B"),
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
      ),
    );
  }

  DropdownMenu<Text> genderDrowdown(BuildContext context) {
    return DropdownMenu(
      controller: genderController,
      label: Text(
        "Gender",
        style: Theme.of(context).textTheme.labelSmall,
      ),
      width: 175,
      enableFilter: true,
      textStyle: Theme.of(context).textTheme.labelSmall,
      dropdownMenuEntries: [
        DropdownMenuEntry(
            value: Text(
              "male",
              style: Theme.of(context).textTheme.labelSmall,
            ),
            label: "Male"),
        DropdownMenuEntry(
            value: Text(
              "female",
              style: TextStyle(fontSize: 12),
            ),
            label: "Female"),
        DropdownMenuEntry(value: Text("other"), label: "Other"),
      ],
    );
  }

  Widget PfpImageUpload(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Stack(
        children: [
          CircleAvatar(
              maxRadius: 40,
              child: (imageUrl == "nil")
                  ? Icon(
                      Icons.person,
                      size: 50,
                    )
                  : ClipOval(
                      child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      height: 50,
                      width: 50,
                    ))),
          Positioned(
            bottom: -10,
            left: 40,
            child: IconButton(
              icon: Icon(
                Icons.add_a_photo_rounded,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => selectImage(),
            ),
          )
        ],
      );
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        dobController.text = picked.toString().split(" ")[0];
      });
    }
  }
}

class InputText extends StatelessWidget {
  const InputText({
    super.key,
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 175,
      child: TextField(
        keyboardType: (label == 'Height' || label == 'Weight')
            ? TextInputType.number
            : TextInputType.name,
        controller: controller,
        style: Theme.of(context).textTheme.labelMedium,
        decoration: InputDecoration(
          label: Text(label),
          labelStyle: Theme.of(context).textTheme.labelSmall,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: const BorderSide(color: Colors.white, width: 0.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
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

class LongInput extends StatelessWidget {
  const LongInput({
    super.key,
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextField(
        keyboardType:
            (label == "Phone") ? TextInputType.phone : TextInputType.name,
        controller: controller,
        style: Theme.of(context).textTheme.labelMedium,
        decoration: InputDecoration(
          label: Text(label),
          labelStyle: Theme.of(context).textTheme.labelSmall,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: const BorderSide(color: Colors.white, width: 0.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
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

class NoteInput extends StatelessWidget {
  const NoteInput({
    super.key,
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: TextField(
        maxLines: 5,
        keyboardType: TextInputType.name,
        controller: controller,
        style: Theme.of(context).textTheme.labelMedium,
        decoration: InputDecoration(
          label: Text(label),
          labelStyle: Theme.of(context).textTheme.labelSmall,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: const BorderSide(color: Colors.white, width: 0.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
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
