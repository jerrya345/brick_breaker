import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'game_hud.dart';
import 'level_selector.dart';
import 'music_selector.dart';
import 'overlay_screen.dart';
import 'score_card.dart';
import 'skin_selector.dart';

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final BrickBreaker game;

  @override
  void initState() {
    super.initState();
    game = BrickBreaker();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.pressStart2pTextTheme().apply(
          bodyColor: const Color(0xff184e77),
          displayColor: const Color(0xff184e77),
        ),
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffa9d6e5), Color(0xfff2e8cf)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    // Botones de menú
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LevelSelector(
                                      onLevelSelected: (level) {
                                        game.setLevel(level);
                                        game.startGame(level: level);
                                      },
                                      currentLevel: game.currentLevel,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.map, size: 18),
                              label: const Text('LEVELS', style: TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff1e6091),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SkinSelector(
                                      onSkinSelected: (skinId) {
                                        game.changeSkin(skinId);
                                      },
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.palette, size: 18),
                              label: const Text('SKINS', style: TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff1e6091),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MusicSelector(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.music_note, size: 18),
                              label: const Text('MUSIC', style: TextStyle(fontSize: 10)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff1e6091),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Score card con temporizador
                    ScoreCard(score: game.score, game: game),
                    // Game widget con HUD
                    Expanded(
                      child: Stack(
                        children: [
                          FittedBox(
                            child: SizedBox(
                              width: gameWidth,
                              height: gameHeight,
                              child: GestureDetector(
                                onTap: () {
                                  if (game.playState != PlayState.playing) {
                                    game.startGame();
                                  }
                                },
                                child: GameWidget(
                                  game: game,
                                  overlayBuilderMap: {
                                    PlayState.welcome.name: (context, game) =>
                                        const OverlayScreen(
                                          title: 'TAP TO PLAY',
                                          subtitle: 'Select a level to start',
                                        ),
                                    PlayState.gameOver.name: (context, game) =>
                                        const OverlayScreen(
                                          title: 'G A M E   O V E R',
                                          subtitle: 'Tap to Play Again',
                                        ),
                                    PlayState.won.name: (context, game) =>
                                        const OverlayScreen(
                                          title: 'L E V E L   C O M P L E T E !',
                                          subtitle: 'Tap to Continue',
                                        ),
                                    PlayState.levelSelect.name: (context, game) =>
                                        const OverlayScreen(
                                          title: 'SELECT LEVEL',
                                          subtitle: 'Choose your challenge',
                                        ),
                                  },
                                ),
                              ),
                            ),
                          ),
                          // HUD overlay
                          if (game.playState == PlayState.playing)
                            GameHUD(game: game),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
