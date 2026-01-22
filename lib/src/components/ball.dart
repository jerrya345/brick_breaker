import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import 'bat.dart';
import 'brick.dart';
import 'enemy.dart';
import 'play_area.dart';

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
    Color? color,
  }) : super(
         radius: radius,
         anchor: Anchor.center,
         paint: Paint()
           ..color = color ?? const Color(0xff1e6091)
           ..style = PaintingStyle.fill,
         children: [CircleHitbox()],
       );

  final Vector2 velocity;
  final double difficultyModifier;

  void changeColor(Color color) {
    paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.y >= game.height) {
        add(
          RemoveEffect(
            delay: 0.35,
            onComplete: () {
              game.playState = PlayState.gameOver;
            },
          ),
        );
      }
    } else if (other is Bat) {
      final bat = other as Bat;
      
      if (bat.isCurved) {
        // Física especial para bate curvo
        // El rebote es más pronunciado hacia el centro
        final centerX = bat.position.x;
        final distanceFromCenter = position.x - centerX;
        final normalizedDistance = distanceFromCenter / (bat.size.x / 2);
        
        // Rebote más pronunciado
        velocity.y = -velocity.y.abs();
        velocity.x = velocity.x + normalizedDistance * game.width * 0.5;
      } else {
        // Física normal
        velocity.y = -velocity.y;
        velocity.x =
            velocity.x +
            (position.x - other.position.x) / other.size.x * game.width * 0.3;
      }
    } else if (other is Brick) {
      if (position.y < other.position.y - other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < other.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > other.position.x) {
        velocity.x = -velocity.x;
      }
      velocity.setFrom(velocity * difficultyModifier);
    } else if (other is Enemy) {
      // La pelota rebota en los enemigos
      if (position.y < other.position.y - other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > other.position.y + other.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < other.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > other.position.x) {
        velocity.x = -velocity.x;
      }
    }
  }
}
