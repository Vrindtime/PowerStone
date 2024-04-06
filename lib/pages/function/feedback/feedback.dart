import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:powerstone/common/search.dart';
import 'package:powerstone/pages/function/feedback/add_feedback.dart';
import 'package:powerstone/services/function/feedback_service.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _searchController = TextEditingController();
  final FeedBackService _feedbackService = FeedBackService();
  // Get the current user ID
  late String userId;
  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid; // Return the user ID if the user is logged in
    } else {
      return null; // Return null if no user is logged in
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userId = getCurrentUserId()!;
  }

  String search = '';
  void updateSearch(String newSearch) {
    setState(() {
      search = newSearch;
    });
  }

  void createNewFeedBack() {
    showDialog(
      context: context,
      builder: (context) {
        return AddFeedbackPage();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                child: SearchTextField(
                  onSearchUpdate: updateSearch,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _feedbackService.getFeedBacks(search),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No Feedback Found'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
                      String feedback = data['feedback'];
                      int vote = data['upvotes'];
                      return Card(
                        child: ListTile(
                          title: Text(
                            feedback,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          subtitle: Text('Upvotes: ${vote.toString()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.thumb_up,
                                    color: data['upvotedBy'] != null &&
                                            data['upvotedBy'].contains(userId)
                                        ? Colors.green
                                        : null),
                                onPressed: () {
                                  _feedbackService.upvoteFeedback(
                                      doc.id, userId);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.thumb_down,
                                    color: data['downvotedBy'] != null &&
                                            data['downvotedBy'].contains(userId)
                                        ? Colors.red
                                        : null),
                                onPressed: () {
                                  _feedbackService.downvoteFeedback(
                                      doc.id, userId);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        
        onPressed: () {
          createNewFeedBack();
        },
        child: const Icon(Icons.add),
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
      title: const Text('FEEDBACK'),
      centerTitle: true,
    );
  }
}
