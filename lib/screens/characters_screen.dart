import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const arcadeBgDark = Color(0xFF070311);
const arcadeNeonCyan = Color(0xFF00F5FF);
const arcadeNeonPink = Color(0xFFFF2FAE);

class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  List<dynamic> characters = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  bool sortAscending = true;

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
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
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

  List<dynamic> get _filteredCharacters {
    final query = searchQuery.trim().toLowerCase();
    final filtered = characters.where((character) {
      final name = (character['name'] ?? '').toString().toLowerCase();
      return query.isEmpty || name.contains(query);
    }).toList();

    filtered.sort((a, b) {
      final nameA = (a['name'] ?? '').toString();
      final nameB = (b['name'] ?? '').toString();
      return sortAscending ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
    });

    return filtered;
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
        actions: [
          IconButton(
            tooltip: sortAscending ? 'Tri Z-A' : 'Tri A-Z',
            onPressed: () {
              setState(() => sortAscending = !sortAscending);
            },
            icon: Icon(
              sortAscending
                  ? Icons.sort_by_alpha
                  : Icons.sort_by_alpha_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Rafraîchir',
            onPressed: fetchCharacters,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: isLoading
          ? _loadingWidget()
          : errorMessage != null
          ? _errorWidget()
          : Column(
              children: [
                _searchBar(),
                _countBanner(_filteredCharacters.length),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchCharacters,
                    color: arcadeNeonCyan,
                    child: _filteredCharacters.isEmpty
                        ? _emptyWidget()
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                            itemCount: _filteredCharacters.length,
                            itemBuilder: (context, index) {
                              final character = _filteredCharacters[index];
                              final color = _sideColor(character['gender']);
                              return _CharacterCard(
                                character: character,
                                color: color,
                                sideLabel: _sideLabel(character['gender']),
                                imageUrl:
                                    characterImages[index %
                                        characterImages.length],
                                index: index,
                                onTap: () =>
                                    _openCharacterDetails(character, color),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _searchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
    child: TextField(
      onChanged: (value) => setState(() => searchQuery = value),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Rechercher un héros...',
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: arcadeNeonCyan),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: arcadeNeonPink),
        ),
      ),
    ),
  );

  Widget _countBanner(int count) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: arcadeNeonPink.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: arcadeNeonPink.withOpacity(0.45)),
        ),
        child: Text(
          '$count héros détecté(s)',
          style: const TextStyle(
            color: arcadeNeonCyan,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );

  Widget _emptyWidget() => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: const [
      SizedBox(height: 140),
      Center(
        child: Text(
          'Aucun héros trouvé pour cette recherche.',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    ],
  );

  Widget _loadingWidget() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            color: arcadeNeonCyan,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Chargement des fichiers holo...',
          style: TextStyle(
            color: arcadeNeonPink.withOpacity(0.9),
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
        const Icon(Icons.videogame_asset, color: arcadeNeonPink, size: 60),
        const SizedBox(height: 16),
        Text(errorMessage!, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: fetchCharacters,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
      ],
    ),
  );

  void _openCharacterDetails(dynamic character, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: arcadeBgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final lines = <MapEntry<String, String>>[
          MapEntry('Nom', (character['name'] ?? 'Inconnu').toString()),
          MapEntry('Genre', (character['gender'] ?? 'Inconnu').toString()),
          MapEntry(
            'Naissance',
            (character['birth_year'] ?? 'Inconnu').toString(),
          ),
          MapEntry('Taille', '${character['height'] ?? '?'} cm'),
          MapEntry('Poids', '${character['mass'] ?? '?'} kg'),
          MapEntry('Yeux', (character['eye_color'] ?? 'Inconnu').toString()),
          MapEntry(
            'Cheveux',
            (character['hair_color'] ?? 'Inconnu').toString(),
          ),
          MapEntry('Peau', (character['skin_color'] ?? 'Inconnu').toString()),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Archives Jedi',
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                ...lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: Text(
                            '${line.key}:',
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            line.value,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CharacterCard extends StatelessWidget {
  final dynamic character;
  final Color color;
  final String sideLabel;
  final String imageUrl;
  final int index;
  final VoidCallback onTap;

  const _CharacterCard({
    required this.character,
    required this.color,
    required this.sideLabel,
    required this.imageUrl,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [color.withOpacity(0.08), arcadeBgDark],
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
                          colors: [color.withOpacity(0.3), arcadeBgDark],
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
                        colors: [Colors.transparent, arcadeBgDark],
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
