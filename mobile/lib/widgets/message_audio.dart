import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:rescue_app/models/message.dart';

class MessageAudio extends StatefulWidget {
  final Message message;

  const MessageAudio({
    required this.message,
    super.key,
  });

  @override
  State<MessageAudio> createState() => _MessageAudioState();
}

class _MessageAudioState extends State<MessageAudio> {
  late final AudioPlayer _player;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();

    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) {
        return;
      }
      setState(() {
        _playerState = state;
      });
    });

    _player.onDurationChanged.listen((duration) {
      if (!mounted) {
        return;
      }
      setState(() {
        _duration = duration;
      });
    });

    _player.onPositionChanged.listen((position) {
      if (!mounted) {
        return;
      }
      setState(() {
        _position = position;
      });
    });

    _player.onPlayerComplete.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Source? get _audioSource {
    final voiceUrl = widget.message.voiceUrl?.trim();
    if (voiceUrl != null && voiceUrl.isNotEmpty) {
      return UrlSource(voiceUrl);
    }

    final voiceFile = widget.message.voiceFile?.trim();
    if (voiceFile != null && voiceFile.isNotEmpty) {
      return DeviceFileSource(voiceFile);
    }

    return null;
  }

  bool get _isPlaying => _playerState == PlayerState.playing;

  Future<void> _togglePlayPause() async {
    final source = _audioSource;
    if (source == null) {
      return;
    }

    if (_playerState == PlayerState.playing) {
      await _player.pause();
      return;
    }

    if (_playerState == PlayerState.paused) {
      await _player.resume();
      return;
    }

    await _player.play(source);
  }

  Future<void> _stopIfPlaying() async {
    if (!_isPlaying) {
      return;
    }

    await _player.stop();
    if (!mounted) {
      return;
    }
    setState(() {
      _position = Duration.zero;
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final source = _audioSource;
    final canPlay = source != null;
    final maxMs = _duration.inMilliseconds;
    final currentMs = _position.inMilliseconds.clamp(0, maxMs == 0 ? 0 : maxMs);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  onPressed: canPlay ? _togglePlayPause : null,
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                ),
                IconButton(
                  onPressed: _isPlaying ? _stopIfPlaying : null,
                  icon: const Icon(Icons.stop),
                ),
                Expanded(
                  child: Slider(
                    value: currentMs.toDouble(),
                    min: 0,
                    max: maxMs > 0 ? maxMs.toDouble() : 1,
                    onChanged: maxMs > 0
                        ? (value) {
                            _player.seek(Duration(milliseconds: value.toInt()));
                          }
                        : null,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position)),
                Text(_formatDuration(_duration)),
              ],
            ),
            if (!canPlay)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'אין קובץ שמע זמין',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
