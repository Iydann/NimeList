import 'package:flutter/material.dart';

import 'app_button.dart';

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
          children: [
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              AppButton(label: 'Coba lagi', onPressed: onRetry!),
            ],
          ],
        ),
      ),
    );
  }
}
