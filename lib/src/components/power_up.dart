import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../brick_breaker.dart';
import '../models/power_up_type.dart';
import 'ball.dart';
import 'bat.dart';

class PowerUp extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  PowerUp({
    required this.type,
    required super.position,
  }) : super(
         size: Vector2(40, 40),
         anchor: Anchor.center,
         paint: Paint()
           ..color = _getColorForType(type)
           ..style = PaintingStyle.fill,
         children: [RectangleHitbox()],
       );

  final PowerUpType type;
  final _paint = Paint();
  double _rotation = 0;
  final double _fallSpeed = 50.0;

  static Color _getColorForType(PowerUpType type) {
    switch (type) {
      case PowerUpType.tripleBall:
        return const Color(0xffff00ff); // Magenta
      case PowerUpType.curvedBat:
        return const Color(0xff00ffff); // Cyan
      case PowerUpType.extendedBat:
        return const Color(0xffffff00); // Yellow
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Rotar el power-up
    _rotation += dt * 2;
    
    // Hacer caer el power-up
    position.y += _fallSpeed * dt;
    
    // Si cae fuera de la pantalla, removerlo
    if (position.y > game.height + size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Guardar el estado del canvas
    canvas.save();
    
    // Mover al centro y rotar
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(_rotation);
    canvas.translate(-size.x / 2, -size.y / 2);
    
    // Dibujar el power-up con un símbolo
    final paint = Paint()
      ..color = _getColorForType(type)
      ..style = PaintingStyle.fill;
    
    // Dibujar un círculo con borde
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 - 2,
      paint,
    );
    
    // Dibujar borde
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 - 2,
      borderPaint,
    );
    
    // Dibujar símbolo según el tipo usando TextPainter
    final textPainter = TextPainter(
      text: TextSpan(
        text: _getSymbol(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.x - textPainter.width) / 2,
        (size.y - textPainter.height) / 2,
      ),
    );
    
    // Restaurar el estado del canvas
    canvas.restore();
  }

  String _getSymbol() {
    switch (type) {
      case PowerUpType.tripleBall:
        return '3';
      case PowerUpType.curvedBat:
        return 'C';
      case PowerUpType.extendedBat:
        return 'E';
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Ball || other is Bat) {
      // Aplicar el power-up cuando la pelota o el bate lo tocan
      game.applyPowerUp(type);
      removeFromParent();
    }
  }
}
