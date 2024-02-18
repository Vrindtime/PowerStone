import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:powerstone/common/notification.dart';
import 'package:powerstone/pages/loginPage.dart';
import 'package:powerstone/services/payment/payment.dart';
import 'package:powerstone/services/user_managment/firestore.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({
    super.key,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  TextEditingController searchController = TextEditingController();

  String search = "";
  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  List<String> years = [
    "2015",
    "2016",
    "2017",
    "2018",
    "2019",
    "2020",
    "2021",
    "2022",
    "2023",
    "2024"
  ];

  int totalValue = 0;
  final List<String> paymentOptions = ["All User", "Paid", "UnPaid"];
  String selectedFilter = 'All User';
  final FirestoreServices firestoreServices = FirestoreServices();
  final PaymentService paymentService = PaymentService();
  List<String> selectedUser = [];

  final now = DateTime.now();
  String? selectedMonth;
  String? selectedYear;
  @override
  void initState() {
    super.initState();
    selectedMonth = months[now.month - 1];
    selectedYear = now.year.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              "Monthly Income: $totalValue",
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontSize: 21),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: _monthSelectDDB(context)),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: _yearSelectDDB(context)),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: paymentOptions
                .map(
                  (op) => FilterChip(
                    selected: selectedFilter == op, // Highlight selected chip
                    label: Text(
                      op,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = selected ? op : 'all';
                      });
                    },
                  ),
                )
                .toList(),
          ),
          Expanded(
            child: StreamBuilder(
              stream: paymentService.getUserDetailsP(search),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error has Occurred"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Lottie.asset('assets/lottie/green_dumbell.json',
                      fit: BoxFit.contain);
                }
                if (snapshot.hasData) {
                  List userList = snapshot.data!.docs;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
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
                            String userName =
                                data['firstName'] ?? "No Name Recieved";
                            String userImg = data['image'] ?? "nil";

                            // Retrieve payment status for February 2024
                            Stream<DocumentSnapshot> paymentStream =
                                paymentService.getPaymentStatusForMonth(
                                    docID, selectedYear!, selectedMonth!);

                            // display as a list tile
                            return StreamBuilder(
                                stream: paymentStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return const Text(
                                        'Error retrieving payment status');
                                  }
                                  if (snapshot.hasData) {
                                    DocumentSnapshot paymentSnapshot =
                                        snapshot.data as DocumentSnapshot;
                                    bool? payStatus;
                                    if (paymentSnapshot.exists) {
                                      final data = paymentSnapshot.data()
                                          as Map<String, dynamic>;
                                      payStatus = data['status'] as bool?;
                                    }

                                    switch (selectedFilter) {
                                      case 'All User':
                                        return (payStatus != null)
                                            ? PaymentStatusTile(
                                                document: document,
                                                userImg: userImg,
                                                userName: userName,
                                                payStatus: payStatus,
                                                paymentSnapshot:
                                                    paymentSnapshot)
                                            : const SizedBox.shrink();
                                      case 'Paid':
                                        return (payStatus == true && payStatus != null)
                                            ? PaymentStatusTile(
                                                document: document,
                                                userImg: userImg,
                                                userName: userName,
                                                payStatus: payStatus,
                                                paymentSnapshot:
                                                    paymentSnapshot)
                                            : const SizedBox.shrink();
                                      case 'UnPaid':
                                        return (payStatus == false && payStatus != null)
                                            ? PaymentStatusTile(
                                                document: document,
                                                userImg: userImg,
                                                userName: userName,
                                                payStatus: payStatus,
                                                paymentSnapshot:
                                                    paymentSnapshot)
                                            : const SizedBox.shrink();
                                      default:
                                        return const Center(
                                            child: CircularProgressIndicator());
                                    }
                                  }
                                  return const Center(
                                      child: CircularProgressIndicator());
                                });
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }

  DropdownButtonHideUnderline _monthSelectDDB(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        hint: Text("Month", style: Theme.of(context).textTheme.labelSmall),
        value: selectedMonth,
        buttonStyleData: ButtonStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 0.2),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          elevation: 0,
        ),
        onChanged: (String? value) {
          setState(() {
            selectedMonth = value;
          });
        },
        items: months
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ))
            .toList(),
        dropdownStyleData: DropdownStyleData(
          maxHeight: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          offset: const Offset(-20, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(3),
            thumbVisibility: MaterialStateProperty.all(true),
          ),
        ),
      ),
    );
  }

  DropdownButtonHideUnderline _yearSelectDDB(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        hint: Text("Year", style: Theme.of(context).textTheme.labelSmall),
        value: selectedYear,
        buttonStyleData: ButtonStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white, width: 0.2),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          elevation: 0,
        ),
        onChanged: (String? value) {
          setState(() {
            selectedYear = value;
          });
        },
        items: years
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ))
            .toList(),
        dropdownStyleData: DropdownStyleData(
          maxHeight: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          offset: const Offset(-20, 0),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all(3),
            thumbVisibility: MaterialStateProperty.all(true),
          ),
        ),
      ),
    );
  }

  //appbar
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

class PaymentStatusTile extends StatelessWidget {
  const PaymentStatusTile({
    Key? key,
    required this.document,
    required this.userImg,
    required this.userName,
    required this.payStatus,
    required this.paymentSnapshot,
  });

  final DocumentSnapshot<Object?> document;
  final String userImg;
  final String userName;
  final bool? payStatus;
  final DocumentSnapshot<Object?> paymentSnapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
          contentPadding: const EdgeInsets.all(6),
          leading:
              ((document.data() as Map<String, dynamic>).containsKey("image") ||
                      userImg.isNotEmpty)
                  ? ClipOval(
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/img_not_found.jpg',
                        image: userImg,
                        fit: BoxFit.cover,
                        height: 40,
                        width: 40,
                        imageErrorBuilder: (context, error, stackTrace) {
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
          trailing: Checkbox(
            value: payStatus,
            onChanged: (bool? value) {
              try {
                paymentSnapshot.reference.update({
                  'status': value,
                });
              } catch (e) {
                print("Not Found");
              }
            },
            // tristate: true, //fix the user list and remove this DEBUG
            activeColor: Theme.of(context).primaryColor,
            checkColor: Colors.black,
            semanticLabel: "Pay Status",
          )),
    );
  }
}
