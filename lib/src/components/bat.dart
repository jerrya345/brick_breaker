import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';

class Bat extends PositionComponent
    with DragCallbacks, HasGameReference<BrickBreaker> {
  Bat({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center, children: [RectangleHitbox()]);

  final Radius cornerRadius;
  bool _isCurved = false;
  bool get isCurved => _isCurved;
  bool _isExtended = false;
  Vector2 _originalSize = Vector2.zero();

  final _paint = Paint()
    ..color = const Color(0xff1e6091)
    ..style = PaintingStyle.fill;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    _originalSize = size;
  }

  void setCurved(bool curved) {
    _isCurved = curved;
  }

  void setExtended(bool extended) {
    _isExtended = extended;
    if (extended) {
      // Extender el bate al doble de ancho
      size = Vector2(_originalSize.x * 2, _originalSize.y);
    } else {
      size = _originalSize;
    }
    // Actualizar hitbox - remover hitbox anterior y agregar nuevo
    final hitboxes = children.whereType<RectangleHitbox>().toList();
    for (final hitbox in hitboxes) {
      hitbox.removeFromParent();
    }
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (_isCurved) {
      // Dibujar bate curvo (forma de arco)
      final path = Path();
      final rect = Offset.zero & size.toSize();
      final centerY = size.y / 2;
      
      // Crear forma curva (arco hacia arriba)
      path.moveTo(0, size.y);
      path.quadraticBezierTo(
        size.x / 2,
        -size.y * 0.3, // Curvatura hacia arriba
        size.x,
        size.y,
      );
      path.lineTo(size.x, size.y);
      path.lineTo(0, size.y);
      path.close();
      
      canvas.drawPath(path, _paint);
      
      // Dibujar borde
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, borderPaint);
    } else {
      // Dibujar bate normal
      canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size.toSize(), cornerRadius),
        _paint,
      );
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position.x = (position.x + event.localDelta.x).clamp(0, game.width);
  }

  void moveBy(double dx) {
    add(
      MoveToEffect(
        Vector2((position.x + dx).clamp(0, game.width), position.y),
        EffectController(duration: 0.1),
      ),
    );
  }
}
