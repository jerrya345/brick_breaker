import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import 'ball.dart';

class Enemy extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Enemy({
    required super.position,
    required super.size,
  }) : super(
         anchor: Anchor.center,
         paint: Paint()
           ..color = const Color(0xff8b0000)
           ..style = PaintingStyle.fill,
         children: [RectangleHitbox()],
       );

  final _paint = Paint()
    ..color = const Color(0xff8b0000)
    ..style = PaintingStyle.fill;

  Vector2? _targetPosition;
  final double _speed = 100.0;
  final double _detectionRadius = 200.0;

  @override
  void update(double dt) {
    super.update(dt);

    // Buscar la pelota más cercana
    final balls = game.world.children.query<Ball>();
    if (balls.isNotEmpty) {
      final ball = balls.first;
      final distance = (ball.position - position).length;

      if (distance < _detectionRadius) {
        // Moverse alejándose de la pelota
        final direction = (position - ball.position).normalized();
        _targetPosition = position + direction * _speed * dt;
      } else {
        _targetPosition = null;
      }
    }

    // Mover hacia la posición objetivo
    if (_targetPosition != null) {
      final direction = (_targetPosition! - position).normalized();
      position += direction * _speed * dt;

      // Mantener dentro de los límites
      position.x = position.x.clamp(size.x / 2, game.width - size.x / 2);
      position.y = position.y.clamp(size.y / 2, game.height * 0.3);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size.toSize(),
        const Radius.circular(4),
      ),
      _paint,
    );
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ball) {
      // El enemigo desaparece al ser golpeado
      removeFromParent();
    }
  }
}
