import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerstone_admin/common/video_player.dart';
import 'package:powerstone_admin/navigation_menu.dart';
import 'package:powerstone_admin/services/function/workout_service.dart';

class AddWorkout extends StatefulWidget {
  const AddWorkout({Key? key});

  @override
  _AddWorkoutState createState() => _AddWorkoutState();
}

class _AddWorkoutState extends State<AddWorkout> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController muscleController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController intensityController = TextEditingController();
  final TextEditingController instructionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String videoUrl = '';
  bool isVideoSelected = false;
  String label = '';
  String? selectedMuscle;
  String getExtension(XFile file) {
    final path = file.path;
    return path.substring(path.lastIndexOf('.') + 1);
  }

  final List<String> muscleOptions = [
    'chest',
    'lat',
    'delt',
    'bicep',
    'tricep',
    'leg',
    'cardio',
  ];

  Future<void> selectVideo() async {
    //imagepicker enable to open galerry
    final XFile? file =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (file != null) {
      String fileName =
          '${DateTime.now().microsecondsSinceEpoch}.${getExtension(file)}';
      Reference referenceRoot = FirebaseStorage.instance.ref();
      Reference referenceDireVideos = referenceRoot.child('workout');
      Reference referenceVideoToUpload = referenceDireVideos.child(fileName);
      try {
        await referenceVideoToUpload.putFile(File(file.path));
        var tempUrl = await referenceVideoToUpload.getDownloadURL();
        setState(() {
          videoUrl = tempUrl!;
          isVideoSelected = true;
        });
        print("DEBUG: Success uploading video");
      } catch (e) {
        if (videoUrl.isEmpty) {
          isVideoSelected = false;
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error uploading video to DB Storage',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> uploadWorkout() async {
    final WorkoutService _workoutService = WorkoutService();

    if (_formKey.currentState!.validate() && isVideoSelected) {
      String name = nameController.text;
      String sets = setsController.text;
      String reps = repsController.text;
      String intensity = intensityController.text;
      String instruction = instructionController.text;

      // Check if sets and reps are numbers
      if (!_isNumeric(sets) || !_isNumeric(reps)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sets and reps must be numbers',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Upload workout details to Firestore
      await _workoutService.addWorkout(
        name: name,
        muscle: selectedMuscle!,
        sets: sets,
        reps: reps,
        intensity: intensity,
        videoLink: videoUrl,
        instruction: instruction,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Workout uploaded successfully',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form fields after successful upload
      nameController.clear();
      muscleController.clear();
      setsController.clear();
      repsController.clear();
      intensityController.clear();
      instructionController.clear();

      setState(() {
        videoUrl = '';
        isVideoSelected = false;
        selectedMuscle = null;
      });
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const NavigationMenu()));
    } else {
      // Show snackbar if form is not valid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill all fields correctly',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Helper function to check if a string is numeric
  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Workout'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              videoUpload(context),
              const SizedBox(height: 20.0),
              TextInputWidget(
                  label: 'Workout Name', controller: nameController),
              const SizedBox(height: 10.0),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.92,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: _muscleDropdown(context)),
              const SizedBox(height: 10.0),
              TextInputWidget(label: 'Sets', controller: setsController),
              const SizedBox(height: 10.0),
              TextInputWidget(
                label: 'Reps',
                controller: repsController,
              ),
              const SizedBox(height: 10.0),
              TextInputWidget(
                  label: 'Intensity', controller: intensityController),
              const SizedBox(height: 10.0),
              TextInputWidget(
                  label: 'Workout Instruction',
                  controller: instructionController),
              const SizedBox(height: 20.0),
              addVideoBtn(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget videoUpload(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        children: [
          (videoUrl == '' && videoUrl.isEmpty)
              ? const Icon(
                  Icons.video_call,
                  size: 70,
                )
              : SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ChewieVideoPlayer(
                      videoUrl: videoUrl,
                    ),
                  ),
                ),
          IconButton(
            icon: Icon(
              Icons.video_camera_back_rounded,
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () => selectVideo(),
          )
        ],
      );
    });
  }

  GestureDetector addVideoBtn(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await uploadWorkout();
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
            "Add Workout",
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }

  DropdownButtonHideUnderline _muscleDropdown(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        // Specify type parameter <String> for DropdownButton2
        hint: Text("Select Target Muscle",
            style: Theme.of(context).textTheme.labelSmall),
        value: selectedMuscle,
        buttonStyleData: ButtonStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 0.2),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          elevation: 0,
        ),
        onChanged: (String? value) {
          // Change type of value to String
          setState(() {
            selectedMuscle = value;
          });
        },
        items: muscleOptions
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ))
            .toList(),
        dropdownStyleData: DropdownStyleData(
          maxHeight: MediaQuery.of(context).size.height * .8,
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

class TextInputWidget extends StatelessWidget {
  const TextInputWidget({
    super.key,
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        label: Text(label),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a workout details';
        }
        return null;
      },
    );
  }
}
