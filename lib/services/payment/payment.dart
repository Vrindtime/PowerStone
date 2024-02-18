import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
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
    final String monthName = months[month-1];
    final DocumentReference userDocRef = _paymentStatus.doc(userId);

    try {
      // Ensure user document exists
      await userDocRef.get();

      // Set payment status for the specified month
      await userDocRef.collection(year.toString()).doc(monthName).set({
        'status': false,
        'money': 0,
      });

      print('DEBUG Payment status added successfully for $userId: $month/$year');
    } on FirebaseException catch (e) {
      // Handle specific Firebase errors or generic error
      print('DEBUG Error adding payment status: $e');
    } catch (e) {
      // Handle unexpected errors
      print('DEBUG An unexpected error occurred: $e');
    }
  }
}
