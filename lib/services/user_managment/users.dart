import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:powerstone/services/payment/payment.dart';

class FirestoreServices {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection("user");
  final PaymentService _paymentService = PaymentService();

  //CREATE
  Future<void> addUser(
      String firstName,
      String lastName,
      String dateOfBirth,
      String gender,
      String job,
      String bloodGroup,
      String height,
      String weight,
      String phone,
      String password,
      String note,
      String? imageUrl) async {
    // Convert all string values to lowercase
    firstName = firstName.toLowerCase();
    lastName = lastName.toLowerCase();
    gender = gender.toLowerCase();
    job = job.toLowerCase();
    note = note.toLowerCase();

    // Add the user to Firestore
    DocumentReference userRef = await _userCollection.add({
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'job': job,
      'bloodGroup': bloodGroup,
      'height': height,
      'weight': weight,
      'phone': phone,
      'password': password,
      'note': note,
      'image': imageUrl,
    });

    // Get current month and year
    final now = DateTime.now();

    // Create payment status document for the new user
    try {
      const Duration(seconds: 1);
      await _paymentService.addPaymentStatus(userRef.id, now.month, now.year);
    } catch (e) {
      print('DEBUG ERROR: $e');
    }
  }

  Future<int> getTotalUsers() async {
    QuerySnapshot querySnapshot = await _userCollection.get();
    int totalUsers = querySnapshot.size;
    return totalUsers;
  }

  //READ
  Stream<QuerySnapshot> getUserDetails(String value) {
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

  //UPDATE
  Future<void> updateUser(
      String docID,
      String firstName,
      String lastName,
      String dateOfBirth,
      String gender,
      String job,
      String bloodGroup,
      String height,
      String weight,
      String phone,
      String password,
      String note,
      String? imageUrl) {
    return _userCollection.doc(docID).update({
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'job': job,
      'bloodGroup': bloodGroup,
      'height': height,
      'weight': weight,
      'phone': phone,
      'password': password,
      'note': note,
      'image': imageUrl,
    });
  }

  //DELETE
  Future<void> deleteUser(String docID) {
    return _userCollection.doc(docID).delete();
  }

  //SEARCH
  Stream<QuerySnapshot> searchResult(String value) {
    final userstream =
        _userCollection.where('firstName', isEqualTo: value).snapshots();
    return userstream;
  }

  // Function to retrieve user data from Firestore
  Future<Map<String, dynamic>> getUserData(String userId) async {
    DocumentSnapshot<Map<String, dynamic>> userData =
        await FirebaseFirestore.instance.collection('user').doc(userId).get();

    return userData.data() ?? {}; // Return user data or empty map if not found
  }
}
