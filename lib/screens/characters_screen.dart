import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  List<dynamic> characters = [];
  bool isLoading = true;
  String? errorMessage;

  // Avatars Star Wars style (silhouettes colorées par rôle)
  // Images libres de droits - illustrations spatiales NASA
  final List<String> characterImages = [
    'https://images-assets.nasa.gov/image/PIA21474/PIA21474~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA18033/PIA18033~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA17563/PIA17563~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA21073/PIA21073~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA12235/PIA12235~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA20522/PIA20522~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA21474/PIA21474~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA18033/PIA18033~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA17563/PIA17563~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA21073/PIA21073~thumb.jpg',
  ];

  @override
  void initState() {
    super.initState();
    fetchCharacters();
  }

  Future<void> fetchCharacters() async {
    try {
      final response = await http.get(
        Uri.parse('https://swapi.tech/api/people?page=1&limit=10'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> detailed = [];
        for (var c in data['results']) {
          final r = await http.get(Uri.parse(c['url']));
          if (r.statusCode == 200) {
            detailed.add(jsonDecode(r.body)['result']['properties']);
          }
        }
        setState(() {
          characters = detailed;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur API';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Connexion impossible';
        isLoading = false;
      });
    }
  }

  Color _sideColor(String? gender) {
    if (gender == 'male') return const Color(0xFF00BFFF);
    if (gender == 'female') return const Color(0xFFFF69B4);
    return const Color(0xFF7CFC00);
  }

  String _sideLabel(String? gender) {
    if (gender == 'male') return '⚔️ Côté Clair';
    if (gender == 'female') return '🌸 Alliance';
    return '🤖 Droïde';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('HÉROS', style: TextStyle(letterSpacing: 4)),
        centerTitle: true,
      ),
      body: isLoading
          ? _loadingWidget()
          : errorMessage != null
          ? _errorWidget()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                final color = _sideColor(character['gender']);
                return _CharacterCard(
                  character: character,
                  color: color,
                  sideLabel: _sideLabel(character['gender']),
                  imageUrl: characterImages[index % characterImages.length],
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
          'Recrutement en cours...',
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

class _CharacterCard extends StatelessWidget {
  final dynamic character;
  final Color color;
  final String sideLabel;
  final String imageUrl;
  final int index;

  const _CharacterCard({
    required this.character,
    required this.color,
    required this.sideLabel,
    required this.imageUrl,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [color.withOpacity(0.08), const Color(0xFF020B18)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar photo
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(14),
            ),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  width: 110,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 110,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          color.withOpacity(0.3),
                          const Color(0xFF020B18),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.person, color: color, size: 50),
                    ),
                  ),
                ),
                // Overlay dégradé latéral
                Container(
                  width: 110,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.transparent, const Color(0xFF020B18)],
                    ),
                  ),
                ),
                // Numéro
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.9),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Infos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character['name'] ?? 'Inconnu',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Badge côté
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(
                      sideLabel,
                      style: TextStyle(color: color, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Stats en grille
                  Row(
                    children: [
                      _StatChip('🎂', character['birth_year'] ?? '?', color),
                      const SizedBox(width: 6),
                      _StatChip('📏', '${character['height']}cm', color),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StatChip('⚖️', '${character['mass']}kg', color),
                      const SizedBox(width: 6),
                      _StatChip('👁️', character['eye_color'] ?? '?', color),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _StatChip('💇', character['hair_color'] ?? '?', color),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final String value;
  final Color color;

  const _StatChip(this.emoji, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(color: color.withOpacity(0.85), fontSize: 10.5),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
