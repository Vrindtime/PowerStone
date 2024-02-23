import 'package:flutter/material.dart';

class CommingSoon extends StatelessWidget {
  const CommingSoon({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comming Soon Page"),),
      body: const Center(child: Text("C O M M I N G \n S O O N",textAlign: TextAlign.center,style: TextStyle(fontSize: 50),),),
    );
  }
}