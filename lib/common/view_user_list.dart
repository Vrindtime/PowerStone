import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/common/DotMenu.dart';
import 'package:powerstone/services/firestore.dart';

class ViewUserList extends StatelessWidget {
  const ViewUserList({
    super.key,
    required this.firestoreServices,
    required this.search,
    required this.searchController,
  });

  final FirestoreServices firestoreServices;
  final String search;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
          stream: firestoreServices.getUserDetails(search),
          builder: (context, snapshot) {
            //if we have data, get all the docs
            if (snapshot.hasData) {
              List userList = snapshot.data!.docs;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total User : ${userList.length}",
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        //get each individual doc
                        DocumentSnapshot document = userList[index];
                        String docID =
                            document.id; //keep track of users
                        // print("Doc ID: " + docID);
    
                        //get userdata from each doc
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String userName =
                            data['firstName'] ?? "No Name Recieved";
    
                        // display as a list tile
                        return Container(
                          margin:
                              const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).splashColor,
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(6),
                            leading: CircleAvatar(
                              child: Text(docID),
                            ),
                            title: Text(
                              userName,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium,
                            ),
                            trailing: const DotMenu(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: Text(
                  "No User data Exists",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              );
            }
          }),
    );
  }
}