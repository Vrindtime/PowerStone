import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:powerstone/models/equipment_model.dart';

class EquipmentService {
  final CollectionReference _equipmentCollection =
      FirebaseFirestore.instance.collection("equipment");

  //Save the Equipemnt to the DB
  Future<void> addItem(String name, String price, String brand,
      String description, String img) async {
    Equipments newEquipment = Equipments(
        name: name,
        price: price,
        brand: brand,
        description: description,
        img: img);
    await _equipmentCollection.add(newEquipment.toMap());
  }

  //get Equipemnt List
  Stream<QuerySnapshot> getEquipment(String value) {
    Query equipmentStream = _equipmentCollection;

    //function to filter search
    if (value.isNotEmpty) {
      String searchValue =
          value.toLowerCase(); // Convert search value to lowercase
      String endValue = searchValue.substring(0, searchValue.length - 1) +
          String.fromCharCode(
              searchValue.codeUnitAt(searchValue.length - 1) + 1);
      equipmentStream = _equipmentCollection.where(
        'EquipmentName',
        isGreaterThanOrEqualTo: searchValue,
        isLessThan: endValue,
      );
    }
    return equipmentStream.snapshots();
  }
}
