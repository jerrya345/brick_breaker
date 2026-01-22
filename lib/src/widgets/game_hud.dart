import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../models/ball_skin.dart';
import '../services/game_storage.dart';

class GameHUD extends StatelessWidget {
  final BrickBreaker game;

  const GameHUD({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: game.score,
      builder: (context, score, child) {
        return ValueListenableBuilder<int>(
          valueListenable: game.levelNotifier,
          builder: (context, level, child) {
            return FutureBuilder<Map<String, dynamic>>(
              future: _getHUDData(level),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final data = snapshot.data!;
                final totalScore = data['totalScore'] as int;
                final nextSkin = data['nextSkin'] as BallSkin?;

                return Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LEVEL: $level',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'SCORE: $score',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'TOTAL: $totalScore',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            ValueListenableBuilder<int>(
                              valueListenable: game.timeRemaining,
                              builder: (context, time, child) {
                                final minutes = time ~/ 60;
                                final seconds = time % 60;
                                final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
                                final timeColor = time <= 30 
                                    ? Colors.red 
                                    : time <= 60 
                                        ? Colors.orange 
                                        : Colors.green;
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: timeColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: timeColor, width: 2),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        color: timeColor,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        timeString,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: timeColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        if (nextSkin != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'NEXT SKIN:',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: nextSkin.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${nextSkin.requiredScore - totalScore} pts',
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
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getHUDData(int level) async {
    final totalScore = await GameStorage.getTotalScore();
    final skins = BallSkin.generateSkins();
    final unlockedSkins = await GameStorage.getUnlockedSkins();
    
    final nextSkin = skins.firstWhere(
      (skin) => !unlockedSkins.contains(skin.id) && totalScore < skin.requiredScore,
      orElse: () => skins.last,
    );

    return {
      'totalScore': totalScore,
      'nextSkin': nextSkin,
      'level': level,
    };
  }
}
