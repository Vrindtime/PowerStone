import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String image;
  final Function()? ontap;
  const UserTile({super.key, required this.text, required this.ontap,required this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: Theme.of(context).splashColor,
            borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(6),
          leading: (image !="nil")
              ? ClipOval(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/img_not_found.jpg',
                    image: image,
                    fit: BoxFit.cover,
                    height: 40,
                    width: 40,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
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
            text,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}
