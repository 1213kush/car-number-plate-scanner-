import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────────────
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _particleCtrl;
  late final AnimationController _progressCtrl;

  // ── Logo animations ───────────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoRotate;

  // ── Text animations ───────────────────────────────────────────────────────
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineFade;

  // ── Ring pulse ────────────────────────────────────────────────────────────
  late final Animation<double> _ringScale;
  late final Animation<double> _ringOpacity;

  // ── Progress ──────────────────────────────────────────────────────────────
  late final Animation<double> _progress;

  // ── Status text ───────────────────────────────────────────────────────────
  final _statusNotifier = ValueNotifier<String>('Initializing...');
  final _statusMessages = [
    'Initializing scanner...',
    'Loading OCR engine...',
    'Calibrating detector...',
    'Ready!',
  ];

  // ── Particles ─────────────────────────────────────────────────────────────
  final _particles = <_Particle>[];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _buildParticles();
    _setupAnimations();
    _startStatusCycle();
    _navigate();
  }

  void _buildParticles() {
    for (int i = 0; i < 18; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        radius: _rng.nextDouble() * 2.5 + 0.8,
        speed: _rng.nextDouble() * 0.4 + 0.2,
        phase: _rng.nextDouble() * pi * 2,
      ));
    }
  }

  void _setupAnimations() {
    // Logo: scale + fade + slight rotate
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));
    _logoRotate = Tween<double>(begin: -0.15, end: 0.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic));

    // Ring pulse (loops)
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _ringScale = Tween<double>(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
    _ringOpacity = Tween<double>(begin: 0.5, end: 0.0).animate(
        CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));

    // Particles (loops)
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();

    // Text slides up
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _titleSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _textCtrl,
            curve: const Interval(0.4, 1.0, curve: Curves.easeIn)));

    // Progress bar over 3s
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut));

    // Start sequence
    _logoCtrl.forward().then((_) => _textCtrl.forward());
    _progressCtrl.forward();
  }

  void _startStatusCycle() {
    int idx = 0;
    Timer.periodic(const Duration(milliseconds: 750), (t) {
      if (!mounted) { t.cancel(); return; }
      if (idx < _statusMessages.length) {
        _statusNotifier.value = _statusMessages[idx++];
      } else {
        t.cancel();
      }
    });
  }

  void _navigate() {
    Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
            child: child,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _ringCtrl.dispose();
    _particleCtrl.dispose();
    _progressCtrl.dispose();
    _statusNotifier.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF060818),
              Color(0xFF0D1B2A),
              Color(0xFF0A1628),
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Floating particles ───────────────────────────────────────
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _ParticlePainter(
                    _particles, _particleCtrl.value),
              ),
            ),

            // ── Ambient glow behind logo ─────────────────────────────────
            Positioned(
              left: size.width / 2 - 110,
              top: size.height * 0.28,
              child: AnimatedBuilder(
                animation: _logoCtrl,
                builder: (_, __) => Opacity(
                  opacity: _logoFade.value * 0.35,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0xFF1E88E5), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Main content ─────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // ── Logo + ring ────────────────────────────────────────
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_logoCtrl, _ringCtrl]),
                    builder: (_, __) {
                      return SizedBox(
                        width: 160,
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pulsing outer ring
                            Opacity(
                              opacity: _ringOpacity.value,
                              child: Transform.scale(
                                scale: _ringScale.value,
                                child: Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF1E88E5),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Logo container
                            Opacity(
                              opacity: _logoFade.value,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: Transform.rotate(
                                  angle: _logoRotate.value,
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF0D1B2A),
                                      border: Border.all(
                                        color: const Color(0xFF1E88E5),
                                        width: 2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x551E88E5),
                                          blurRadius: 30,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.directions_car_rounded,
                                      size: 52,
                                      color: Color(0xFF1E88E5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // ── Title & tagline ────────────────────────────────────
                  AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Column(
                          children: [
                            // Brand name
                            RichText(
                              text: const TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'VEHICLE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 5,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' OCR',
                                    style: TextStyle(
                                      color: Color(0xFF1E88E5),
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Divider line
                            Container(
                              width: 48,
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E88E5),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Tagline
                            FadeTransition(
                              opacity: _taglineFade,
                              child: const Text(
                                'AI-Powered License Plate Recognition',
                                style: TextStyle(
                                  color: Color(0xFF8099B4),
                                  fontSize: 13,
                                  letterSpacing: 0.6,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Progress + status ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48)
                        .copyWith(bottom: 48),
                    child: Column(
                      children: [
                        // Status text
                        ValueListenableBuilder<String>(
                          valueListenable: _statusNotifier,
                          builder: (_, status, __) => AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              status,
                              key: ValueKey(status),
                              style: const TextStyle(
                                color: Color(0xFF4A6080),
                                fontSize: 12,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Progress bar
                        AnimatedBuilder(
                          animation: _progress,
                          builder: (_, __) => ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progress.value,
                              minHeight: 3,
                              backgroundColor: const Color(0xFF1A2A3A),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1E88E5)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Version badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1B2A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFF1A2A3A)),
                          ),
                          child: const Text(
                            'v1.0.0  •  Powered by ML Kit',
                            style: TextStyle(
                              color: Color(0xFF3A5068),
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Particle data model ───────────────────────────────────────────────────────
class _Particle {
  final double x, y, radius, speed, phase;
  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
  });
}

// ── Particle painter ──────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double t;
  _ParticlePainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final dy = (t * p.speed) % 1.0;
      final y  = (p.y - dy + 1.0) % 1.0;
      final opacity = (sin(t * pi * 2 + p.phase) * 0.5 + 0.5) * 0.4 + 0.05;
      paint.color = const Color(0xFF1E88E5).withOpacity(opacity);
      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}