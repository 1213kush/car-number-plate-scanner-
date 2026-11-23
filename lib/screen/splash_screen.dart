import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // --- Controllers ---
  late AnimationController _logoController;
  late AnimationController _contentController;
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _progressController;

  // --- Logo animations ---
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotate;

  // --- Content animations ---
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _badgeOpacity;
  late Animation<Offset> _badgeSlide;
  late Animation<double> _footerOpacity;

  // --- Scan line ---
  late Animation<double> _scanPosition;

  // --- Pulse ring ---
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // --- Progress ---
  late Animation<double> _progressValue;

  static const _cyan = Color(0xFF00E5FF);
  static const _cyanDim = Color(0x3300E5FF);
  static const _cyanGlow = Color(0x6600E5FF);
  static const _white = Colors.white;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _scheduleNavigation();
  }

  void _setupAnimations() {
    // Logo: scale + fade + subtle rotate
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    ).drive(Tween(begin: 0.4, end: 1.0));
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ).drive(Tween(begin: 0.0, end: 1.0));
    _logoRotate = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: -0.08, end: 0.0));

    // Content: staggered fade + slide
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _titleOpacity = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));
    _titleSlide = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
    ).drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero));
    _badgeOpacity = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));
    _badgeSlide = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ).drive(Tween(begin: const Offset(0, 0.4), end: Offset.zero));
    _footerOpacity = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ).drive(Tween(begin: 0.0, end: 1.0));

    // Scan line sweeps over logo
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _scanPosition = CurvedAnimation(
      parent: _scanController,
      curve: Curves.easeInOut,
    ).drive(Tween(begin: 0.0, end: 1.0));

    // Pulse ring breathes continuously
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseScale = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ).drive(Tween(begin: 1.0, end: 1.18));
    _pulseOpacity = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ).drive(Tween(begin: 0.5, end: 0.15));

    // Progress bar fills over 2 seconds
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _progressValue = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ).drive(Tween(begin: 0.0, end: 1.0));

    // Sequence: logo → scan → content + progress
    _logoController.forward().then((_) {
      _scanController.forward().then((_) {
        _contentController.forward();
        _progressController.forward();
      });
    });
  }

  void _scheduleNavigation() {
    Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _contentController.dispose();
    _scanController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080E14),
      body: Stack(
        children: [
          // ── Background mesh gradient ──
          _buildBackground(),

          // ── Main content ──
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                _buildLogo(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 14),
                _buildBadge(),
                const Spacer(flex: 3),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  Background
  // ─────────────────────────────────────────
  Widget _buildBackground() {
    return Stack(
      children: [
        // Deep base
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3),
              radius: 1.4,
              colors: [
                Color(0xFF0D1E2E),
                Color(0xFF080E14),
              ],
            ),
          ),
        ),
        // Subtle top-left accent glow
        Positioned(
          top: -120,
          left: -120,
          child: Container(
            width: 400,
            height: 400,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x1500E5FF), Color(0x00000000)],
              ),
            ),
          ),
        ),
        // Bottom-right accent glow
        Positioned(
          bottom: -100,
          right: -100,
          child: Container(
            width: 320,
            height: 320,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x0D00E5FF), Color(0x00000000)],
              ),
            ),
          ),
        ),
        // Fine grid lines (purely decorative)
        CustomPaint(
          size: Size.infinite,
          painter: _GridPainter(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  //  Logo
  // ─────────────────────────────────────────
  Widget _buildLogo() {
    const logoSize = 112.0;
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoController,
        _scanController,
        _pulseController,
      ]),
      builder: (context, _) {
        return Transform.rotate(
          angle: _logoRotate.value,
          child: Transform.scale(
            scale: _logoScale.value,
            child: Opacity(
              opacity: _logoOpacity.value,
              child: SizedBox(
                width: logoSize + 60,
                height: logoSize + 60,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulse ring
                    Transform.scale(
                      scale: _pulseScale.value,
                      child: Container(
                        width: logoSize + 40,
                        height: logoSize + 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _cyan.withOpacity(_pulseOpacity.value),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    // Dashed orbit ring (static)
                    CustomPaint(
                      size: const Size(logoSize + 24, logoSize + 24),
                      painter: _DashedCirclePainter(
                        color: _cyanDim,
                        dashCount: 24,
                      ),
                    ),

                    // Glass disc
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF162638),
                            Color(0xFF0C1A28),
                          ],
                        ),
                        border: Border.all(
                          color: const Color(0x5500E5FF),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _cyanGlow,
                            blurRadius: 36,
                            spreadRadius: 2,
                          ),
                          const BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Icon
                            const Icon(
                              Icons.directions_car_filled_rounded,
                              size: 48,
                              color: _cyan,
                            ),

                            // Scan line sweep
                            Positioned(
                              top: _scanPosition.value * logoSize,
                              left: 0,
                              right: 0,
                              child: Opacity(
                                opacity: (1.0 - (_scanPosition.value - 0.5).abs() * 2).clamp(0.0, 1.0),
                                child: Container(
                                  height: 2,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        _cyan,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Gloss sheen
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: logoSize * 0.4,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0x1AFFFFFF),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────
  //  Title
  // ─────────────────────────────────────────
  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, _) {
        return FadeTransition(
          opacity: _titleOpacity,
          child: SlideTransition(
            position: _titleSlide,
            child: Column(
              children: [
                // Wordmark
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'VEHICLE',
                      style: TextStyle(
                        color: _white.withOpacity(0.95),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 6,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _cyanDim,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: _cyanGlow, width: 1),
                      ),
                      child: const Text(
                        'OCR',
                        style: TextStyle(
                          color: _cyan,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tagline
                Text(
                  'AI License Plate Recognition',
                  style: TextStyle(
                    color: _white.withOpacity(0.42),
                    fontSize: 12.5,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────
  //  Badge chips
  // ─────────────────────────────────────────
  Widget _buildBadge() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, _) {
        return FadeTransition(
          opacity: _badgeOpacity,
          child: SlideTransition(
            position: _badgeSlide,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _chip(Icons.flash_on_rounded, 'Real-time'),
                const SizedBox(width: 10),
                _chip(Icons.security_rounded, 'Secure'),
                const SizedBox(width: 10),
                _chip(Icons.layers_rounded, 'ML Kit'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x2200E5FF), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _cyan.withOpacity(0.7)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: _white.withOpacity(0.55),
              fontSize: 11,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  Footer: progress + version
  // ─────────────────────────────────────────
  Widget _buildFooter() {
    return AnimatedBuilder(
      animation: Listenable.merge([_contentController, _progressController]),
      builder: (context, _) {
        return FadeTransition(
          opacity: _footerOpacity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
            child: Column(
              children: [
                // Progress track
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(
                      value: _progressValue.value,
                      backgroundColor: const Color(0x1AFFFFFF),
                      valueColor: const AlwaysStoppedAnimation<Color>(_cyan),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Version row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: _white.withOpacity(0.22),
                        fontSize: 10.5,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      'Powered by Google ML Kit',
                      style: TextStyle(
                        color: _white.withOpacity(0.22),
                        fontSize: 10.5,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────
//  Custom Painters
// ─────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x06FFFFFF)
      ..strokeWidth = 0.5;

    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final int dashCount;

  const _DashedCirclePainter({required this.color, required this.dashCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final dashAngle = (2 * math.pi) / dashCount;
    final gapFraction = 0.4;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) =>
      old.color != color || old.dashCount != dashCount;
}