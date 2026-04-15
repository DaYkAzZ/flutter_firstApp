import 'package:flutter/material.dart';
import 'screens/films_screen.dart';
import 'screens/planet_screen.dart';
import 'screens/characters_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star Wars',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020B18),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFFFFE81F),
          titleTextStyle: TextStyle(
            color: Color(0xFFFFE81F),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    FilmsScreen(),
    PlanetScreen(),
    CharactersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond étoilé global
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 2.0,
                colors: [Color(0xFF0D1B3E), Color(0xFF020B18)],
              ),
            ),
          ),
          // Étoiles
          const StarfieldBackground(),
          // Contenu
          _screens[_selectedIndex],
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF020B18),
          border: const Border(
            top: BorderSide(color: Color(0xFFFFE81F), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFE81F).withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFFFFE81F),
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
          elevation: 0,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter_outlined),
              activeIcon: Icon(Icons.movie_filter, size: 28),
              label: 'FILMS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.public_outlined),
              activeIcon: Icon(Icons.public, size: 28),
              label: 'PLANÈTES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, size: 28),
              label: 'HÉROS',
            ),
          ],
        ),
      ),
    );
  }
}

// Widget d'étoiles en fond
class StarfieldBackground extends StatelessWidget {
  const StarfieldBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: StarPainter(), size: Size.infinite);
  }
}

class StarPainter extends CustomPainter {
  final List<Offset> stars = const [
    Offset(0.05, 0.02),
    Offset(0.15, 0.08),
    Offset(0.25, 0.03),
    Offset(0.35, 0.11),
    Offset(0.45, 0.05),
    Offset(0.55, 0.09),
    Offset(0.65, 0.01),
    Offset(0.75, 0.07),
    Offset(0.85, 0.04),
    Offset(0.95, 0.12),
    Offset(0.08, 0.18),
    Offset(0.18, 0.22),
    Offset(0.28, 0.16),
    Offset(0.38, 0.25),
    Offset(0.48, 0.19),
    Offset(0.58, 0.23),
    Offset(0.68, 0.15),
    Offset(0.78, 0.21),
    Offset(0.88, 0.17),
    Offset(0.98, 0.28),
    Offset(0.03, 0.35),
    Offset(0.13, 0.42),
    Offset(0.23, 0.38),
    Offset(0.33, 0.45),
    Offset(0.43, 0.39),
    Offset(0.53, 0.43),
    Offset(0.63, 0.36),
    Offset(0.73, 0.41),
    Offset(0.83, 0.37),
    Offset(0.93, 0.48),
    Offset(0.07, 0.55),
    Offset(0.17, 0.62),
    Offset(0.27, 0.58),
    Offset(0.37, 0.65),
    Offset(0.47, 0.59),
    Offset(0.57, 0.63),
    Offset(0.67, 0.56),
    Offset(0.77, 0.61),
    Offset(0.87, 0.57),
    Offset(0.97, 0.68),
    Offset(0.02, 0.75),
    Offset(0.12, 0.82),
    Offset(0.22, 0.78),
    Offset(0.32, 0.85),
    Offset(0.42, 0.79),
    Offset(0.52, 0.83),
    Offset(0.62, 0.76),
    Offset(0.72, 0.81),
    Offset(0.82, 0.77),
    Offset(0.92, 0.88),
    Offset(0.10, 0.93),
    Offset(0.30, 0.96),
    Offset(0.50, 0.91),
    Offset(0.70, 0.95),
    Offset(0.90, 0.92),
    Offset(0.20, 0.32),
    Offset(0.60, 0.72),
    Offset(0.40, 0.52),
    Offset(0.80, 0.29),
    Offset(0.11, 0.69),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (int i = 0; i < stars.length; i++) {
      final star = stars[i];
      final radius = (i % 3 == 0)
          ? 1.5
          : (i % 3 == 1)
          ? 1.0
          : 0.7;
      final opacity = (i % 5 == 0)
          ? 0.9
          : (i % 5 == 1)
          ? 0.6
          : 0.4;
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        radius,
        paint..color = Colors.white.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
