class Equipments {
  final String name;
  final String price;
  final String brand;
  final String description;
  final String img;

  Equipments({
    required this.name,
    required this.price,
    required this.brand,
    required this.description,
    required this.img,
  });

  //convert to a map

  Map<String, dynamic> toMap() {
    return {
      'EquipmentName': name,
      'EquipmentPrice': price,
      'EquipmentBrand': brand,
      'EquipmentDescription': description,
      'EquipmentImage': img
    };
  }
}
