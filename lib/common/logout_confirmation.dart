import 'package:flutter/material.dart';

Future<bool?> showLogoutConfirmation(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Prevent user from dismissing without choosing an option
    builder: (context) => AlertDialog(
      title: const Text('Log Out'),
      content: Text('Are you sure you want to log out?', textAlign: TextAlign.center,style: Theme.of(context).textTheme.labelMedium,),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false), // Indicate user chose "Cancel"
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
          child: const Text('Cancel',style: TextStyle(fontSize: 18),),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true), // Indicate user chose "Log Out"
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          ),
          child: const Text('Log Out',style: TextStyle(fontSize: 18,color: Colors.red),),
        ),
      ],
    ),
  );
}
