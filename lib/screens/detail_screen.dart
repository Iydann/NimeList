import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String title;
  final String score;
  final String status;

  const DetailScreen({
    super.key,
    required this.title,
    required this.score,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anime Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Score: $score'),
            Text('Status: $status'),
            const SizedBox(height: 16),
            const Text(
              'Sinopsis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Deskripsi anime masih menggunakan data dummy untuk sementara.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ditambahkan ke My List')),
                  );
                },
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Add to My List'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
