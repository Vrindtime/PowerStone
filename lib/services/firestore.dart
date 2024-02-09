import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection("user");

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
  ) {
    // Convert all string values to lowercase
    firstName = firstName?.toLowerCase() ?? "nil";
    lastName = lastName?.toLowerCase() ?? "nil";
    gender = gender?.toLowerCase() ?? "nil";
    job = job?.toLowerCase() ?? "nil";
    note = note?.toLowerCase() ?? "nil";

    // Add the user to Firestore
    return _userCollection.add({
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth ?? "nil",
      'gender': gender,
      'job': job,
      'bloodGroup': bloodGroup??"nil",
      'height': height ?? "nil",
      'weight': weight ?? "nil",
      'phone': phone,
      'password': password??"nil",
      'note': note,
    });
  }

  Future<int> getTotalUsers() async {
    QuerySnapshot querySnapshot = await _userCollection.get();
    int totalUsers = querySnapshot.size;
    return totalUsers;
  }

  //READ
  Stream<QuerySnapshot> getUserDetails(String value) {
    Query userstream = _userCollection.orderBy('firstName', descending: false);
    if (value != null && value.isNotEmpty) {
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

  //DELETE

  //SEARCH
  Stream<QuerySnapshot> searchResult(String value) {
    final userstream =
        _userCollection.where('firstName', isEqualTo: value).snapshots();
    return userstream;
  }
}
