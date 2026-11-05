import 'models/anime.dart';

// Favorit disimpan di memori selama aplikasi berjalan.
final List<Anime> myAnimeList = [
  const Anime(
    id: 52991,
    title: 'Frieren',
    score: 9.1,
    status: 'Finished Airing',
  ),
  const Anime(
    id: 21,
    title: 'One Piece',
    score: 8.7,
    status: 'Currently Airing',
  ),
];
