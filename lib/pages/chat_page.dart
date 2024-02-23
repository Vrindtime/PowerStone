import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:powerstone/common/notification.dart';
import 'package:powerstone/common/profile_picture.dart';
import 'package:powerstone/pages/chat_room.dart';
import 'package:powerstone/pages/loginPage.dart';
import 'package:powerstone/services/user_managment/users.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final FirestoreServices firestoreServices = FirestoreServices();
  final TextEditingController searchController = TextEditingController();
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: ChatList(
        firestoreServices: firestoreServices,
        search: search,
        searchController: searchController,
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
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(
              MaterialPageRoute(builder: ((context) => const LoginPage())));
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
          child: SizedBox(
            width: 250,
            child: searchTextField(context),
          ),
        ),
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

  TextField searchTextField(BuildContext context) {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        label: const Text("Search"),
        labelStyle: Theme.of(context).textTheme.labelSmall,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: const BorderSide(color: Colors.white, width: 0.5)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.0),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor, // Border color when focused
            width: 0.5,
          ),
        ),
        suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                search = searchController.text;
              });
            },
            icon: Icon(
              Icons.search,
              color: Theme.of(context).primaryColor,
            )),
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  const ChatList({
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
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: StreamBuilder(
          stream: firestoreServices.getUserDetails(search),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Lottie.asset('assets/lottie/green_dumbell.json',
                  fit: BoxFit.contain);
            }
            //if we have data, get all the docs
            if (snapshot.hasData) {
              List userList = snapshot.data!.docs;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Chat: ${userList.length}",
                    style: const TextStyle(
                        fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        //get each individual doc
                        DocumentSnapshot document = userList[index];
                        String docID = document.id; //keep track of users
      
                        //get userdata from each doc
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        String userName = data['firstName'] ?? "No Name Recieved";
      
                        String userImg = data['image'];
      
                        // display as a list tile
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Theme.of(context).splashColor,
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(6),
                            leading: (userImg.isNotEmpty)
                                ? ProfilePicture(userImg: userImg)
                                : const CircleAvatar(
                                    radius: 40,
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      size: 50,
                                    ),
                                  ),
                            title: Text(
                              userName,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.chat),
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ChatRoom(
                                          username: userName,
                                          reciverID: docID,
                                          img: userImg,
                                        )));
                              },
                            ),
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


