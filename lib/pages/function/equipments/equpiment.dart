import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:powerstone_admin/common/search.dart';
import 'package:powerstone_admin/pages/function/equipments/add_equipement.dart';
import 'package:powerstone_admin/services/function/equipment_service.dart';

class EquipmentPage extends StatefulWidget {
  EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final EquipmentService _equipmentService = EquipmentService();

  String search = '';
  void updateSearch(String newSearch) {
    setState(() {
      search = newSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SearchTextField(
                    onSearchUpdate: updateSearch,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  radius: 20,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const AddEquipemnts()));
                    },
                    icon: Icon(
                      Icons.add,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Equipments List',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: _equipmentService.getEquipment(search),
              builder: (context, snapshot) {
                print('Search: $search');
                if (snapshot.hasError) {
                  return const Text("Error");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Expanded(child: _equipmentList(snapshot));
              },
            ),
          ],
        ),
      ),
    );
  }

  //custom components Here after
  AppBar customAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 65,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.clear_outlined,
          size: 32,
        ),
        color: Theme.of(context).primaryColor,
      ),
      title: const Text('EQUIPMENT MANGMENT'),
      centerTitle: true,
    );
  }

  ListView _equipmentList(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox.shrink(),
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        DocumentSnapshot doc = snapshot.data!.docs[index];
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String name = data["EquipmentName"];
        String price = data["EquipmentPrice"];
        String brand = data["EquipmentBrand"];
        String description = data["EquipmentDescription"];
        String img = data["EquipmentImage"];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Image Section
                Container(
                  width: 120,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                  child: (img != '')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/img_not_found.jpg',
                            image: img,
                            fit: BoxFit.cover,
                            height: 40,
                            width: 40,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return const CircleAvatar(
                                child: Icon(
                                  Icons.wifi_tethering_error_sharp,
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
                ),
                const SizedBox(width: 12), // Space between image and text

                // Text Information Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: $name',
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Brand: $brand',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Price: ₹$price',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Description: $description',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
