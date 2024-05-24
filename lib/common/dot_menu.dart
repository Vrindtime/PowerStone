import 'package:flutter/material.dart';
import 'package:popover/popover.dart';
import 'package:powerstone_admin/pages/user/edit_profile.dart';
import 'package:powerstone_admin/services/user_managment/users.dart';

class DotMenu extends StatelessWidget {
  final String docID;
  const DotMenu({super.key, required this.docID});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPopover(
        height: 50.0,
        context: context,
        bodyBuilder: (context) => MenuItems(docID: docID),
        direction: PopoverDirection.left,
        arrowWidth: 10,
        backgroundColor: Theme.of(context).primaryColor
      ),
      child: Icon(
        Icons.more_vert,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class MenuItems extends StatelessWidget {
  final String docID;
  MenuItems({super.key, required this.docID});
  final FirestoreServices firestoreServices = FirestoreServices();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile(docID: docID)));
            
          },
          child: SizedBox(
            height: 30,
            width: 100,
            child: Center(
                child: Text('Edit Profile',
                    style: Theme.of(context).textTheme.labelMedium)),
          ),
        ),
        InkWell(
          onTap: () {
            firestoreServices.deleteUser(docID);
            Navigator.pop(context);
          },
          child: SizedBox(
            height: 30,
            width: 100,
            child: Center(
                child: Text('Delete',
                    style: Theme.of(context).textTheme.labelMedium)),
          ),
        ),
      ],
    );
  }
}
