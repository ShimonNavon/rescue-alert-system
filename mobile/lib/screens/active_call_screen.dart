import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rescue_app/service/call_mode.dart';
import 'package:rescue_app/service/call_service.dart';
// import 'package:ptt_call/models/call_model.dart';
// import 'package:ptt_call/services/call_service.dart';
// import 'package:ptt_call/services/call_provider.dart';

/// Active PTT call screen.
/// Shows the large PTT (walkie-talkie) button, mute, speaker, end call.
class ActiveCallScreen extends ConsumerStatefulWidget {
  final CallModel call;
  const ActiveCallScreen({super.key, required this.call});

  @override
  ConsumerState<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends ConsumerState<ActiveCallScreen>
    with TickerProviderStateMixin {
  late CallModel _call;
  Timer? _durationTimer;
  Duration _elapsed = Duration.zero;

  // PTT press animation
  late final AnimationController _pttPressCtrl;
  late final AnimationController _pttPulseCtrl;
  late final AnimationController _receiveCtrl;

  bool _isTransmitting = false;

  @override
  void initState() {
    super.initState();
    _call = widget.call;

    _pttPressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _pttPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _receiveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (_call.state == CallState.active) {
      _startTimer();
    }

    CallService.instance.callStateStream.listen((call) {
      if (!mounted) return;
      if (call == null) return;
      setState(() => _call = call);

      if (call.state == CallState.active && _durationTimer == null) {
        _startTimer();
      }

      if (call.pttState == PttState.receiving) {
        _receiveCtrl.repeat(reverse: true);
      } else {
        _receiveCtrl.stop();
        _receiveCtrl.value = 0;
      }
    });
  }

  void _startTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  String get _elapsedLabel {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (_elapsed.inHours > 0) {
      return '${_elapsed.inHours}:$m:$s';
    }
    return '$m:$s';
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _pttPressCtrl.dispose();
    _pttPulseCtrl.dispose();
    _receiveCtrl.dispose();
    super.dispose();
  }

  void _onPttDown() {
    if (_isTransmitting) return;
    setState(() => _isTransmitting = true);
    HapticFeedback.heavyImpact();
    _pttPressCtrl.forward();
    _pttPulseCtrl.repeat();
    CallService.instance.startTransmitting();
  }

  void _onPttUp() {
    if (!_isTransmitting) return;
    setState(() => _isTransmitting = false);
    HapticFeedback.mediumImpact();
    _pttPressCtrl.reverse();
    _pttPulseCtrl.stop();
    _pttPulseCtrl.value = 0;
    CallService.instance.stopTransmitting();
  }

  void _endCall() {
    HapticFeedback.mediumImpact();
    CallService.instance.endCall(_call.callId);
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _call.state == CallState.active;
    final isOutgoing = _call.state == CallState.outgoing;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF060C18),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            CustomPaint(
                painter: _WaveformBgPainter(transmitting: _isTransmitting)),

            SafeArea(
              child: Column(
                children: [
                  // ── Top bar ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF00C853).withOpacity(0.12)
                                : const Color(0xFFFFB300).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFF00C853)
                                      : const Color(0xFFFFB300),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isActive
                                    ? 'CONNECTED'
                                    : isOutgoing
                                        ? 'CALLING...'
                                        : 'CONNECTING',
                                style: TextStyle(
                                  color: isActive
                                      ? const Color(0xFF00C853)
                                      : const Color(0xFFFFB300),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (isActive)
                          Text(
                            _elapsedLabel,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Avatar & name
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF)
                              .withOpacity(_isTransmitting ? 0.5 : 0.2),
                          blurRadius: _isTransmitting ? 40 : 20,
                          spreadRadius: _isTransmitting ? 4 : 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _call.callerName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    _call.callerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _call.callerNumber,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Receive indicator
                  AnimatedBuilder(
                    animation: _receiveCtrl,
                    builder: (_, __) {
                      final visible = _call.pttState == PttState.receiving;
                      return AnimatedOpacity(
                        opacity: visible ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF00E5FF)
                                  .withOpacity(0.3 + _receiveCtrl.value * 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.volume_up_rounded,
                                color: const Color(0xFF00E5FF),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'RECEIVING',
                                style: TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // ── PTT Button ───────────────────────────────────────────
                  if (isActive) ...[
                    _PTTButton(
                      isTransmitting: _isTransmitting,
                      pulseCtrl: _pttPulseCtrl,
                      pressCtrl: _pttPressCtrl,
                      onDown: _onPttDown,
                      onUp: _onPttUp,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isTransmitting ? '● TRANSMITTING' : 'HOLD TO TALK',
                      style: TextStyle(
                        color: _isTransmitting
                            ? const Color(0xFFFF6B35)
                            : Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: _OutgoingIndicator(),
                    ),

                  const Spacer(),

                  // ── Bottom controls ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
                    child: _BottomControls(
                      call: _call,
                      onMute: () => CallService.instance.toggleMute(),
                      onSpeaker: () => CallService.instance.toggleSpeaker(),
                      onEnd: _endCall,
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

// ── PTT Button ────────────────────────────────────────────────────────────────

class _PTTButton extends StatelessWidget {
  final bool isTransmitting;
  final AnimationController pulseCtrl;
  final AnimationController pressCtrl;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const _PTTButton({
    required this.isTransmitting,
    required this.pulseCtrl,
    required this.pressCtrl,
    required this.onDown,
    required this.onUp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onDown(),
      onTapUp: (_) => onUp(),
      onTapCancel: onUp,
      child: AnimatedBuilder(
        animation: Listenable.merge([pulseCtrl, pressCtrl]),
        builder: (_, __) {
          final scale = 1.0 -
              pressCtrl.value * 0.07 +
              (isTransmitting
                  ? 0.04 * (0.5 + 0.5 * (1 - (pulseCtrl.value - 0.5).abs() * 2))
                  : 0);

          return Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse
                if (isTransmitting)
                  AnimatedBuilder(
                    animation: pulseCtrl,
                    builder: (_, __) => Container(
                      width: 180 + pulseCtrl.value * 40,
                      height: 180 + pulseCtrl.value * 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF6B35)
                              .withOpacity((1 - pulseCtrl.value) * 0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                // Button body
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: isTransmitting
                          ? [
                              const Color(0xFFFF6B35),
                              const Color(0xFFE64A19),
                            ]
                          : [
                              const Color(0xFF1A3A5C),
                              const Color(0xFF0D2137),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isTransmitting
                                ? const Color(0xFFFF6B35)
                                : const Color(0xFF00E5FF))
                            .withOpacity(isTransmitting ? 0.6 : 0.25),
                        blurRadius: isTransmitting ? 40 : 20,
                        spreadRadius: isTransmitting ? 4 : 0,
                      ),
                    ],
                    border: Border.all(
                      color: (isTransmitting
                              ? const Color(0xFFFF8C61)
                              : const Color(0xFF00E5FF))
                          .withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isTransmitting ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Outgoing (dialing) indicator ──────────────────────────────────────────────

class _OutgoingIndicator extends StatefulWidget {
  @override
  State<_OutgoingIndicator> createState() => _OutgoingIndicatorState();
}

class _OutgoingIndicatorState extends State<_OutgoingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _dots = 1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
    _ctrl.addListener(() {
      setState(() => _dots = (_ctrl.value * 3).floor() + 1);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'Calling${'.' * _dots}',
      style: const TextStyle(
        color: Color(0xFFFFB300),
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
      ),
    );
  }
}

// ── Bottom controls ───────────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final CallModel call;
  final VoidCallback onMute;
  final VoidCallback onSpeaker;
  final VoidCallback onEnd;

  const _BottomControls({
    required this.call,
    required this.onMute,
    required this.onSpeaker,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlBtn(
          icon: call.isMuted ? Icons.mic_off_rounded : Icons.mic_outlined,
          label: call.isMuted ? 'Unmute' : 'Mute',
          onTap: onMute,
          active: call.isMuted,
          activeColor: const Color(0xFFFFB300),
        ),
        // End call — centre
        GestureDetector(
          onTap: onEnd,
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE53935).withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.call_end_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        _ControlBtn(
          icon: call.isSpeakerOn
              ? Icons.volume_up_rounded
              : Icons.volume_off_rounded,
          label: call.isSpeakerOn ? 'Speaker' : 'Earpiece',
          onTap: onSpeaker,
          active: call.isSpeakerOn,
          activeColor: const Color(0xFF00E5FF),
        ),
      ],
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final Color activeColor;

  const _ControlBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.active,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: active
                  ? activeColor.withOpacity(0.15)
                  : Colors.white.withOpacity(0.07),
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    active ? activeColor.withOpacity(0.4) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: active ? activeColor : Colors.white.withOpacity(0.5),
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: active ? activeColor : Colors.white.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background waveform painter ───────────────────────────────────────────────

class _WaveformBgPainter extends CustomPainter {
  final bool transmitting;
  _WaveformBgPainter({required this.transmitting});

  @override
  void paint(Canvas canvas, Size size) {
    // Base dark gradient
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF060C18), Color(0xFF050A14)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle grid
    final gridPaint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.02)
      ..strokeWidth = 0.5;

    for (double x = 0; x < size.width; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Bottom glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (transmitting ? const Color(0xFFFF6B35) : const Color(0xFF00E5FF))
              .withOpacity(0.07),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height * 0.85),
        radius: size.width * 0.7,
      ));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  @override
  bool shouldRepaint(_WaveformBgPainter old) =>
      old.transmitting != transmitting;
}
