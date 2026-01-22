import 'dart:async' as async;
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/components.dart';
import 'components/power_up.dart';
import 'config.dart';
import 'models/level.dart';
import 'models/ball_skin.dart';
import 'models/power_up_type.dart';
import 'services/game_storage.dart';
import 'services/music_service.dart';

enum PlayState { welcome, playing, gameOver, won, levelSelect }

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents {
  BrickBreaker()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: gameWidth,
          height: gameHeight,
        ),
      );

  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> levelNotifier = ValueNotifier(1);
  final ValueNotifier<int> timeRemaining = ValueNotifier(200);
  final rand = math.Random();
  final musicService = MusicService();
  
  int _currentLevel = 1;
  int get currentLevel => _currentLevel;
  Level? _currentLevelData;
  BallSkin? _currentSkin;
  async.Timer? _timer;
  
  // Power-ups activos
  bool _curvedBatActive = false;
  async.Timer? _curvedBatTimer;
  bool _extendedBatActive = false;
  async.Timer? _extendedBatTimer;
  
  double get width => size.x;
  double get height => size.y;

  PlayState _playState = PlayState.welcome;
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
      case PlayState.levelSelect:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
        overlays.remove(PlayState.levelSelect.name);
    }
  }

  @override
  async.FutureOr<void> onLoad() async {
    super.onLoad();

    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());

    // Cargar skin actual
    final skinId = await GameStorage.getCurrentSkin();
    final skins = BallSkin.generateSkins();
    _currentSkin = skins.firstWhere(
      (s) => s.id == skinId,
      orElse: () => skins.first,
    );

    // Inicializar música
    final musicEnabled = await GameStorage.isMusicEnabled();
    if (musicEnabled) {
      final currentMusic = await GameStorage.getCurrentMusic();
      musicService.playTrack(currentMusic);
    }

    playState = PlayState.welcome;
  }

  Future<void> startGame({int? level}) async {
    if (playState == PlayState.playing) return;

    // Cancelar temporizador anterior si existe
    _timer?.cancel();

    // Determinar nivel
    if (level != null) {
      _currentLevel = level;
    }
    levelNotifier.value = _currentLevel;

    // Cargar datos del nivel
    final levels = Level.generateLevels();
    _currentLevelData = levels.firstWhere((l) => l.number == _currentLevel);

    // Verificar si el nivel está desbloqueado
    final isUnlocked = await GameStorage.isLevelUnlocked(_currentLevel);
    if (!isUnlocked && _currentLevel > 1) {
      return; // No iniciar si no está desbloqueado
    }

    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());
    world.removeAll(world.children.query<Enemy>());
    world.removeAll(world.children.query<PowerUp>());
    
    // Resetear power-ups
    _curvedBatActive = false;
    _extendedBatActive = false;
    _curvedBatTimer?.cancel();
    _extendedBatTimer?.cancel();

    playState = PlayState.playing;
    score.value = 0;
    
    // Inicializar temporizador
    timeRemaining.value = _currentLevelData!.timeLimit;
    _startTimer();

    // Crear pelota con skin
    final ballColor = _currentSkin?.color ?? const Color(0xff1e6091);
    world.add(
      Ball(
        difficultyModifier: difficultyModifier * _currentLevelData!.difficultyMultiplier,
        radius: ballRadius,
        position: size / 2,
        velocity: Vector2(
          (rand.nextDouble() - 0.5) * width,
          height * 0.2,
        ).normalized()..scale(height / 4 * _currentLevelData!.difficultyMultiplier),
        color: ballColor,
      ),
    );

    // Crear bate
    world.add(
      Bat(
        size: Vector2(batWidth, batHeight),
        cornerRadius: const Radius.circular(ballRadius / 2),
        position: Vector2(width / 2, height * 0.95),
      ),
    );

    // Crear ladrillos según el nivel
    final levelData = _currentLevelData!;
    final rows = levelData.brickRows;
    final cols = levelData.brickCols;
    final actualBrickWidth = (gameWidth - (brickGutter * (cols + 1))) / cols;

    world.addAll([
      for (var i = 0; i < cols; i++)
        for (var j = 1; j <= rows; j++)
          Brick(
            position: Vector2(
              (i + 0.5) * actualBrickWidth + (i + 1) * brickGutter,
              (j + 2.0) * brickHeight + j * brickGutter,
            ),
            color: brickColors[i % brickColors.length],
          ),
    ]);

    // Agregar enemigos si el nivel los tiene
    if (levelData.hasEnemies) {
      final enemyCount = (_currentLevel / 5).ceil();
      for (int i = 0; i < enemyCount; i++) {
        world.add(
          Enemy(
            position: Vector2(
              (rand.nextDouble() * 0.6 + 0.2) * width,
              (rand.nextDouble() * 0.3 + 0.4) * height,
            ),
            size: Vector2(brickWidth * 0.8, brickHeight * 0.8),
          ),
        );
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = null;
    
    _timer = async.Timer.periodic(const Duration(seconds: 1), (timer) {
      // Verificar que el juego sigue en estado playing
      if (playState != PlayState.playing) {
        timer.cancel();
        _timer = null;
        return;
      }

      // Actualizar tiempo restante de forma segura
      final currentTime = timeRemaining.value;
      if (currentTime > 0) {
        timeRemaining.value = currentTime - 1;
        
        // Si el tiempo llegó a 0, manejar fin del tiempo
        if (timeRemaining.value <= 0) {
          timer.cancel();
          _timer = null;
          _onTimeUp();
        }
      } else {
        // Si ya está en 0, cancelar y llamar a _onTimeUp
        timer.cancel();
        _timer = null;
        _onTimeUp();
      }
    });
  }

  Future<void> _onTimeUp() async {
    // Verificar si alcanzó el puntaje requerido
    final levelData = _currentLevelData!;
    final requiredScore = levelData.requiredScore;
    
    if (score.value < requiredScore) {
      // No alcanzó el puntaje requerido, perder
      playState = PlayState.gameOver;
    } else {
      // Alcanzó el puntaje, completar nivel normalmente
      await onBrickDestroyed();
    }
  }

  Future<void> onBrickDestroyed() async {
    // Verificar si se ganó el nivel
    final remainingBricks = world.children.query<Brick>();
    if (remainingBricks.isEmpty) {
      // Guardar puntaje del nivel
      await GameStorage.setLevelScore(_currentLevel, score.value);
      await GameStorage.addToTotalScore(score.value);

      // Verificar desbloqueo de skins
      final totalScore = await GameStorage.getTotalScore();
      final skins = BallSkin.generateSkins();
      for (final skin in skins) {
        if (totalScore >= skin.requiredScore) {
          await GameStorage.unlockSkin(skin.id);
        }
      }

      // Desbloquear siguiente nivel si se alcanzó el puntaje requerido
      if (_currentLevel < 50) {
        final nextLevel = _currentLevel + 1;
        final levels = Level.generateLevels();
        final nextLevelData = levels.firstWhere((l) => l.number == nextLevel);
        final totalScore = await GameStorage.getTotalScore();

        if (totalScore >= nextLevelData.requiredScore) {
          await GameStorage.unlockLevel(nextLevel);
        }
      }

      // Cancelar temporizador solo cuando se completa el nivel
      _timer?.cancel();
      _timer = null;
      playState = PlayState.won;
    }
  }

  void setLevel(int level) {
    _currentLevel = level;
    levelNotifier.value = level;
  }

  Future<void> changeSkin(String skinId) async {
    final skins = BallSkin.generateSkins();
    final skin = skins.firstWhere((s) => s.id == skinId);
    final isUnlocked = await GameStorage.isSkinUnlocked(skinId);
    
    if (isUnlocked) {
      _currentSkin = skin;
      await GameStorage.setCurrentSkin(skinId);
      
      // Actualizar color de la pelota si está en juego
      final ball = world.children.query<Ball>().firstOrNull;
      if (ball != null) {
        ball.changeColor(skin.color);
      }
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        if (playState == PlayState.playing) {
          world.children.query<Bat>().firstOrNull?.moveBy(-batStep);
        }
      case LogicalKeyboardKey.arrowRight:
        if (playState == PlayState.playing) {
          world.children.query<Bat>().firstOrNull?.moveBy(batStep);
        }
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        if (playState != PlayState.playing) {
          startGame();
        }
    }
    return KeyEventResult.handled;
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);

  // Generar power-up en una posición
  void spawnPowerUp(Vector2 position) {
    if (playState != PlayState.playing) return;
    
    // Seleccionar un power-up aleatorio
    final powerUpTypes = PowerUpType.values;
    final randomType = powerUpTypes[rand.nextInt(powerUpTypes.length)];
    
    world.add(
      PowerUp(
        type: randomType,
        position: position,
      ),
    );
  }

  // Aplicar un power-up
  void applyPowerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.tripleBall:
        _applyTripleBall();
        break;
      case PowerUpType.curvedBat:
        _applyCurvedBat();
        break;
      case PowerUpType.extendedBat:
        _applyExtendedBat();
        break;
    }
  }

  void _applyTripleBall() {
    final balls = world.children.query<Ball>();
    if (balls.isEmpty) return;
    
    final originalBall = balls.first;
    final velocity = originalBall.velocity;
    final position = originalBall.position;
    final color = originalBall.paint.color;
    
    // Crear 2 pelotas adicionales con velocidades ligeramente diferentes
    for (int i = 0; i < 2; i++) {
      final angle = (i + 1) * 0.3; // Ángulo de separación
      final newVelocity = Vector2(
        velocity.x * math.cos(angle) - velocity.y * math.sin(angle),
        velocity.x * math.sin(angle) + velocity.y * math.cos(angle),
      ).normalized()..scale(velocity.length);
      
      world.add(
        Ball(
          difficultyModifier: originalBall.difficultyModifier,
          radius: ballRadius,
          position: position + Vector2((i - 1) * 20, 0),
          velocity: newVelocity,
          color: color,
        ),
      );
    }
  }

  void _applyCurvedBat() {
    // Cancelar timer anterior si existe
    _curvedBatTimer?.cancel();
    _curvedBatActive = true;
    
    // Aplicar efecto curvo al bate
    final bat = world.children.query<Bat>().firstOrNull;
    if (bat != null) {
      bat.setCurved(true);
    }
    
    // El efecto dura hasta que se cancele manualmente o termine el nivel
    // No tiene duración fija, permanece activo
  }

  void _applyExtendedBat() {
    // Cancelar timer anterior si existe
    _extendedBatTimer?.cancel();
    _extendedBatActive = true;
    
    // Aplicar efecto extendido al bate
    final bat = world.children.query<Bat>().firstOrNull;
    if (bat != null) {
      bat.setExtended(true);
    }
    
    // El efecto dura 30 segundos
    _extendedBatTimer = async.Timer(const Duration(seconds: 30), () {
      _extendedBatActive = false;
      final bat = world.children.query<Bat>().firstOrNull;
      if (bat != null) {
        bat.setExtended(false);
      }
      _extendedBatTimer = null;
    });
  }

  @override
  void onRemove() {
    _timer?.cancel();
    _curvedBatTimer?.cancel();
    _extendedBatTimer?.cancel();
    super.onRemove();
  }
}
