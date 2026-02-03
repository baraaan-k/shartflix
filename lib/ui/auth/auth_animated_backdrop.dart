import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AuthAnimatedBackdrop extends StatefulWidget {
  const AuthAnimatedBackdrop({
    super.key,
    this.showPosters = true,
    this.glowCenter = const Alignment(0.0, -0.85),
    this.glowRadius = 1.35,
  });

  final bool showPosters;
  final Alignment glowCenter;
  final double glowRadius;

  @override
  State<AuthAnimatedBackdrop> createState() => _AuthAnimatedBackdropState();
}

class _AuthAnimatedBackdropState extends State<AuthAnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final top = height * 0.04;
    final posters = [
      _PosterSpec(
        asset: 'assets/branding/movie-1.png',
        top: top,
        left: width * 0.06,
        rope: 55,
        size: const Size(70, 84),
        ampDeg: 10,
        phase: 0.10,
      ),
      _PosterSpec(
        asset: 'assets/branding/movie-2.png',
        top: top,
        left: width * 0.26,
        rope: 60,
        size: const Size(74, 88),
        ampDeg: 7,
        phase: 0.42,
      ),
      _PosterSpec(
        asset: 'assets/branding/movie-3.png',
        top: top,
        left: width * 0.46,
        rope: 58,
        size: const Size(74, 88),
        ampDeg: 9,
        phase: 0.70,
      ),
      _PosterSpec(
        asset: 'assets/branding/movie-4.png',
        top: top,
        left: width * 0.66,
        rope: 65,
        size: const Size(78, 92),
        ampDeg: 6,
        phase: 0.95,
      ),
    ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.bg),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: widget.glowCenter,
                        radius: widget.glowRadius,
                        colors: [
                          AppColors.brandRed2.withValues(alpha: 0.55),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (widget.showPosters) ...[
              ...posters.map(
                (spec) => Positioned(
                  left: spec.left,
                  top: spec.top,
                  child: HangingPoster(
                    asset: spec.asset,
                    ropeLength: spec.rope,
                    size: spec.size,
                    t: t,
                    phase: spec.phase,
                    ampDeg: spec.ampDeg,
                  ),
                ),
              ),
              _SparkleDot(
                t: t,
                left: width * 0.14,
                top: height * 0.16,
                size: 4,
                phase: 0.15,
              ),
              _SparkleDot(
                t: t,
                left: width * 0.34,
                top: height * 0.16,
                size: 3,
                phase: 0.42,
              ),
              _SparkleDot(
                t: t,
                left: width * 0.54,
                top: height * 0.16,
                size: 3,
                phase: 0.68,
              ),
              _SparkleDot(
                t: t,
                left: width * 0.72,
                top: height * 0.16,
                size: 4,
                phase: 0.86,
              ),
            ],
          ],
        );
      },
    );
  }
}

class HangingPoster extends StatelessWidget {
  const HangingPoster({
    super.key,
    required this.asset,
    required this.ropeLength,
    required this.size,
    required this.t,
    required this.phase,
    required this.ampDeg,
  });

  final String asset;
  final double ropeLength;
  final Size size;
  final double t;
  final double phase;
  final double ampDeg;

  @override
  Widget build(BuildContext context) {
    final base = math.sin((t + phase) * math.pi * 2);
    final wobble = math.sin((t + phase * 1.7) * math.pi * 4) * 0.2;
    final angle = (base + wobble) * (ampDeg * math.pi / 180);
    final floatY = math.sin((t + phase) * math.pi * 2) * 2.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 2,
          height: ropeLength,
          color: Colors.white.withAlpha(60),
        ),
        Transform.translate(
          offset: Offset(0, floatY),
          child: Transform.rotate(
            alignment: Alignment.topCenter,
            angle: angle,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withAlpha(24),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Image.asset(
                  asset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SparkleDot extends StatelessWidget {
  const _SparkleDot({
    required this.t,
    required this.left,
    required this.top,
    required this.size,
    required this.phase,
  });

  final double t;
  final double left;
  final double top;
  final double size;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final alpha = (0.2 + 0.6 * (math.sin((t + phase) * math.pi * 2) * 0.5 + 0.5))
        .clamp(0.0, 1.0);
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: alpha,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(200),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withAlpha(120),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PosterSpec {
  const _PosterSpec({
    required this.asset,
    required this.top,
    required this.left,
    required this.rope,
    required this.size,
    required this.ampDeg,
    required this.phase,
  });

  final String asset;
  final double top;
  final double left;
  final double rope;
  final Size size;
  final double ampDeg;
  final double phase;
}
