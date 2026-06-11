import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:rescue_app/service/call_mode.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
// import 'package:ptt_call/models/call_model.dart';

/// Central service that bridges flutter_callkit_incoming events
/// with our app state. Singleton accessed via [CallService.instance].
class CallService {
  CallService._();
  static final CallService instance = CallService._();

  final _uuid = const Uuid();

  // Stream controllers for UI to subscribe to
  final _callStateController = StreamController<CallModel?>.broadcast();
  Stream<CallModel?> get callStateStream => _callStateController.stream;

  CallModel? _currentCall;
  CallModel? get currentCall => _currentCall;

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    FlutterCallkitIncoming.onEvent.listen(_onCallkitEvent);
  }

  // ── Simulate incoming PTT call (for demo) ─────────────────────────────────

  Future<void> simulateIncomingCall({
    String name = 'Alpha Team',
    String number = '+1 555 0101',
  }) async {
    final id = _uuid.v4();

    final params = CallKitParams(
      id: id,
      nameCaller: name,
      appName: 'PTT Call',
      avatar: 'https://i.pravatar.cc/150?u=$number',
      handle: number,
      type: 0, // 0 = audio
      duration: 30000, // ms auto-reject timeout
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed PTT call',
        callbackText: 'Call back',
      ),
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0A0A1A',
        backgroundUrl: 'assets/bg_call.png',
        actionColor: '#00E5FF',
        textColor: '#FFFFFF',
        incomingCallNotificationChannelName: 'Incoming PTT Call',
        missedCallNotificationChannelName: 'Missed PTT Call',
        isShowCallID: false,
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: false,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'voiceChat',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: false,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);

    _currentCall = CallModel(
      callId: id,
      callerName: name,
      callerNumber: number,
      isIncoming: true,
      startTime: DateTime.now(),
      state: CallState.ringing,
    );
    _callStateController.add(_currentCall);
  }

  // ── Outgoing call ─────────────────────────────────────────────────────────

  Future<void> startOutgoingCall({
    required String name,
    required String number,
  }) async {
    final id = _uuid.v4();

    final params = CallKitParams(
      id: id,
      nameCaller: name,
      handle: number,
      type: 0,
      ios: const IOSParams(
        handleType: 'generic',
        supportsVideo: false,
      ),
      android: const AndroidParams(
        isCustomNotification: true,
        backgroundColor: '#0A0A1A',
        actionColor: '#00E5FF',
        textColor: '#FFFFFF',
        incomingCallNotificationChannelName: 'Outgoing PTT Call',
        missedCallNotificationChannelName: 'Missed PTT Call',
      ),
    );

    await FlutterCallkitIncoming.startCall(params);

    _currentCall = CallModel(
      callId: id,
      callerName: name,
      callerNumber: number,
      isIncoming: false,
      startTime: DateTime.now(),
      state: CallState.outgoing,
    );
    _callStateController.add(_currentCall);
  }

  // ── Accept / Decline / End ────────────────────────────────────────────────

  Future<void> acceptCall(String callId) async {
    await FlutterCallkitIncoming.setCallConnected(callId);
    _updateCallState(callId, CallState.active);
    await WakelockPlus.enable();
  }

  Future<void> declineCall(String callId) async {
    await FlutterCallkitIncoming.endCall(callId);
    _updateCallState(callId, CallState.ended);
    _clearCall();
  }

  Future<void> endCall(String callId) async {
    await FlutterCallkitIncoming.endCall(callId);
    _updateCallState(callId, CallState.ended);
    await WakelockPlus.disable();
    _clearCall();
  }

  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
    await WakelockPlus.disable();
    _clearCall();
  }

  // ── PTT actions ───────────────────────────────────────────────────────────

  void startTransmitting() {
    if (_currentCall == null) return;
    _currentCall = _currentCall!.copyWith(pttState: PttState.transmitting);
    _callStateController.add(_currentCall);
  }

  void stopTransmitting() {
    if (_currentCall == null) return;
    _currentCall = _currentCall!.copyWith(pttState: PttState.idle);
    _callStateController.add(_currentCall);
  }

  void toggleMute() {
    if (_currentCall == null) return;
    _currentCall = _currentCall!.copyWith(isMuted: !_currentCall!.isMuted);
    _callStateController.add(_currentCall);
  }

  void toggleSpeaker() {
    if (_currentCall == null) return;
    _currentCall =
        _currentCall!.copyWith(isSpeakerOn: !_currentCall!.isSpeakerOn);
    _callStateController.add(_currentCall);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _onCallkitEvent(CallEvent? event) {
    if (event == null) return;
    debugPrint('[CallService] event: ${event.event} body: ${event.body}');

    switch (event.event) {
      case Event.actionCallIncoming:
        // Already handled in simulateIncomingCall
        break;

      case Event.actionCallAccept:
        final id = event.body['id'] as String? ?? '';
        _updateCallState(id, CallState.active);
        WakelockPlus.enable();
        break;

      case Event.actionCallDecline:
        final id = event.body['id'] as String? ?? '';
        _updateCallState(id, CallState.ended);
        _clearCall();
        break;

      case Event.actionCallEnded:
        _clearCall();
        WakelockPlus.disable();
        break;

      case Event.actionCallTimeout:
        _clearCall();
        break;

      case Event.actionDidUpdateDevicePushTokenVoip:
        // Handle VOIP push token refresh
        break;

      default:
        break;
    }
  }

  void _updateCallState(String callId, CallState state) {
    if (_currentCall == null) return;
    _currentCall = _currentCall!.copyWith(state: state);
    _callStateController.add(_currentCall);
  }

  void _clearCall() {
    _currentCall = null;
    _callStateController.add(null);
  }

  void dispose() {
    _callStateController.close();
  }
}
