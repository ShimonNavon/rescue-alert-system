import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';

class AudioService {
  AudioService({AudioRecorder? recorder, AudioPlayer? player})
    : _recorder = recorder ?? AudioRecorder(),
      _player = player ?? AudioPlayer();

  final AudioRecorder _recorder;
  final AudioPlayer _player;

  Future<String?> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      return null;
    }
    final path =
        '${Directory.systemTemp.path}/rescue_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    return path;
  }

  Future<String?> stopRecording() async {
    return _recorder.stop();
  }

  Future<Uint8List?> readRecording(String? path) async {
    if (path == null) {
      return null;
    }
    return File(path).readAsBytes();
  }

  Future<void> playFromUrl(String url) async {
    await _player.play(UrlSource(url));
  }

  Future<void> playFromFile(String path) async {
    await _player.play(DeviceFileSource(path));
  }

  Future<void> stopPlayback() async {
    await _player.stop();
  }

  Future<void> dispose() async {
    await _player.dispose();
    _recorder.dispose();
  }
}
