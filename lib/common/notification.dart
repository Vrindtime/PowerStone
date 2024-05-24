import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:powerstone_admin/services/keys/api_config.dart';
import 'package:powerstone_admin/services/notifications/curd_notifications.dart';
import 'package:powerstone_admin/services/notifications/push_notifications.dart';
import 'package:http/http.dart' as http;
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late String fcmKey;
  @override
  void initState() {
    super.initState();
    fcmKey = ApiConfig.cloudMessagingAPI;
  }
  final TextEditingController _messageController = TextEditingController();
  final NotificationService notificationService = NotificationService();
  //creating an object for PushNoti
  FCMNotificationServices fcmNotificationServices = FCMNotificationServices();

  String _getTime(Timestamp? time) {
    if (time == null) {
      return 'Unknown';
    } else {
      DateTime dateTime = time.toDate();
      String formattedTime =
          DateFormat.jm().format(dateTime); // Format the DateTime object
      return formattedTime;
    }
  }

  void sendMessage() async {
    // if there is something inside the textfield
    if (_messageController.text.isNotEmpty) {
      await notificationService.addNotification(_messageController.text);
      await fcmNotificationServices.getDeviceToken().then((value) async {
        var data = {
          'to': '/topics/all', // Send to all devices subscribed to "all" topic
          'priority': 'high',
          'notification': {
            'title': 'Notification',
            'body': _messageController.text,
          },
          'data':{
            'type':'notification'
          }
        };
        var response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: jsonEncode(data),
          headers: {
            'Content-Type':'application/json; charset=UTF-8',
            'Authorization':'key=$fcmKey'
          }
        ); 
        if (response.statusCode == 200) {
        print('Notification sent to all devices successfully');
      } else {
        print('Failed to send notification to all devices. Status code: ${response.statusCode}');
        print(data);
      }
      });
    }
    
    _messageController.text = '';
    _messageController.clear();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: customAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            child: Column(
              children: [
                //Input to add notifications
                SizedBox(
                  height: 50,
                  child: _buildUserInput(context),
                ),
                Divider(
                  color: Theme.of(context).primaryColor,
                  thickness: 3,
                ),
                //show the notification stream
                SizedBox(
                  height: 600,
                  width: double.infinity,
                  child: notificationStream(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> notificationStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: notificationService.getNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Lottie.asset('assets/lottie/green_dumbell.json',
              fit: BoxFit.contain);
        }

        // Build your notification list UI using snapshot.data.documents
        List<QueryDocumentSnapshot> notifications = snapshot.data!.docs;
        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            var notification = notifications[index];
            String formattedTime = _getTime(notification['timestamp']);
            return Column(
              children: [
                ListTile(
                  title: Text(notification['message'],
                      style: Theme.of(context).textTheme.labelMedium),
                  subtitle: Text(
                    formattedTime,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      await notificationService
                          .deleteNotification(notification.id);
                    },
                  ),
                ),
                Divider(
                  color: Theme.of(context).splashColor,
                  height: 1,
                  thickness: 1,
                ),
              ],
            );
          },
        );
      },
    );
  }

  AppBar customAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () async {
          Navigator.of(context).pop();
        },
        icon: const Icon(
          Icons.close,
          size: 32,
        ),
        color: Theme.of(context).primaryColor,
      ),
      title: const Text('N O T I F I C A T I O N S'),
      centerTitle: true,
    );
  }

  //build msg input
  Widget _buildUserInput(context) {
    return Row(
      children: [
        Flexible(
          child: TextField(
            controller: _messageController,
            style: Theme.of(context).textTheme.labelMedium,
            decoration: InputDecoration(
              hintText: "Enter Notification Text",
              labelStyle: Theme.of(context).textTheme.labelSmall,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: const BorderSide(color: Colors.white, width: 0.5),
              ),
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
        ),
        const SizedBox(
          width: 8,
        ),
        CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          radius: 22,
          child: IconButton(
              onPressed: sendMessage,
              icon: Icon(
                Icons.add,
                color: Theme.of(context).scaffoldBackgroundColor,
              )),
        )
      ],
    );
  }
}
