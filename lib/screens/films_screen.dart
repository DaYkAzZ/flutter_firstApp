import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FilmsScreen extends StatefulWidget {
  const FilmsScreen({super.key});

  @override
  State<FilmsScreen> createState() => _FilmsScreenState();
}

class _FilmsScreenState extends State<FilmsScreen> {
  List<dynamic> films = [];
  bool isLoading = true;
  String? errorMessage;

  // Affiches libres de droits / fan art depuis Wikimedia ou images spatiales
  final List<String> posterUrls = [
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Star_Wars_Logo.svg/600px-Star_Wars_Logo.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Star_Wars_Logo.svg/600px-Star_Wars_Logo.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Star_Wars_Logo.svg/600px-Star_Wars_Logo.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Star_Wars_Logo.svg/600px-Star_Wars_Logo.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Star_Wars_Logo.svg/600px-Star_Wars_Logo.svg.png',
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Star_Wars_Logo.svg/600px-Star_Wars_Logo.svg.png',
  ];

  // Images spatiales NASA (domaine public) pour illustrer chaque film
  final List<String> spaceImages = [
    'https://images-assets.nasa.gov/image/PIA12235/PIA12235~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA17563/PIA17563~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA21073/PIA21073~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA18033/PIA18033~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA21474/PIA21474~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA20522/PIA20522~thumb.jpg',
  ];

  final List<Color> episodeColors = [
    const Color(0xFFFFE81F),
    const Color(0xFF00BFFF),
    const Color(0xFFFF4500),
    const Color(0xFF7CFC00),
    const Color(0xFFFF69B4),
    const Color(0xFF9370DB),
  ];

  @override
  void initState() {
    super.initState();
    fetchFilms();
  }

  Future<void> fetchFilms() async {
    try {
      final response = await http.get(Uri.parse('https://swapi.tech/api/films'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sorted = List.from(data['result'])
          ..sort((a, b) =>
              a['properties']['episode_id'].compareTo(b['properties']['episode_id']));
        setState(() {
          films = sorted;
          isLoading = false;
        });
      } else {
        setState(() { errorMessage = 'Erreur API'; isLoading = false; });
      }
    } catch (e) {
      setState(() { errorMessage = 'Connexion impossible'; isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/Star_Wars_Logo.svg/200px-Star_Wars_Logo.svg.png',
              height: 30,
              errorBuilder: (_, __, ___) => const Icon(Icons.star, color: Color(0xFFFFE81F)),
            ),
            const SizedBox(width: 10),
            const Text('FILMS', style: TextStyle(letterSpacing: 4)),
          ],
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? _loadingWidget()
          : errorMessage != null
              ? _errorWidget()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                  itemCount: films.length,
                  itemBuilder: (context, index) {
                    final film = films[index]['properties'];
                    final color = episodeColors[index % episodeColors.length];
                    final imgIndex = index % spaceImages.length;
                    return _FilmCard(
                      film: film,
                      color: color,
                      imageUrl: spaceImages[imgIndex],
                      index: index,
                    );
                  },
                ),
    );
  }

  Widget _loadingWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: Color(0xFFFFE81F),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Que la Force soit avec toi...',
              style: TextStyle(
                color: const Color(0xFFFFE81F).withOpacity(0.8),
                fontSize: 16,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );

  Widget _errorWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber, color: Color(0xFFFFE81F), size: 60),
            const SizedBox(height: 16),
            Text(errorMessage!, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
}

class _FilmCard extends StatelessWidget {
  final dynamic film;
  final Color color;
  final String imageUrl;
  final int index;

  const _FilmCard({
    required this.film,
    required this.color,
    required this.imageUrl,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.08),
            const Color(0xFF020B18).withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de fond spatiale
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.3), const Color(0xFF020B18)],
                      ),
                    ),
                    child: const Center(child: Icon(Icons.stars, color: Colors.white30, size: 60)),
                  ),
                ),
                // Dégradé overlay
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0xFF020B18).withOpacity(0.9),
                      ],
                    ),
                  ),
                ),
                // Badge épisode
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ÉPISODE ${film['episode_id']}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                // Titre en bas de l'image
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Text(
                    film['title'].toString().toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(color: color.withOpacity(0.8), blurRadius: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Infos
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Badge(Icons.calendar_today, film['release_date'] ?? '', color),
                    const SizedBox(width: 8),
                    _Badge(Icons.movie, film['director'] ?? '', color),
                  ],
                ),
                const SizedBox(height: 12),
                // Opening crawl
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    film['opening_crawl'] ?? '',
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontStyle: FontStyle.italic,
                      fontSize: 12.5,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Badge(this.icon, this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color.withOpacity(0.9), fontSize: 11)),
        ],
      ),
    );
  }
}
