import 'package:flutter/material.dart';

// ============================================================
// ANIME MODEL
// ============================================================

class Anime {
  final String title;
  final double? score;
  final bool placeholder;
  final Color posterColor;

  const Anime({
    required this.title,
    this.score,
    this.placeholder = false,
    this.posterColor = const Color(0xFF173B70),
  });
}

// ============================================================
// DUMMY DATA
// ============================================================

// ============================================================
// ALL
// ============================================================

const List<Anime> allAnime = [
  Anime(
    title: 'That Time I Got Reincarnated as a Slime',
    score: 8.3,
    posterColor: Color(0xFF174A8B),
  ),

  Anime(
    title: 'Clevatess Season 2',
    score: 7.7,
    posterColor: Color(0xFF263F73),
  ),

  Anime(
    title: 'Mushoku Tensei Season 3',
    score: 8.4,
    posterColor: Color(0xFF173B70),
  ),

  Anime(
    title: 'Bleach: Thousand-Year Blood War',
    score: 8.8,
    posterColor: Color(0xFF234B78),
  ),

  Anime(
    title: 'Grand Blue Season 3',
    score: 7.8,
    posterColor: Color(0xFF164A66),
  ),

  Anime(title: 'Black Torch', score: 8.0, posterColor: Color(0xFF263C5C)),
];

// ============================================================
// THIS SEASON
// ============================================================

const List<Anime> thisSeasonAnime = [
  Anime(
    title: 'Clevatess Season 2',
    score: 7.7,
    posterColor: Color(0xFF263F73),
  ),

  Anime(
    title: 'That Time I Got Reincarnated as a Slime',
    score: 8.3,
    posterColor: Color(0xFF174A8B),
  ),

  Anime(
    title: 'Mushoku Tensei Season 3',
    score: 8.4,
    posterColor: Color(0xFF173B70),
  ),

  Anime(title: 'Black Torch', score: 8.0, posterColor: Color(0xFF263C5C)),

  Anime(title: 'This Season', placeholder: true),
  Anime(title: 'This Season', placeholder: true),
];

// ============================================================
// COMING SOON
// ============================================================

