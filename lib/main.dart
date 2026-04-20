import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'screens/films_screen.dart';
import 'screens/planet_screen.dart';
import 'screens/characters_screen.dart';

const arcadeBgDark = Color(0xFF070311);
const arcadeBgMid = Color(0xFF130A2B);
const arcadeNeonCyan = Color(0xFF00F5FF);
const arcadeNeonPink = Color(0xFFFF2FAE);

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
        scaffoldBackgroundColor: arcadeBgDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: arcadeNeonCyan,
          brightness: Brightness.dark,
        ).copyWith(primary: arcadeNeonCyan, secondary: arcadeNeonPink),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: arcadeNeonPink,
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: arcadeNeonCyan,
          titleTextStyle: TextStyle(
            color: arcadeNeonCyan,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 3.2,
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

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _spaceFxController;
  late final AnimationController _jumpController;
  bool _showHyperspace = false;

  final List<Widget> _screens = const [
    FilmsScreen(),
    PlanetScreen(),
    CharactersScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _spaceFxController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _spaceFxController.dispose();
    _jumpController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
      _showHyperspace = true;
    });
    _jumpController.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      setState(() => _showHyperspace = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond étoilé global
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.65,
                colors: [Color(0xFF271157), Color(0xFF120825), arcadeBgDark],
              ),
            ),
          ),
          // Étoiles
          AnimatedBuilder(
            animation: _spaceFxController,
            builder: (context, child) {
              return StarfieldBackground(t: _spaceFxController.value);
            },
          ),
          AnimatedBuilder(
            animation: _spaceFxController,
            builder: (context, child) {
              return ScanlineOverlay(t: _spaceFxController.value);
            },
          ),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    arcadeNeonPink.withOpacity(0.08),
                    Colors.transparent,
                    arcadeNeonCyan.withOpacity(0.08),
                  ],
                ),
              ),
            ),
          ),
          if (_showHyperspace)
            AnimatedBuilder(
              animation: _jumpController,
              builder: (context, child) {
                return HyperspaceFlash(progress: _jumpController.value);
              },
            ),
          // Contenu
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final fade = CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              );
              final slide = Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(fade);
              return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOpeningCrawl(context),
        backgroundColor: arcadeNeonPink,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('OPENING CRAWL'),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: arcadeBgDark.withOpacity(0.95),
          border: Border(
            top: BorderSide(color: arcadeNeonPink.withOpacity(0.8), width: 1.1),
          ),
          boxShadow: [
            BoxShadow(
              color: arcadeNeonPink.withOpacity(0.2),
              blurRadius: 14,
              spreadRadius: 1.5,
            ),
            BoxShadow(color: arcadeNeonCyan.withOpacity(0.16), blurRadius: 22),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: Colors.transparent,
          selectedItemColor: arcadeNeonCyan,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
          elevation: 0,
          onTap: _onTabTap,
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

  void _showOpeningCrawl(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _OpeningCrawlSheet(),
    );
  }
}

// Widget d'étoiles en fond
class StarfieldBackground extends StatelessWidget {
  final double t;
  const StarfieldBackground({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: StarPainter(t), size: Size.infinite);
  }
}

class StarPainter extends CustomPainter {
  final double t;
  StarPainter(this.t);

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
      final twinkle = 0.65 + 0.35 * math.sin((t * 2 * math.pi) + i * 0.55);
      final animatedOpacity = (opacity * twinkle).clamp(0.2, 1.0);
      final flickerColor = (i % 4 == 0)
          ? arcadeNeonCyan.withOpacity(animatedOpacity)
          : (i % 4 == 1)
          ? arcadeNeonPink.withOpacity(animatedOpacity * 0.85)
          : Colors.white.withOpacity(animatedOpacity);
      canvas.drawCircle(
        Offset(star.dx * size.width, star.dy * size.height),
        radius,
        paint..color = flickerColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => oldDelegate.t != t;
}

class ScanlineOverlay extends StatelessWidget {
  final double t;
  const ScanlineOverlay({super.key, required this.t});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: ScanlinePainter(t), size: Size.infinite),
    );
  }
}

class ScanlinePainter extends CustomPainter {
  final double t;
  ScanlinePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()..color = Colors.white.withOpacity(0.03);
    final offset = (t * 6) % 4;
    for (double y = -4 + offset; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ScanlinePainter oldDelegate) =>
      oldDelegate.t != t;
}

class HyperspaceFlash extends StatelessWidget {
  final double progress;
  const HyperspaceFlash({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final opacity = (1 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0);
    return IgnorePointer(
      child: Opacity(
        opacity: opacity * 0.45,
        child: CustomPaint(
          painter: _HyperspacePainter(progress),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _HyperspacePainter extends CustomPainter {
  final double progress;
  _HyperspacePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          arcadeNeonCyan.withOpacity(0.8),
          arcadeNeonPink.withOpacity(0.55),
          Colors.white.withOpacity(0.9),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final lineCount = 35;
    for (int i = 0; i < lineCount; i++) {
      final angle = (i / lineCount) * math.pi * 2;
      final dir = Offset(math.cos(angle), math.sin(angle));
      final start = center + dir * (25 + 30 * progress);
      final end = center + dir * (size.longestSide * (0.5 + progress));
      canvas.drawLine(start, end, paint..strokeWidth = 1 + (2.2 * progress));
    }
  }

  @override
  bool shouldRepaint(covariant _HyperspacePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _OpeningCrawlSheet extends StatefulWidget {
  const _OpeningCrawlSheet();

  @override
  State<_OpeningCrawlSheet> createState() => _OpeningCrawlSheetState();
}

class _OpeningCrawlSheetState extends State<_OpeningCrawlSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _crawlController;

  @override
  void initState() {
    super.initState();
    _crawlController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _crawlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: arcadeBgDark.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border.all(color: arcadeNeonCyan.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(color: arcadeNeonPink.withOpacity(0.3), blurRadius: 18),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _crawlController,
                builder: (context, child) {
                  final y = 1.2 - (_crawlController.value * 1.9);
                  return Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0016)
                      ..rotateX(-0.72),
                    child: FractionalTranslation(
                      translation: Offset(0, y),
                      child: child,
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'EPISODE TP\n'
                    'LA MONTEE EN PUISSANCE\n\n'
                    'Un jeune Padawan du code transforme son application '
                    'en une borne arcade intergalactique.\n\n'
                    'Animations, neon et hyperespace ont ete ajoutes '
                    'pour impressionner le Conseil Jedi.\n\n'
                    'Mais ce n est que le debut...\n'
                    'D autres fonctionnalites epiques approchent.\n',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: arcadeNeonCyan),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
