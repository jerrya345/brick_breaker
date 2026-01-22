import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/ball_skin.dart';
import '../services/game_storage.dart';

class SkinSelector extends StatefulWidget {
  final Function(String) onSkinSelected;

  const SkinSelector({super.key, required this.onSkinSelected});

  @override
  State<SkinSelector> createState() => _SkinSelectorState();
}

class _SkinSelectorState extends State<SkinSelector> {
  List<BallSkin> _skins = [];
  List<String> _unlockedSkins = [];
  String _currentSkin = 'default';
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _loadSkins();
  }

  Future<void> _loadSkins() async {
    _skins = BallSkin.generateSkins();
    _unlockedSkins = await GameStorage.getUnlockedSkins();
    _currentSkin = await GameStorage.getCurrentSkin();
    _totalScore = await GameStorage.getTotalScore();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff184e77),
      appBar: AppBar(
        title: Text(
          'BALL SKINS',
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
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: _skins.length,
          itemBuilder: (context, index) {
            final skin = _skins[index];
            final isUnlocked = _unlockedSkins.contains(skin.id);
            final isSelected = _currentSkin == skin.id;

            return GestureDetector(
              onTap: isUnlocked
                  ? () {
                      widget.onSkinSelected(skin.id);
                      setState(() {
                        _currentSkin = skin.id;
                      });
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Colors.white
                      : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: Colors.yellow, width: 3)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: skin.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      skin.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isUnlocked ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (!isUnlocked)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          children: [
                            const Icon(Icons.lock, size: 16, color: Colors.white),
                            Text(
                              '${skin.requiredScore - _totalScore} pts',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.yellow,
                                    fontSize: 10,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
