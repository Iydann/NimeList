import 'package:flutter/material.dart';
import '../favorite_data.dart';

class DetailScreen extends StatefulWidget {
  final String title;
  final String score;
  final String status;
  final String userName;

  const DetailScreen({
    super.key,
    required this.title,
    required this.score,
    required this.status,
    required this.userName,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  final List<Map<String, String>> _comments = [
    {
      'name': 'NimeList User',
      'content': 'Alurnya seru bet',
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = myAnimeList.any(
      (anime) => anime['title'] == widget.title,
    );

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
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Score: ${widget.score}'),
            Text('Status: ${widget.status}'),
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

            // Tombol favorit berubah sesuai status anime.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    if (isFavorite) {
                      myAnimeList.removeWhere(
                        (anime) => anime['title'] == widget.title,
                      );
                    } else {
                      myAnimeList.add({
                        'title': widget.title,
                        'score': widget.score,
                        'status': widget.status,
                      });
                    }
                  });
                },
                icon: Icon(
                  isFavorite
                      ? Icons.bookmark_remove_outlined
                      : Icons.bookmark_add_outlined,
                ),
                label: Text(
                  isFavorite ? 'Remove from My List' : 'Add to My List',
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Komentar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                CircleAvatar(
                  child: Text(widget.userName[0].toUpperCase()),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Tulis komentar...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  final text = _commentController.text.trim();

                  if (text.isNotEmpty) {
                    setState(() {
                      _comments.add({
                        'name': widget.userName,
                        'content': text,
                      });
                    });
                    _commentController.clear();
                  }
                },
                child: const Text('Post Comment'),
              ),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                final bool isMyComment = comment['name'] == widget.userName;

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(comment['name']![0].toUpperCase()),
                    ),
                    title: Text(comment['name']!),
                    subtitle: Text(comment['content']!),
                    trailing: isMyComment
                        ? IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              setState(() {
                                _comments.removeAt(index);
                              });
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
