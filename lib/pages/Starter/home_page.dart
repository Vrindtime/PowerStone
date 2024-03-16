import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/common/logout_confirmation.dart';
import 'package:powerstone/common/monthly_fl_chart.dart';
import 'package:powerstone/pages/Starter/loginPage.dart';
import 'package:powerstone/pages/comming_soon.dart';
import 'package:powerstone/pages/function/equipments/equpiment.dart';
import 'package:powerstone/pages/function/workout/workout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<IconData> customIcons = [
    Icons.store,
    Icons.sports_martial_arts,
    Icons.person_pin_sharp,
    Icons.storage_sharp,
    // Add more icons as needed
  ];
  List<String> customText = [
    'Equipment\nManagment',
    'Workout Library\nManagment',
    'View User\nAttendance ',
    'Resource\nManagment'
  ];

  List<Widget> location = [
    EquipmentPage(),
    WorkoutPage(),
    const CommingSoon(),
    const CommingSoon()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Monthly Revenue",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontSize: 20),
              ),
            ),
            const MonthlyFlowChart(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Functions",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(fontSize: 20),
              ),
            ),
            //create the grid
            homeFunctions(),
          ],
        ),
      ),
    );
  }

  Widget homeFunctions() {
    return Expanded(
      child: GridView.builder(
        key: UniqueKey(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
        ),
        itemCount: customText.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).splashColor.withOpacity(.1),
                border: Border.all(width: 1, color: Colors.white),
                borderRadius: BorderRadius.circular(22),
              ),
              child: GestureDetector(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        customIcons[index],
                        size: 46,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text(
                        customText[index],
                        style: Theme.of(context).textTheme.labelMedium,
                        textAlign: TextAlign.center,
                      )
                    ]),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => location[index]));
                },
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar customAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 65,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "P O W E R S T O N E",
        style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 21),
      ),
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
          child: IconButton(
            icon: const Icon(Icons.notifications),
            color: Theme.of(context).primaryColor,
            iconSize: 36,
            onPressed: () {
              Navigator.pushNamed(context, '/notification');
            },
          ),
        )
      ],
    );
  }
}
