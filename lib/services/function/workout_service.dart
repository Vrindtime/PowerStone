import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:powerstone/models/workout_model.dart';

class WorkoutService{
  final CollectionReference _workoutCollection = FirebaseFirestore.instance.collection("workout");
  Future<void> addWorkout({
    required String name,
    required String muscle,
    required String sets,
    required String reps,
    required String intensity,
    required String videoLink,
    required String instruction,
  }) async {
    
    WorkoutModel newWorkout = WorkoutModel(
      name: name,
      muscle: muscle,
      set: sets,
      rep: reps,
      intensity: intensity,
      videolink: videoLink,
      instruction: instruction,
    );

    await _workoutCollection.add(newWorkout.toMap());
  }

  Stream<QuerySnapshot> getWorkout(String value){
    Query workoutstream = _workoutCollection;
    //function to filter search
    if (value.isNotEmpty) {
      String searchValue =
          value.toLowerCase(); // Convert search value to lowercase
      String endValue = searchValue.substring(0, searchValue.length - 1) +
          String.fromCharCode(
              searchValue.codeUnitAt(searchValue.length - 1) + 1);
      workoutstream = _workoutCollection.where(
        'WorkoutName',
        isGreaterThanOrEqualTo: searchValue,
        isLessThan: endValue,
      );
    }
    return workoutstream.snapshots();
  }
}