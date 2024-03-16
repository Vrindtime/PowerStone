class WorkoutModel {
  
  final String name;
  final String muscle;
  final String set;
  final String rep;
  final String intensity;
  final String videolink;
  final String instruction;

  WorkoutModel({
    required this.name,
    required this.muscle,
    required this.set,
    required this.rep,
    required this.intensity,
    required this.videolink,
    required this.instruction,
  });

  //covert to a map
  Map<String,dynamic> toMap(){
    return {
      'WorkoutName':name,
      'WorkoutMuscle':muscle,
      'WorkoutSet':set,
      'WorkoutRep':rep,
      'WorkoutIntensity':intensity,
      'WorkoutVideoLink':videolink,
      'WorkoutInstruction':instruction,
    };
  }
}
