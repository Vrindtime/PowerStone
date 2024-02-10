import 'package:flutter/material.dart';
import 'package:popover/popover.dart';

class DotMenu extends StatelessWidget {
  const DotMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPopover(
        height: 80.0,
        context: context,
        bodyBuilder: (context) => const MenuItems(),
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
          child: SizedBox(
            height: 30,
            width: 100,
            child: Center(
                child: Text('View',
                    style: Theme.of(context).textTheme.labelMedium)),
          ),
        ),
        InkWell(
          onTap: () {},
          child: SizedBox(
            height: 30,
            width: 100,
            child: Center(
                child: Text('Update',
                    style: Theme.of(context).textTheme.labelMedium)),
          ),
        ),
        InkWell(
          onTap: () {},
          child: SizedBox(
            height: 30,
            width: 100,
            child: Center(
                child: Text('Delete',
                    style: Theme.of(context).textTheme.labelMedium)),
          ),
        ),
      ],
    );
  }
}
