/// Defines how audio is routed and transmitted during a call.
///
/// [ptt]      — Push-to-Talk (walkie-talkie): half-duplex, mic only active
///              while the PTT button is held. Default for this app.
/// [duplex]   — Full-duplex (normal phone call): both sides can speak at once.
/// [broadcast]— One-way: local user transmits continuously, remote only listens.
/// [listen]   — One-way: local user only receives, cannot transmit.
enum CallModeType { ptt, duplex, broadcast, listen }

/// Audio output routing preference.
enum AudioRoute { speaker, earpiece, bluetooth, wiredHeadset }

/// Immutable configuration object describing how a call should behave.
///
/// Pass a [CallMode] when creating a [CallModel] to control PTT vs duplex
/// behaviour, audio routing, and optional features like voice activity
/// detection or encryption.
class CallMode {
  /// The transmission mode (PTT, duplex, broadcast, listen).
  final CallModeType type;

  /// Where audio is routed on the local device.
  final AudioRoute audioRoute;

  /// How long (ms) to keep the channel open after the PTT button is released.
  /// Prevents clipping the tail of the last syllable. Default: 300 ms.
  final int pttTailMs;

  /// Maximum continuous transmit time (ms) before auto-release.
  /// 0 = unlimited. Default: 30 000 ms (30 s).
  final int maxTransmitMs;

  /// Play a short "beep" tone when PTT is pressed / released.
  final bool pttTones;

  /// Visual + haptic feedback when PTT state changes.
  final bool hapticFeedback;

  /// Whether the channel uses end-to-end encryption.
  final bool encrypted;

  /// Human-readable channel/group label shown in the UI.
  final String? channelLabel;

  const CallMode({
    this.type = CallModeType.ptt,
    this.audioRoute = AudioRoute.speaker,
    this.pttTailMs = 300,
    this.maxTransmitMs = 30000,
    this.pttTones = true,
    this.hapticFeedback = true,
    this.encrypted = false,
    this.channelLabel,
  });

  // ── Named presets ────────────────────────────────────────────────────────

  /// Standard PTT (walkie-talkie) mode — speaker, tones on.
  static const CallMode standardPtt = CallMode();

  /// Quiet PTT — earpiece, no tones, no haptic (e.g. covert ops).
  static const CallMode quietPtt = CallMode(
    type: CallModeType.ptt,
    audioRoute: AudioRoute.earpiece,
    pttTones: false,
    hapticFeedback: false,
  );

  /// Regular full-duplex phone call.
  static const CallMode phoneCall = CallMode(
    type: CallModeType.duplex,
    audioRoute: AudioRoute.earpiece,
    pttTones: false,
  );

  /// One-way broadcast (announcements).
  static const CallMode broadcastMode = CallMode(
    type: CallModeType.broadcast,
    audioRoute: AudioRoute.speaker,
    pttTones: false,
    maxTransmitMs: 0, // unlimited
  );

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Whether the user can press PTT in this mode.
  bool get canTransmit =>
      type == CallModeType.ptt ||
      type == CallModeType.duplex ||
      type == CallModeType.broadcast;

  /// Whether the user receives audio from the remote party.
  bool get canReceive =>
      type == CallModeType.ptt ||
      type == CallModeType.duplex ||
      type == CallModeType.listen;

  /// Returns a copy with selected fields overridden.
  CallMode copyWith({
    CallModeType? type,
    AudioRoute? audioRoute,
    int? pttTailMs,
    int? maxTransmitMs,
    bool? pttTones,
    bool? hapticFeedback,
    bool? encrypted,
    String? channelLabel,
  }) {
    return CallMode(
      type: type ?? this.type,
      audioRoute: audioRoute ?? this.audioRoute,
      pttTailMs: pttTailMs ?? this.pttTailMs,
      maxTransmitMs: maxTransmitMs ?? this.maxTransmitMs,
      pttTones: pttTones ?? this.pttTones,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      encrypted: encrypted ?? this.encrypted,
      channelLabel: channelLabel ?? this.channelLabel,
    );
  }

  @override
  String toString() =>
      'CallMode(type: $type, route: $audioRoute, encrypted: $encrypted)';
}

enum CallState {
  idle,
  ringing, // Incoming — full-screen UI shown
  outgoing, // Outgoing — dialing
  active, // In call
  held,
  ended,
}

enum PttState {
  idle,
  transmitting, // Local user pressing PTT
  receiving, // Remote party transmitting
}

class CallModel {
  final String callId;
  final String callerName;
  final String callerNumber;
  final String? callerAvatarUrl;
  final bool isIncoming;
  final DateTime startTime;

  /// How this call transmits / receives audio.
  final CallMode mode;

  CallState state;
  PttState pttState;
  bool isMuted;
  bool isSpeakerOn;

  CallModel({
    required this.callId,
    required this.callerName,
    required this.callerNumber,
    this.callerAvatarUrl,
    required this.isIncoming,
    required this.startTime,
    this.mode = CallMode.standardPtt,
    this.state = CallState.ringing,
    this.pttState = PttState.idle,
    this.isMuted = false,
    this.isSpeakerOn = true, // PTT defaults to speaker
  });

  CallModel copyWith({
    CallMode? mode,
    CallState? state,
    PttState? pttState,
    bool? isMuted,
    bool? isSpeakerOn,
  }) {
    return CallModel(
      callId: callId,
      callerName: callerName,
      callerNumber: callerNumber,
      callerAvatarUrl: callerAvatarUrl,
      isIncoming: isIncoming,
      startTime: startTime,
      mode: mode ?? this.mode,
      state: state ?? this.state,
      pttState: pttState ?? this.pttState,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    );
  }
}
