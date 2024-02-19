import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/common/monthly_fl_chart.dart';
import 'package:powerstone/common/notification.dart';
import 'package:powerstone/pages/loginPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
              child: Text("Monthly Revenue",style: Theme.of(context).textTheme.labelMedium,),
            ),
            const MonthlyFlowChart(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Functions",style: Theme.of(context).textTheme.labelMedium,),
            ),
            //create the grid
          ],
        ),
      ),
    );
  }
  AppBar customAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 65,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text("P O W E R S T O N E",style: Theme.of(context).textTheme.labelMedium!.copyWith(fontSize: 21),),
      leading: IconButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(MaterialPageRoute(builder: ((context) => const LoginPage())));
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
              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => const NotificationWidget())));
            },
          ),
        )
      ],
    );
  }
}
