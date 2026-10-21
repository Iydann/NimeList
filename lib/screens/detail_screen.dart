import 'package:flutter/material.dart';

import '../favorite_data.dart';
import '../widgets/anime_poster.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/user_avatar.dart';

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
    {'name': 'NimeList User', 'content': 'Alurnya seru bet'},
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
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Anime Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AnimePoster(height: 260, borderRadius: 12),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Score: ${widget.score}'),
            Text('Status: ${widget.status}'),
            const SizedBox(height: 16),
            const Text(
              'Sinopsis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Deskripsi anime masih menggunakan data dummy untuk sementara.',
            ),
            const SizedBox(height: 16),

            // Tombol favorit berubah sesuai status anime.
            SizedBox(
              width: double.infinity,
              child: AppButton(
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
                icon: isFavorite
                    ? Icons.bookmark_remove_outlined
                    : Icons.bookmark_add_outlined,
                label: isFavorite ? 'Remove from My List' : 'Add to My List',
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Komentar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                UserAvatar(name: widget.userName),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    controller: _commentController,
                    hintText: 'Tulis komentar...',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: AppButton(
                label: 'Post Comment',
                onPressed: () {
                  final text = _commentController.text.trim();

                  if (text.isNotEmpty) {
                    setState(() {
                      _comments.add({'name': widget.userName, 'content': text});
                    });
                    _commentController.clear();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              itemBuilder: (context, index) {
                final comment = _comments[index];
                final bool isMyComment = comment['name'] == widget.userName;

                return Card(
                  child: ListTile(
                    leading: UserAvatar(name: comment['name']!),
                    title: Text(
                      comment['name']!,
                      style: const TextStyle(color: Colors.black87),
                    ),
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
