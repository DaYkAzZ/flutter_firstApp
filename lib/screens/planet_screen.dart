import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const arcadeBgDark = Color(0xFF070311);
const arcadeNeonCyan = Color(0xFF00F5FF);
const arcadeNeonPink = Color(0xFFFF2FAE);

class PlanetScreen extends StatefulWidget {
  const PlanetScreen({super.key});

  @override
  State<PlanetScreen> createState() => _PlanetScreenState();
}

class _PlanetScreenState extends State<PlanetScreen> {
  List<dynamic> planets = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  bool showGrid = true;

  // Images NASA domaine public pour représenter les planètes
  final List<String> planetImages = [
    'https://images-assets.nasa.gov/image/PIA18033/PIA18033~thumb.jpg', // désert
    'https://images-assets.nasa.gov/image/PIA21073/PIA21073~thumb.jpg', // glace
    'https://images-assets.nasa.gov/image/PIA17563/PIA17563~thumb.jpg', // gaz
    'https://images-assets.nasa.gov/image/PIA12235/PIA12235~thumb.jpg', // volcans
    'https://images-assets.nasa.gov/image/PIA20522/PIA20522~thumb.jpg', // océan
    'https://images-assets.nasa.gov/image/PIA21474/PIA21474~thumb.jpg', // forêt
    'https://images-assets.nasa.gov/image/PIA18033/PIA18033~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA17563/PIA17563~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA21073/PIA21073~thumb.jpg',
    'https://images-assets.nasa.gov/image/PIA20522/PIA20522~thumb.jpg',
  ];

  final List<Color> planetColors = [
    const Color(0xFFD2691E),
    const Color(0xFF87CEEB),
    const Color(0xFFFF8C00),
    const Color(0xFFDC143C),
    const Color(0xFF00CED1),
    const Color(0xFF228B22),
    const Color(0xFFDA70D6),
    const Color(0xFFFFD700),
    const Color(0xFF4169E1),
    const Color(0xFFFF6347),
  ];

  @override
  void initState() {
    super.initState();
    fetchPlanets();
  }

  Future<void> fetchPlanets() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http.get(
        Uri.parse('https://swapi.tech/api/planets?page=1&limit=10'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> detailed = [];
        for (var p in data['results']) {
          final r = await http.get(Uri.parse(p['url']));
          if (r.statusCode == 200) {
            detailed.add(jsonDecode(r.body)['result']['properties']);
          }
        }
        setState(() {
          planets = detailed;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('PLANÈTES', style: TextStyle(letterSpacing: 4)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: showGrid ? 'Mode liste' : 'Mode grille',
            onPressed: () => setState(() => showGrid = !showGrid),
            icon: Icon(showGrid ? Icons.view_list : Icons.grid_view),
          ),
          IconButton(
            tooltip: 'Rafraîchir',
            onPressed: fetchPlanets,
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
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchPlanets,
                    color: arcadeNeonCyan,
                    child: showGrid ? _buildGrid() : _buildList(),
                  ),
                ),
              ],
            ),
    );
  }

  List<dynamic> get _filteredPlanets {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return planets;
    return planets.where((planet) {
      final name = (planet['name'] ?? '').toString().toLowerCase();
      final climate = (planet['climate'] ?? '').toString().toLowerCase();
      return name.contains(query) || climate.contains(query);
    }).toList();
  }

  Widget _searchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: TextField(
      onChanged: (value) => setState(() => searchQuery = value),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Rechercher une planète (nom, climat)...',
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

  Widget _buildGrid() => _filteredPlanets.isEmpty
      ? _emptyWidget()
      : GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _filteredPlanets.length,
          itemBuilder: (context, index) {
            return _PlanetCard(
              planet: _filteredPlanets[index],
              color: planetColors[index % planetColors.length],
              imageUrl: planetImages[index % planetImages.length],
            );
          },
        );

  Widget _buildList() => _filteredPlanets.isEmpty
      ? _emptyWidget()
      : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          itemCount: _filteredPlanets.length,
          itemBuilder: (context, index) {
            final planet = _filteredPlanets[index];
            final color = planetColors[index % planetColors.length];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.public, color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      planet['name'] ?? 'Inconnu',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    (planet['climate'] ?? '?').toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            );
          },
        );

  Widget _emptyWidget() => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: const [
      SizedBox(height: 140),
      Center(
        child: Text(
          'Aucune planète ne correspond à votre recherche.',
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
          'Scan des secteurs en cours...',
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
          onPressed: fetchPlanets,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
        ),
      ],
    ),
  );
}

class _PlanetCard extends StatelessWidget {
  final dynamic planet;
  final Color color;
  final String imageUrl;

  const _PlanetCard({
    required this.planet,
    required this.color,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.1), arcadeBgDark],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image planète
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: Stack(
              children: [
                Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.4), arcadeBgDark],
                      ),
                    ),
                    child: Center(
                      child: Icon(Icons.public, color: color, size: 50),
                    ),
                  ),
                ),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, arcadeBgDark],
                    ),
                  ),
                ),
                // Effet "planète" cercle coloré
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.3),
                      border: Border.all(color: color, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.6),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Nom
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
            child: Text(
              planet['name'] ?? 'Inconnu',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Stats
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow('🌡️', planet['climate']),
                  _StatRow('🌍', planet['terrain']),
                  _StatRow('👥', planet['population']),
                  _StatRow('💧', '${planet['surface_water']}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String emoji;
  final String? value;

  const _StatRow(this.emoji, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value ?? 'Inconnu',
              style: const TextStyle(color: Colors.white60, fontSize: 10.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
