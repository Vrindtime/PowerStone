import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:powerstone/navigation_menu.dart';
import 'package:powerstone/services/function/equipment_service.dart';

class AddEquipemnts extends StatefulWidget {
  const AddEquipemnts({super.key});

  @override
  State<AddEquipemnts> createState() => _AddEquipemntsState();
}

class _AddEquipemntsState extends State<AddEquipemnts> {
  final EquipmentService _equipmentService = EquipmentService();
  String imageUrl = '';
  bool isImageSelected = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String getExtension(XFile file) {
    final path = file.path;
    return path.substring(path.lastIndexOf('.') + 1);
  }

  void selectImage() async {
    final source = await showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {}, // Prevent closing on outside tap
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_album),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
            )
          ],
        ),
      ),
    );

    if (source != null) {
      final file = await ImagePicker().pickImage(source: source);
      if (file != null) {
        String fileName =
            '${DateTime.now().microsecondsSinceEpoch}.${getExtension(file)}';
        //ref to storage root
        Reference referenceRoot = FirebaseStorage.instance.ref();
        //imgFolder
        Reference referenceDireImages = referenceRoot.child('equipment');

        //reference to uplaod img
        Reference referenceImageToUpload = referenceDireImages.child(fileName);
        try {
          await referenceImageToUpload.putFile(File(file.path));
          var temputl = await referenceImageToUpload.getDownloadURL();
          setState(() {
            imageUrl = temputl!;
          });
          print("DUBUG: Success uplaoding equipemnt");
        } catch (e) {
          if (imageUrl.isEmpty) {
            isImageSelected = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                    child: Text(
                  'Error in uploading Image to DB Storage',
                  style: Theme.of(context).textTheme.labelMedium,
                )),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
          color: Theme.of(context).primaryColor,
        ),
        title: const Text('ADD EQUIPMENTS'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //Image Upload
                pfpImageUpload(context),
                const SizedBox(
                  height: 40,
                ),

                //Name
                TextInput(controller: nameController, label: 'Name'),
                const SizedBox(
                  height: 30,
                ),
                //Brand
                TextInput(controller: brandController, label: 'Brand'),
                const SizedBox(
                  height: 30,
                ),
                //Price
                TextInput(controller: priceController, label: 'Price'),
                const SizedBox(
                  height: 30,
                ),
                //Description
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: TextField(
                    maxLines: 5,
                    keyboardType: TextInputType.name,
                    controller: descriptionController,
                    style: Theme.of(context).textTheme.labelMedium,
                    decoration: InputDecoration(
                      label: const Text('Description'),
                      labelStyle: Theme.of(context).textTheme.labelSmall,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: const BorderSide(
                              color: Colors.white, width: 0.5)),
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
                  height: 40,
                ),
                //Add Button
                addItemBtn(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget pfpImageUpload(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Stack(
        children: [
          CircleAvatar(
            maxRadius: 80,
            child: (imageUrl == '' && imageUrl.isEmpty)
                ? const Icon(
                    Icons.add_a_photo_rounded,
                    size: 70,
                  )
                : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      height: 110,
                      width: 110,
                    ),
                  ),
          ),
          Positioned(
            bottom: 2,
            left: 120,
            child: IconButton(
              icon: Icon(
                Icons.add_a_photo_rounded,
                size: 30,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () => selectImage(),
            ),
          )
        ],
      );
    });
  }

  GestureDetector addItemBtn(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        String name = nameController.text;
        String brand = brandController.text;
        String price = priceController.text;
        String description = descriptionController.text;
        String img = imageUrl;

        await _equipmentService.addItem(name, price, brand, description, img);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
                child: Text(
              'Success',
              style: Theme.of(context).textTheme.labelMedium,
            )),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const NavigationMenu()));
      },
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            "Add Item",
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }
}

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: TextField(
        keyboardType: TextInputType.name,
        controller: controller,
        style: Theme.of(context).textTheme.labelMedium,
        decoration: InputDecoration(
          label: Text(label),
          labelStyle: Theme.of(context).textTheme.labelSmall,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: const BorderSide(color: Colors.white, width: 0.5)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide(
              color:
                  Theme.of(context).primaryColor, // Border color when focused
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
