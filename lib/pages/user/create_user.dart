// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerstone_admin/navigation_menu.dart';
import 'package:powerstone_admin/services/user_managment/users.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CreateUser extends StatefulWidget {
  const CreateUser({super.key});

  @override
  State<CreateUser> createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  String imageUrl = '';
  String? temputl;
  bool isImageSelected = false;

  final TextEditingController fnameController = TextEditingController();

  final TextEditingController lnameController = TextEditingController();

  final TextEditingController dobController = TextEditingController();

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
      if (file != null) {
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
          print("DUBUG: Success uplaodin pfp");
        } catch (e) {
          // print('Stack trace: $stackTrace'); to use this catch (e, stackTrace){}
          if (imageUrl.isEmpty) {
            isImageSelected = false;
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
  }

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

  String? selectjob;
  List<String> jobs = [
    "Healthcare Professional",
    "IT",
    "Engineer",
    "Teacher/Educator",
    "Sales Representative",
    "Administrative Assistant",
    "Customer Service Representative",
    "Accountant/Financial Analyst",
    "Marketing Specialist",
    "Construction Worker",
    "Human Resources Manager",
    "Retail Sales Associate",
    "Graphic Designer",
    "Operations Manager",
    "Project Manager",
    "Legal Assistant/Paralegal",
    "Social Worker",
    "Research Analyst",
    "Chef/Cook",
    "Transportation Worker",
    "Writer/Editor",
    "House Wife",
    "None"
  ];

  String? selectgender;
  List<String> genders = ["male", "female", "other", "none"];

  // Validation function for password
  bool _isPasswordValid(String value) {
    return value.length >= 5 &&
        RegExp(r'^(?=.*[0-9].*[0-9])(?=.*[a-zA-Z].{3,})[a-zA-Z0-9]+$')
            .hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //Image Upload
                pfpImageUpload(context),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InputText(
                      controller: fnameController,
                      label: "First Name",
                    ),
                    InputText(
                      controller: lnameController,
                      label: "Last Name",
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                      child: selectDOB(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
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
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                //login btn
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

  //login btn
  GestureDetector createUserbtn(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Check if all form fields are filled
      if (fnameController.text.isEmpty ||
          lnameController.text.isEmpty ||
          dobController.text.isEmpty ||
          selectgender == null ||
          selectjob == null ||
          selectedBloodGroup == null ||
          heightController.text.isEmpty ||
          weightController.text.isEmpty ||
          phoneController.text.isEmpty ||
          passwordController.text.isEmpty ||
          noteController.text.isEmpty ||
          imageUrl.isEmpty) {
        // If any field is empty, show an error message or handle it accordingly
        // For example, you can display a SnackBar to inform the user to fill out all fields
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please fill out all fields',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return; // Exit the function without proceeding further
      }
      
        const Duration(seconds: 1);
        final String firstName = fnameController.text;
        final String lastName = lnameController.text;
        final String dateOfBirth = dobController.text;
        final String gender = selectgender ?? 'nil';
        final String job = selectjob ?? 'nil';
        final String bloodGroup = selectedBloodGroup ?? 'nil';
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
            .push(MaterialPageRoute(builder: (context) => NavigationMenu()));
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

  Widget pfpImageUpload(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Stack(
        children: [
          CircleAvatar(
            maxRadius: 40,
            child: (imageUrl == '' && imageUrl.isEmpty)
                ? Icon(
                    Icons.person,
                    size: 70,
                  )
                : ClipOval(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      height: 70,
                      width: 70,
                    ),
                  ),
          ),
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
      width: MediaQuery.of(context).size.width * 0.45,
      child: TextFormField(
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your phone number';
          }
        },
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
      child: TextFormField(
        obscureText: (label == "Phone") ? false : true,
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
        validator: (value) {
          if (label != "Phone") {
            if (value!.length >= 5 &&
                RegExp(r'^(?=.*[0-9].*[0-9])(?=.*[a-zA-Z].{3,})[a-zA-Z0-9]+$')
                    .hasMatch(value)) {
              return 'Password must be at least 5 characters long and contain at least 2 numbers';
            }
          }
          return null;
        },
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
      child: TextFormField(
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a password';
          }
        },
      ),
    );
  }
}
