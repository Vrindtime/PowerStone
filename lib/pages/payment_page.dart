import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:powerstone/common/logout_confirmation.dart';
import 'package:powerstone/common/profile_picture.dart';
import 'package:powerstone/pages/Starter/loginPage.dart';
import 'package:powerstone/services/payment/payment.dart';
import 'package:powerstone/services/user_managment/users.dart';

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
  final List<String> paymentOptions = ["All User", "Paid", "UnPaid"];
  String selectedFilter = 'All User';
  final FirestoreServices firestoreServices = FirestoreServices();
  final PaymentService paymentService = PaymentService();
  List<String> selectedUser = [];

  final now = DateTime.now();
  String? selectedMonth;
  String? selectedYear;
  int totalValue = 0;

  @override
  void initState() {
    super.initState();
    int currentmonth = now.month;
    int currentyear = now.year;
    selectedMonth = months[currentmonth - 1];
    selectedYear = currentyear.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('payment')
                .doc('earning')
                .collection(selectedYear!)
                .doc(selectedMonth!)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData) {
                final doc = snapshot.data!;
                int totalValuecus = 0;
                final data = doc.data(); // Retrieve the data map from the DocumentSnapshot

                if (data != null && data.containsKey('value')) {
                  // Check if 'value' field exists in the data map
                  totalValuecus = data['value'];
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    "Monthly Income: $totalValuecus",
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(fontSize: 21),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: firestoreServices.getUserDetails(search),
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
                                  String docID =
                                      document.id; //keep track of users

                                  //get userdata from each doc
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;
                                  String userName =
                                      data['firstName'] ?? "No Name Recieved";
                                  String userImg = data['image'] ??
                                      "https://static.vecteezy.com/system/resources/previews/005/337/799/original/icon-image-not-found-free-vector.jpg";

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
                                        if (snapshot.connectionState ==
                                            ConnectionState.none) {
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
                                            payStatus = data['status'];
                                            payStatus ??= false;
                                          }

                                          switch (selectedFilter) {
                                            case 'All User':
                                              return PaymentStatusTile(
                                                document: document,
                                                userImg: userImg,
                                                userName: userName,
                                                payStatus: payStatus,
                                                docID: docID,
                                                givenMonth: selectedMonth ??
                                                    now.month.toString(),
                                                givenYear: selectedYear ??
                                                    now.year.toString(),
                                              );
                                            case 'Paid':
                                              return (payStatus == true)
                                                  ? PaymentStatusTile(
                                                      document: document,
                                                      userImg: userImg,
                                                      userName: userName,
                                                      payStatus: payStatus,
                                                      docID: docID,
                                                      givenMonth:
                                                          selectedMonth ??
                                                              now.month
                                                                  .toString(),
                                                      givenYear: selectedYear ??
                                                          now.year.toString(),
                                                    )
                                                  : const SizedBox.shrink();
                                            case 'UnPaid':
                                              return (payStatus == false)
                                                  ? PaymentStatusTile(
                                                      document: document,
                                                      userImg: userImg,
                                                      userName: userName,
                                                      payStatus: payStatus,
                                                      docID: docID,
                                                      givenMonth:
                                                          selectedMonth ??
                                                              now.month
                                                                  .toString(),
                                                      givenYear: selectedYear ??
                                                          now.year.toString(),
                                                    )
                                                  : const SizedBox.shrink();
                                            default:
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
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
          // ignore: use_build_context_synchronously
          final logoutConfirmed = await showLogoutConfirmation(context);
          if (logoutConfirmed!) {
            await FirebaseAuth.instance.signOut();
            // ignore: use_build_context_synchronously
            Navigator.of(context).push(
                MaterialPageRoute(builder: ((context) => const LoginPage())));
          }
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
              Navigator.pushNamed(context, '/notification');
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: ((context) => const NotificationWidget())));
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

class PaymentStatusTile extends StatefulWidget {
  PaymentStatusTile({
    super.key,
    required this.document,
    required this.userImg,
    required this.userName,
    required this.payStatus,
    required this.docID,
    required this.givenMonth,
    required this.givenYear,
  });

  final DocumentSnapshot<Object?> document;
  final String userImg;
  final String userName;
  final String docID;
  final String givenMonth;
  final String givenYear;
  final bool? payStatus;

  @override
  State<PaymentStatusTile> createState() => _PaymentStatusTileState();
}

class _PaymentStatusTileState extends State<PaymentStatusTile> {
  final PaymentService paymentService = PaymentService();

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).splashColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
          contentPadding: const EdgeInsets.all(6),
          leading: (widget.userImg.isNotEmpty)
              ? ProfilePicture(userImg: widget.userImg)
              : const CircleAvatar(
                  radius: 40,
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 50,
                  ),
                ),
          title: Text(
            widget.userName,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          trailing: Checkbox(
            value: widget.payStatus ?? false,
            onChanged: (bool? value) async {
              try {
                // Convert givenYear from string to integer
                int year = int.parse(widget.givenYear);
                int monthIndex = months.indexOf(widget.givenMonth);
                await paymentService.handleCheckboxChange(
                    widget.docID, monthIndex, year, value ?? true);
                // widget.updateTotalValue();
              } catch (e) {
                print("DEBUG: ERROR PASSING handleCheckboxChange: $e");
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
