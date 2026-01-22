import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  String? _currentTrack;

  final List<String> _tracks = [
    'track1',
    'track2',
    'track3',
  ];

  List<String> get tracks => _tracks;

  Future<void> playTrack(String trackName, {bool loop = true}) async {
    if (_currentTrack == trackName && _isPlaying) return;

    try {
      await _player.stop();
      
      // En web, usar URLs. En otros plataformas, usar assets
      if (kIsWeb) {
        // URLs de música estilo videojuego (puedes reemplazar con tus propias URLs)
        final trackUrls = {
          'track1': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          'track2': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
          'track3': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        };
        
        await _player.play(UrlSource(trackUrls[trackName] ?? trackUrls['track1']!));
      } else {
        // Para otras plataformas, usar assets locales
        // Necesitarías agregar los archivos de música a assets/
        await _player.play(AssetSource('music/$trackName.mp3'));
      }
      
      if (loop) {
        _player.setReleaseMode(ReleaseMode.loop);
      }
      
      _currentTrack = trackName;
      _isPlaying = true;
    } catch (e) {
      debugPrint('Error playing music: $e');
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  Future<void> resume() async {
    await _player.resume();
    _isPlaying = true;
  }

  void setVolume(double volume) {
    _player.setVolume(volume.clamp(0.0, 1.0));
  }

  bool get isPlaying => _isPlaying;
  String? get currentTrack => _currentTrack;
}
