import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String trailing;
  final void Function(BuildContext)? onEditPressed;
  final void Function(BuildContext)? onDeletePressed;

  const MyListTile({
    super.key,
    required this.title,
    required this.trailing,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          //* settings option
          SlidableAction(
            onPressed: onEditPressed,
            icon: Icons.edit,
            label: 'Edit',
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          //* delete option
          SlidableAction(
            onPressed: onDeletePressed,
            icon: Icons.delete,
            label: 'Delete',
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
      child: ListTile(
        title: Text(title),
        trailing: Text(trailing),
      ),
    );
  }
}
