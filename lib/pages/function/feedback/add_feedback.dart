import 'package:flutter/material.dart';
import 'package:powerstone_admin/services/function/feedback_service.dart'; // Assuming this is where your FeedBackService class is defined

class AddFeedbackPage extends StatefulWidget {
  AddFeedbackPage({super.key});

  @override
  State<AddFeedbackPage> createState() => _AddFeedbackPageState();
}

class _AddFeedbackPageState extends State<AddFeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();

  final FeedBackService _feedbackService = FeedBackService();

  String feeback = '';

  TextEditingController feedbackController = TextEditingController();

  void updateSearch(String newfeeback) {
    setState(() {
      feeback = newfeeback;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: double.infinity,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: feedbackController,
              decoration: InputDecoration(
                label: const Text("Enter Your Feedback"),
                labelStyle: Theme.of(context).textTheme.labelMedium,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    borderSide:
                        const BorderSide(color: Colors.white, width: 0.5)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: BorderSide(
                    color: Theme.of(context)
                        .primaryColor, // Border color when focused
                    width: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).primaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextButton(
                    onPressed: () async {
                      FeedBackService fbs = FeedBackService();
                      await fbs.addFeedBack(feedback: feedbackController.text, upvotes: 0, timestamp: DateTime.now());
                      Navigator.pop(context);
                    },
                    child: Text(
                      'ADD FEEDBACK',
                      style: Theme.of(context).textTheme.labelSmall,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
