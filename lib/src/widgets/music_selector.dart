import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/music_service.dart';
import '../services/game_storage.dart';

class MusicSelector extends StatefulWidget {
  const MusicSelector({super.key});

  @override
  State<MusicSelector> createState() => _MusicSelectorState();
}

class _MusicSelectorState extends State<MusicSelector> {
  final musicService = MusicService();
  String? _currentTrack;
  bool _musicEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _musicEnabled = await GameStorage.isMusicEnabled();
    _currentTrack = await GameStorage.getCurrentMusic();
    setState(() {});
  }

  Future<void> _toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    await GameStorage.setMusicEnabled(_musicEnabled);
    
    if (_musicEnabled && _currentTrack != null) {
      musicService.playTrack(_currentTrack!);
    } else {
      musicService.stop();
    }
    
    setState(() {});
  }

  Future<void> _selectTrack(String track) async {
    _currentTrack = track;
    await GameStorage.setCurrentMusic(track);
    
    if (_musicEnabled) {
      musicService.playTrack(track);
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff184e77),
      appBar: AppBar(
        title: Text(
          'MUSIC',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: const Color(0xff1e6091),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffa9d6e5), Color(0xfff2e8cf)],
          ),
        ),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'MUSIC: ${_musicEnabled ? "ON" : "OFF"}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              value: _musicEnabled,
              onChanged: (value) => _toggleMusic(),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: musicService.tracks.length,
                itemBuilder: (context, index) {
                  final track = musicService.tracks[index];
                  final isSelected = _currentTrack == track;
                  
                  return Card(
                    color: isSelected
                        ? const Color(0xff1e6091)
                        : Colors.white,
                    child: ListTile(
                      title: Text(
                        'Track ${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.yellow)
                          : null,
                      onTap: () => _selectTrack(track),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
