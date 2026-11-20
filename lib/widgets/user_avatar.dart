import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedName = name.trim();
    final initial = trimmedName.isEmpty ? '?' : trimmedName[0].toUpperCase();
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey.shade200,
      foregroundColor: Colors.black87,
      child: Text(initial),
    );

    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return fallback;
    }

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticLabel: '$name profile picture',
        loadingBuilder: (context, child, loadingProgress) {
          return loadingProgress == null ? child : fallback;
        },
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}
