import 'package:flutter/material.dart';

class BallSkin {
  final String id;
  final String name;
  final Color color;
  final int requiredScore;
  final bool isUnlocked;

  BallSkin({
    required this.id,
    required this.name,
    required this.color,
    required this.requiredScore,
    this.isUnlocked = false,
  });

  static List<BallSkin> generateSkins() {
    return [
      BallSkin(
        id: 'default',
        name: 'Classic Blue',
        color: const Color(0xff1e6091),
        requiredScore: 0,
        isUnlocked: true,
      ),
      BallSkin(
        id: 'red',
        name: 'Fire Red',
        color: const Color(0xfff94144),
        requiredScore: 500,
      ),
      BallSkin(
        id: 'orange',
        name: 'Sunset Orange',
        color: const Color(0xfff3722c),
        requiredScore: 1000,
      ),
      BallSkin(
        id: 'yellow',
        name: 'Golden Yellow',
        color: const Color(0xfff9c74f),
        requiredScore: 2000,
      ),
      BallSkin(
        id: 'green',
        name: 'Emerald Green',
        color: const Color(0xff90be6d),
        requiredScore: 3500,
      ),
      BallSkin(
        id: 'purple',
        name: 'Royal Purple',
        color: const Color(0xff6c5ce7),
        requiredScore: 5000,
      ),
      BallSkin(
        id: 'pink',
        name: 'Bubblegum Pink',
        color: const Color(0xffff6b9d),
        requiredScore: 7500,
      ),
      BallSkin(
        id: 'cyan',
        name: 'Neon Cyan',
        color: const Color(0xff00d4ff),
        requiredScore: 10000,
      ),
      BallSkin(
        id: 'rainbow',
        name: 'Rainbow',
        color: const Color(0xffff00ff),
        requiredScore: 15000,
      ),
      BallSkin(
        id: 'gold',
        name: 'Gold',
        color: const Color(0xffffd700),
        requiredScore: 20000,
      ),
    ];
  }
}
