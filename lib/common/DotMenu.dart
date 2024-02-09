import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class DotMenu extends StatelessWidget {
  const DotMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPopover(
        context: context,
        bodyBuilder: (context) => const MenuItems(),
        width: 120,
        height: 78,
        direction: PopoverDirection.left,
        arrowWidth: 10,
        backgroundColor: Theme.of(context).primaryColor
      ),
      child: Icon(
        Icons.more_vert,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class MenuItems extends StatelessWidget {
  const MenuItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Container(
            height: 30,
            child: Center(
                child: Text('View',
                    style: Theme.of(context).textTheme.labelMedium)),
          ),
        ),
        InkWell(
          onTap: () {},
          child: Container(
            height: 30,
            child: Center(
                child: Text('Update',
                    style: Theme.of(context).textTheme.labelMedium)),
          ),
        ),
        InkWell(
          onTap: () {},
          child: Container(
            height: 30,
            child: Center(
                child: Text('Delete',
                    style: Theme.of(context).textTheme.labelMedium)),
          ),
        ),
      ],
    );
  }
}
