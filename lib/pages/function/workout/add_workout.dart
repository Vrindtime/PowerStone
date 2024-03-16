import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerstone/common/video_player.dart';
import 'package:powerstone/navigation_menu.dart';
import 'package:powerstone/services/function/workout_service.dart';

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
  String getExtension(XFile file) {
    final path = file.path;
    return path.substring(path.lastIndexOf('.') + 1);
  }

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error uploading video to DB Storage',
                style: Theme.of(context).textTheme.bodyText1,
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
      String muscle = muscleController.text;
      String sets = setsController.text;
      String reps = repsController.text;
      String intensity = intensityController.text;
      String instruction = instructionController.text;

      // Upload workout details to Firestore
      await _workoutService.addWorkout(
        name: name,
        muscle: muscle,
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
            style: Theme.of(context).textTheme.bodyText1,
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
      });
    }
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
              TextInputWidget(
                  label: 'Target Muscle', controller: muscleController),
              const SizedBox(height: 10.0),
              TextInputWidget(label: 'Sets', controller: setsController),
              const SizedBox(height: 10.0),
              TextInputWidget(label: 'Reps', controller: repsController),
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
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NavigationMenu()));
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
