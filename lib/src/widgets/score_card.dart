import 'package:flutter/material.dart';

import '../brick_breaker.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key, required this.score, required this.game});

  final ValueNotifier<int> score;
  final BrickBreaker game;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ValueListenableBuilder<int>(
            valueListenable: score,
            builder: (context, scoreValue, child) {
              return Text(
                'SCORE: $scoreValue',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 12,
                    ),
              );
            },
          ),
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
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: timeColor,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'TIME: $timeString',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 12,
                          color: timeColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
