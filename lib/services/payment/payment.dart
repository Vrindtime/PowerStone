import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
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
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection("user");

  final CollectionReference _paymentStatus =
      FirebaseFirestore.instance.collection("payment");

  //READ USER DATA
  Stream<QuerySnapshot> getUserDetailsP(String value) {
    Query userstream = _userCollection.orderBy('firstName', descending: false);
    if (value.isNotEmpty) {
      String searchValue =
          value.toLowerCase(); // Convert search value to lowercase
      String endValue = searchValue.substring(0, searchValue.length - 1) +
          String.fromCharCode(
              searchValue.codeUnitAt(searchValue.length - 1) + 1);
      userstream = userstream.where('firstName',
          isGreaterThanOrEqualTo: searchValue, isLessThan: endValue);
    }
    return userstream.snapshots();
  }

  //READ PAYMENT STATUS
  Stream<DocumentSnapshot<Object?>> getPaymentStatusForMonth(
      String uid, String year, String month) {
    return _paymentStatus.doc(uid).collection(year).doc(month).snapshots();
  }

  //add new payment
  Future<void> addPaymentStatus(String userId, int month, int year) async {
    final String monthName = months[month];
    final DocumentReference userDocRef = _paymentStatus.doc(userId);

    try {
      // Ensure user document exists
      await userDocRef.get();

      // Set payment status for the specified month
      await userDocRef.collection(year.toString()).doc(monthName).set({
        'status': false,
      });

      print(
          'DEBUG Payment status added successfully for $userId: $month/$year');
    } on FirebaseException catch (e) {
      // Handle specific Firebase errors or generic error
      print('DEBUG Error adding payment status: $e');
    } catch (e) {
      // Handle unexpected errors
      print('DEBUG An unexpected error occurred: $e');
    }
  }

  Future<void> updatePaymentStatus(String uid, int month, int year, bool status) async {
        print('DEBUG Got into updatePaymentStatus');
        print('DEBUG YEAR $year AND MONTH $month String AND STATUS $status AND UID $uid');
    // String documentPath = 'payment/$uid/years/$year/months/$month';

    final DocumentReference userDocRef = _paymentStatus.doc(uid);
    final String monthName = months[month];
    print('DEBUG YEAR $year AND MONTH $monthName String AND STATUS $status AND UID $uid');
    await userDocRef.collection(year.toString()).doc(monthName).set({
      'status': status,
    }, SetOptions(merge: true));
  }

  // Function to handle checkbox change
  Future<void> handleCheckboxChange(String uid, int month, int year, bool value) async {
    if (value) {
      // Update status to true
      try {
        updatePaymentStatus(uid, month, year, true);
      } catch (e) {
        print("ERROR: LINE 89 payment.dart ; ERROR UPDATING STATUS");
        addPaymentStatus(uid, month, year);
      }
    } else {
      // Initialize document with default status false
      addPaymentStatus(uid, month, year);
    }
  }

  //tofind total of a month
  // Future<Map<String, int>> getMonthlyEarnings(int year) async {
  //   Map<String, int> monthlyEarnings = {};

  //   try {
  //     QuerySnapshot paymentStatusSnapshot = await _paymentStatus.get();

  //     for (QueryDocumentSnapshot userDoc in paymentStatusSnapshot.docs) {
  //       QuerySnapshot monthSnapshot =
  //           await userDoc.reference.collection(year.toString()).get();

  //       monthSnapshot.docs.forEach((monthDoc) {
  //         String monthName = monthDoc.id;
  //         int earnings = monthlyEarnings[monthName] ?? 0;
  //         bool isPaid = (monthDoc.data() as Map<String, dynamic>)['status'] ?? false;

  //         if (isPaid) {
  //           // Assuming fixed price of 700rs per user
  //           earnings += 700;
  //         }
  //         monthlyEarnings[monthName] = earnings;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error getting monthly earnings: $e');
  //   }
  //   print('DEBUG PAYEMTN>DART: $monthlyEarnings');
  //   return monthlyEarnings;
  // }

  Future<Map<String, int>> getMonthlyEarnings() async {
    _paymentStatus.get().then((QuerySnapshot querySnapshot) {
      print("DEBUG LOOP STARTED");
      for (var doc in querySnapshot.docs) {
        // Access data from each document
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('DEBUG LOOP DATA PRINT: $data');
      }
    }).catchError((error) {
      print('DEBUG: Error reading data: $error');
    });

    final currentYear =
        DateTime.now().year; // Handle potentially stale year input

    Map<String, int> monthlyEarnings = {};
    print('DEBUG: GOT ITNO GET MONTHLY EARN ()');

    //error from try
    try {
      print('DEBUG:GOT ITNO try block payment()');
      QuerySnapshot paymentStatusSnapshot = await _paymentStatus.get();
      var x = paymentStatusSnapshot.docs.length; // as Map<String,dynamic>;
      print('DEBUG QUERY SNAPSHOT LNGTH $x');
      // Iterate over each payment document directly
      for (QueryDocumentSnapshot paymentDoc in paymentStatusSnapshot.docs) {
        print('DEBUG:GOT ITNO paymentDoc loop ()');
        // Extract relevant data from the payment document
        String userId = paymentDoc.id; // Assuming "id" is your user ID field
        String monthName =
            paymentDoc.reference.parent.id; // Get month name from parent
        bool isPaid = (paymentDoc.data() as Map<String, dynamic>)['status'] ??
            false; // Handle potential null data
        print('DEBUG: $isPaid');
        if (isPaid) {
          monthlyEarnings[monthName] = (monthlyEarnings[monthName] ?? 0) + 700;
          print('DEBUG PAYEMTN>DART if else statement: $monthlyEarnings');
        }
      }
    } catch (error) {
      print('Error getting monthly earnings: $error');
      // Handle errors more gracefully (e.g., rethrow or return null)
    }

    return monthlyEarnings;
  }
}
