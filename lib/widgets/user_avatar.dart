import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;

  const UserAvatar({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final trimmedName = name.trim();
    final initial = trimmedName.isEmpty ? '?' : trimmedName[0].toUpperCase();

    return CircleAvatar(
      backgroundColor: Colors.grey.shade200,
      foregroundColor: Colors.black87,
      child: Text(initial),
    );
  }
}
