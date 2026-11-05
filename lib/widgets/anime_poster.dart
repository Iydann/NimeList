import 'package:flutter/material.dart';

class AnimePoster extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double? height;
  final double borderRadius;

  const AnimePoster({
    super.key,
    this.imageUrl,
    this.width = double.infinity,
    this.height,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final placeholder = ColoredBox(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.black38),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null || url.isEmpty
            ? placeholder
            : Image.network(
                url,
                width: width,
                height: height,
                fit: BoxFit.cover,
                semanticLabel: 'Poster anime',
                loadingBuilder: (context, child, loadingProgress) {
                  return loadingProgress == null ? child : placeholder;
                },
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}
