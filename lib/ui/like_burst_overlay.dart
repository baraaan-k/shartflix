import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LikeBurstOverlay extends StatefulWidget {
  const LikeBurstOverlay({super.key, required this.child});

  final Widget child;

  static LikeBurstOverlayController? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<_LikeBurstOverlayState>();
  }

  @override
  State<LikeBurstOverlay> createState() => _LikeBurstOverlayState();
}

class _LikeBurstOverlayState extends State<LikeBurstOverlay>
    with SingleTickerProviderStateMixin
    implements LikeBurstOverlayController {
  late final AnimationController _controller;
  bool _visible = false;
  bool _ready = false;
  bool _pendingPlay = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _visible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void play() {
    if (!_ready) {
      _pendingPlay = true;
      setState(() {
        _visible = true;
      });
      return;
    }
    _controller.stop();
    _controller.reset();
    setState(() {
      _visible = true;
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (!_visible) return const SizedBox.shrink();
              return Center(
                child: Opacity(
                  opacity: _ready ? 1 : 0,
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Lottie.asset(
                      'assets/lottie/like_burst.json',
                      controller: _controller,
                      repeat: false,
                      onLoaded: (composition) {
                        _controller.duration = composition.duration;
                        _ready = true;
                        if (_pendingPlay) {
                          _pendingPlay = false;
                          play();
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

abstract class LikeBurstOverlayController {
  void play();
}
