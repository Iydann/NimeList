import 'package:flutter/material.dart';

class AnimeFeedback extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AnimeFeedback({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null)
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
          ],
        ),
      ),
    );
  }
}
