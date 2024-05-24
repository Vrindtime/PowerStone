import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:powerstone_admin/common/search.dart';
import 'package:powerstone_admin/pages/function/workout/add_workout.dart';
import 'package:powerstone_admin/pages/function/workout/info_workout.dart';
import 'package:powerstone_admin/services/function/workout_service.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final WorkoutService _workoutService = WorkoutService();

  String search = '';
  void updateSearch(String newSearch) {
    setState(() {
      search = newSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SearchTextField(
                    onSearchUpdate: updateSearch,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                //Add workout
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 20,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddWorkout()));
                    },
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Workout List',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: _workoutService.getWorkout(search),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("Error");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Expanded(child: _equipmentList(snapshot));
              },
            ),
          ],
        ),
      ),
    );
  }

  //custom components Here after
  AppBar customAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 65,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.clear_outlined,
          size: 32,
        ),
        color: Theme.of(context).primaryColor,
      ),
      title: const Text('WORKOUT LIBRARY'),
      centerTitle: true,
    );
  }

  ListView _equipmentList(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox.shrink(),
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        DocumentSnapshot doc = snapshot.data!.docs[index];
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String name = data["WorkoutName"];
        String muscle = data["WorkoutMuscle"];
        String rep = data["WorkoutRep"];
        String set = data["WorkoutSet"];
        String intensity = data["WorkoutIntensity"];
        String docID = doc.id;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Text Information Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(name,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 20)),
                          const SizedBox(height: 8),
                          Text(
                            'Muscle: $muscle',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Set: $set * Rep: $rep \nIntensity: $intensity',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 4),
                          IconButton(
                            icon: const Icon(Icons.info),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WorkoutInfo(docid: docID,)));
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