const List<Anime> comingSoonAnime = [
  Anime(title: 'Coming Soon', placeholder: true),

  Anime(title: 'Coming Soon', placeholder: true),

  Anime(title: 'Coming Soon', placeholder: true),

  Anime(title: 'Coming Soon', placeholder: true),

  Anime(title: 'Coming Soon', placeholder: true),

  Anime(title: 'Coming Soon', placeholder: true),
];

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Index navigation yang sedang dipilih
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070D),

      // ======================================================
      // BODY
      // ======================================================
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================
              // HEADER
              // =================================================

              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 16),

                child: Text(
                  'NimeList',

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // =================================================
              // HERO
              // =================================================
              const HeroBanner(),

              const SizedBox(height: 28),

              // =================================================
              // ALL
              // =================================================
              SectionTitle(
                title: 'All',

                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CategoryPage(title: 'All Anime'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Semua section menggunakan
              // horizontal ListView yang sama
              AnimeHorizontalList(animeList: allAnime),

              const SizedBox(height: 30),

              // =================================================
              // THIS SEASON
              // =================================================
              SectionTitle(
                title: 'This Season',

                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CategoryPage(title: 'This Season'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              AnimeHorizontalList(animeList: thisSeasonAnime),

              const SizedBox(height: 30),

              // =================================================
              // COMING SOON
              // =================================================
              SectionTitle(
                title: 'Coming Soon',

                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const CategoryPage(title: 'Coming Soon'),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              AnimeHorizontalList(animeList: comingSoonAnime),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HERO BANNER
// ============================================================

class HeroBanner extends StatefulWidget {
  const HeroBanner({super.key});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController pageController = PageController();

  int currentPage = 0;

  final List<HeroAnime> recommendations = const [
    HeroAnime(
      title: 'That Time I Got Reincarnated as a Slime',
      score: '8.3',
      genres: 'Action • Fantasy • Isekai',
      color: Color(0xFF174A8B),
    ),
    HeroAnime(
      title: 'Clevatess Season 2',
      score: '7.7',
      genres: 'Action • Fantasy',
      color: Color(0xFF263F73),
    ),
    HeroAnime(
      title: 'Mushoku Tensei Season 3',
      score: '8.4',
      genres: 'Adventure • Fantasy',
      color: Color(0xFF173B70),
    ),
    HeroAnime(
      title: 'Bleach: Thousand-Year Blood War',
      score: '8.8',
      genres: 'Action • Supernatural',
      color: Color(0xFF234B78),
    ),
    HeroAnime(
      title: 'Black Torch',
      score: '8.0',
      genres: 'Action • Supernatural',
      color: Color(0xFF263C5C),
    ),
  ];

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: pageController,
            itemCount: recommendations.length,
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final anime = recommendations[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Klik: ${anime.title}'),
                          duration: const Duration(milliseconds: 700),
                        ),
                      );
                    },

                    // Efek ketika ditekan
                    splashColor: Colors.white.withOpacity(0.30),
                    highlightColor: Colors.white.withOpacity(0.20),

                    child: Ink(
                      decoration: BoxDecoration(
                        color: anime.color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF173B70)),
                      ),
                      child: Stack(
                        children: [
                          // Informasi anime
                          Positioned(
                            left: 18,
                            right: 18,
                            bottom: 18,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Featured Anime',
                                  style: TextStyle(
                                    color: Color(0xFF60A5FA),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  anime.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  '★ ${anime.score}  •  ${anime.genres}',
                                  style: const TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // Indicator carousel
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(recommendations.length, (index) {
            final bool isActive = index == currentPage;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFF475569),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class HeroAnime {
  final String title;
  final String score;
  final String genres;
  final Color color;

  const HeroAnime({
    required this.title,
    required this.score,
    required this.genres,
    required this.color,
  });
}

// ============================================================
// SECTION TITLE
// ============================================================

class SectionTitle extends StatelessWidget {
  final String title;

  final VoidCallback onSeeAll;

  const SectionTitle({super.key, required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          // ==================================================
          // TITLE
          // ==================================================

          Text(
            title,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          // ==================================================
          // SEE MORE
          // ==================================================
          TextButton(
            onPressed: onSeeAll,

            child: const Text(
              'See More',

              style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HORIZONTAL ANIME LIST
// ============================================================

class AnimeHorizontalList extends StatelessWidget {
  final List<Anime> animeList;

  const AnimeHorizontalList({super.key, required this.animeList});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 235,

      child: ListView.builder(
        // ==================================================
        // HORIZONTAL
        // ==================================================

        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(horizontal: 20),

        itemCount: animeList.length,

        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),

            child: SizedBox(
              width: 130,

              child: AnimeCard(anime: animeList[index]),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// ANIME CARD
// ============================================================

class AnimeCard extends StatelessWidget {
  final Anime anime;

  const AnimeCard({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster anime
          Material(
            color: anime.posterColor,
            borderRadius: BorderRadius.circular(10),
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Klik: ${anime.title}'),
                    duration: const Duration(milliseconds: 700),
                  ),
                );
              },
              splashColor: Colors.white.withOpacity(0.20),
              highlightColor: Colors.white.withOpacity(0.12),
              child: Container(
                width: 130,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF173B70)),
                ),
                child: anime.placeholder
                    ? const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Color(0xFFCBD5E1),
                          size: 35,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.movie_outlined,
                          color: Color(0xFFCBD5E1),
                          size: 35,
                        ),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Judul
          Text(
            anime.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFF8FAFC),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 4),

          // Rating
          if (anime.score != null)
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFACC15), size: 14),
                const SizedBox(width: 3),
                Text(
                  anime.score!.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
// ============================================================
// CATEGORY PAGE
// ============================================================
//
// Halaman sementara untuk tombol See More.
// Nanti bisa diganti menjadi halaman yang berisi
// daftar anime lengkap menggunakan GridView.
//

class CategoryPage extends StatelessWidget {
  final String title;

  const CategoryPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070D),

      appBar: AppBar(
        backgroundColor: const Color(0xFF05070D),

        foregroundColor: Colors.white,

        title: Text(title),
      ),

      body: Center(
        child: Text(
          title,

          style: const TextStyle(
            color: Colors.white,

            fontSize: 20,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
