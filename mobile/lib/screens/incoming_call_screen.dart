import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rescue_app/service/call_mode.dart';
import 'package:rescue_app/service/call_service.dart';

/// Full-screen incoming PTT call screen.
/// Mirrors the visual language of iOS CallKit / Samsung InCallUI.
class IncomingCallScreen extends StatefulWidget {
  final CallModel call;
  const IncomingCallScreen({super.key, required this.call});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen>
    with TickerProviderStateMixin {
  // Pulse ring animations
  late final AnimationController _pulseCtrl;
  late final AnimationController _pulseCtrl2;
  late final AnimationController _pulseCtrl3;
  late final AnimationController _fadeInCtrl;
  late final AnimationController _slideCtrl;

  // Swipe-to-answer state
  // double _swipeProgress = 0.0; // 0.0 → 1.0
  bool _answered = false;
  bool _declined = false;

  @override
  void initState() {
    super.initState();

    // Force full-screen / hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _fadeInCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseCtrl2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(
        period: const Duration(milliseconds: 1800),
      );
    // stagger second ring
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _pulseCtrl2.forward(from: 0);
    });

    _pulseCtrl3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _pulseCtrl3.forward(from: 0);
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pulseCtrl.dispose();
    _pulseCtrl2.dispose();
    _pulseCtrl3.dispose();
    _fadeInCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _accept() {
    if (_answered) return;
    setState(() => _answered = true);
    HapticFeedback.heavyImpact();
    CallService.instance.acceptCall(widget.call.callId);
  }

  void _decline() {
    if (_declined) return;
    setState(() => _declined = true);
    HapticFeedback.mediumImpact();
    CallService.instance.declineCall(widget.call.callId);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background gradient ────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF050D1A),
                    Color(0xFF091428),
                    Color(0xFF060C1C),
                  ],
                  stops: [0, 0.5, 1],
                ),
              ),
            ),

            // Grid texture overlay
            CustomPaint(
              painter: _GridPainter(),
            ),

            // ── Animated pulse rings ───────────────────────────────────────
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _PulseRing(
                    controller: _pulseCtrl,
                    maxRadius: size.width * 0.55,
                    color: const Color(0xFF00E5FF),
                  ),
                  _PulseRing(
                    controller: _pulseCtrl2,
                    maxRadius: size.width * 0.55,
                    color: const Color(0xFF00E5FF),
                  ),
                  _PulseRing(
                    controller: _pulseCtrl3,
                    maxRadius: size.width * 0.55,
                    color: const Color(0xFF00E5FF),
                  ),
                ],
              ),
            ),

            // ── Main content ───────────────────────────────────────────────
            SafeArea(
              child: FadeTransition(
                opacity: _fadeInCtrl,
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // Incoming PTT badge
                    AnimatedBuilder(
                      animation: _slideCtrl,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, (1 - _slideCtrl.value) * -30),
                        child: child,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00E5FF),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'INCOMING PTT CALL',
                              style: TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Avatar
                    AnimatedBuilder(
                      animation: _slideCtrl,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, (1 - _slideCtrl.value) * 20),
                        child: child,
                      ),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF00B4D8),
                              Color(0xFF0077B6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withOpacity(0.35),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.call.callerName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 52,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Caller name
                    Text(
                      widget.call.callerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Phone number
                    Text(
                      widget.call.callerNumber,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 17,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // PTT label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.radio_outlined,
                          color: Colors.white.withOpacity(0.4),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Push-to-Talk',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ── Action buttons ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: _CallActionBar(
                        onAccept: _accept,
                        onDecline: _decline,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Swipe hint
                    Text(
                      'or swipe up to answer',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.25),
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
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

// ── Pulse ring widget ─────────────────────────────────────────────────────────

class _PulseRing extends AnimatedWidget {
  final double maxRadius;
  final Color color;

  const _PulseRing({
    required AnimationController controller,
    required this.maxRadius,
    required this.color,
  }) : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final value = (listenable as AnimationController).value;
    final radius = maxRadius * Curves.easeOut.transform(value);
    final opacity = (1 - value) * 0.25;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(opacity),
          width: 1.5,
        ),
      ),
    );
  }
}

// ── Accept / Decline button bar ───────────────────────────────────────────────

class _CallActionBar extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _CallActionBar({
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Decline
        _CircleButton(
          onTap: onDecline,
          color: const Color(0xFFE53935),
          icon: Icons.call_end_rounded,
          label: 'Decline',
          iconColor: Colors.white,
        ),

        // Secondary actions (speaker preview)
        _CircleButton(
          onTap: () {},
          color: Colors.white.withOpacity(0.08),
          icon: Icons.volume_up_rounded,
          label: 'Speaker',
          iconColor: Colors.white.withOpacity(0.5),
          size: 56,
        ),

        // Accept
        _CircleButton(
          onTap: onAccept,
          color: const Color(0xFF00C853),
          icon: Icons.mic_rounded,
          label: 'Accept',
          iconColor: Colors.white,
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final IconData icon;
  final String label;
  final Color iconColor;
  final double size;

  const _CircleButton({
    required this.onTap,
    required this.color,
    required this.icon,
    required this.label,
    required this.iconColor,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: size * 0.44),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 12,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ── Grid background painter ───────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.025)
      ..strokeWidth = 0.5;

    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Radial gradient overlay
    final center = Offset(size.width / 2, size.height * 0.4);
    final gradient = RadialGradient(
      colors: [
        const Color(0xFF00E5FF).withOpacity(0.04),
        Colors.transparent,
      ],
      radius: 0.7,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.7),
        ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
