import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/common/DotMenu.dart';
import 'package:powerstone/services/user_managment/firestore.dart';

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
                        // String docID = document.id; //keep track of users

                        //get userdata from each doc
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String userName =
                            data['firstName'] ?? "No Name Recieved";

                        String userImg = data['image'] ?? "nil";

                        // display as a list tile
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).splashColor,
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(6),
                            leading: (data.containsKey("image") &&
                                    userImg.isNotEmpty)
                                ? ClipOval(
                                    child: FadeInImage.assetNetwork(
                                      placeholder:
                                          'assets/images/img_not_found.jpg',
                                      image: userImg,
                                      fit: BoxFit.cover,
                                      height: 40,
                                      width: 40,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) {
                                        return const CircleAvatar(
                                          child: Icon(
                                            Icons.person_outline_rounded,
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : const CircleAvatar(
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      size: 40,
                                    ),
                                  ),
                            title: Text(
                              userName,
                              style: Theme.of(context).textTheme.labelMedium,
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
