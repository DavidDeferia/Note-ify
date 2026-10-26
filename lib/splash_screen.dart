import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.nextScreen});

  final Widget nextScreen;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const Color _background = Color(0xFF080D18);
  static const Color _panel = Color(0xFF111E30);
  static const Color _cyan = Color(0xFF00D9FF);

  late final AnimationController _controller;
  late final AnimationController _fadeController;
  late final Animation<double> _dash;
  late final Animation<double> _progress;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _dash = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 1600 / 2400,
          curve: Curves.easeInOutCubic),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 1, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 2400), _fadeAndNavigate);
  }

  Future<void> _fadeAndNavigate() async {
    await _fadeController.forward();
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => widget.nextScreen,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: ReverseAnimation(_fadeController),
      child: Scaffold(
        backgroundColor: _background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedBuilder(
              animation: Listenable.merge([_controller, _fadeController]),
              builder: (context, _) {
                final width = constraints.maxWidth;
                final centerY = constraints.maxHeight * 0.43;
                const panelSize = 76.0;
                const startX = -panelSize;
                final endX = width + panelSize;
                final iconX = ui.lerpDouble(startX, endX, _dash.value)!;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _AmbientGlowPainter(),
                      ),
                    ),
                    Positioned(
                      left: -20 + iconX - panelSize * 0.5,
                      top: centerY - 47,
                      child: Container(
                        width: iconX + panelSize,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              _cyan.withValues(alpha: 0),
                              _cyan.withValues(alpha: 0.25),
                              _cyan,
                            ],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x9900D9FF),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: iconX - panelSize * 0.5,
                      top: centerY - panelSize * 0.5 - 18,
                      child: Container(
                        width: panelSize,
                        height: panelSize,
                        decoration: BoxDecoration(
                          color: _panel,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: _cyan.withValues(alpha: 0.85),
                            width: 1.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x6600D9FF),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: _cyan,
                          size: 46,
                          shadows: [
                            Shadow(color: Color(0xAA00D9FF), blurRadius: 12),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 32,
                      right: 32,
                      top: centerY + 80,
                      child: Column(
                        children: [
                          const Text(
                            'Simple Notepad',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your thoughts. One place.',
                            style: TextStyle(
                              color: Color(0xFF8997AD),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: SizedBox(
                              width: math.min(220, width - 64),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(2),
                                    child: SizedBox(
                                      height: 3,
                                      child: Stack(
                                        children: [
                                          Container(color: const Color(0xFF202B3D)),
                                          FractionallySizedBox(
                                            widthFactor: _progress.value.clamp(0, 1),
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: _cyan,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0xCC00D9FF),
                                                    blurRadius: 8,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text(
                                    'PREPARING YOUR NOTES',
                                    style: TextStyle(
                                      color: Color(0xFF8997AD),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 28,
                      child: Text(
                        'MADE FOR YOUR IDEAS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64738A),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.4,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AmbientGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cyanPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.92, size.height * 0.08),
        size.width * 0.45,
        [const Color(0x3300D9FF), const Color(0x0000D9FF)],
      );
    canvas.drawCircle(Offset(size.width * 0.92, size.height * 0.08),
        size.width * 0.45, cyanPaint);

    final violetPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.08, size.height * 0.82),
        size.width * 0.42,
        [const Color(0x266558FF), const Color(0x006558FF)],
      );
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.82),
        size.width * 0.42, violetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
