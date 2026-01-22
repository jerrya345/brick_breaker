import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/level.dart';
import '../services/game_storage.dart';

class LevelSelector extends StatefulWidget {
  final Function(int) onLevelSelected;
  final int currentLevel;

  const LevelSelector({
    super.key,
    required this.onLevelSelected,
    required this.currentLevel,
  });

  @override
  State<LevelSelector> createState() => _LevelSelectorState();
}

class _LevelSelectorState extends State<LevelSelector> {
  List<Level> _levels = [];
  List<int> _unlockedLevels = [];
  Map<int, int> _levelScores = {};

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    _levels = Level.generateLevels();
    _unlockedLevels = await GameStorage.getUnlockedLevels();
    _levelScores = await GameStorage.getLevelScores();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff184e77),
      appBar: AppBar(
        title: Text(
          'SELECT LEVEL',
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
            crossAxisCount: 5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _levels.length,
          itemBuilder: (context, index) {
            final level = _levels[index];
            final isUnlocked = _unlockedLevels.contains(level.number);
            final bestScore = _levelScores[level.number] ?? 0;

            return GestureDetector(
              onTap: isUnlocked
                  ? () {
                      widget.onLevelSelected(level.number);
                      Navigator.pop(context);
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? const Color(0xff1e6091)
                      : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(12),
                  border: level.number == widget.currentLevel
                      ? Border.all(color: Colors.yellow, width: 3)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${level.number}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (bestScore > 0)
                      Text(
                        '$bestScore',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.yellow,
                            ),
                      ),
                    if (!isUnlocked)
                      const Icon(Icons.lock, color: Colors.white, size: 20),
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
