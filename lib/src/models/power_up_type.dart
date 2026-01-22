enum PowerUpType {
  tripleBall,    // Multiplica la pelota en 3
  curvedBat,     // Hace la plataforma curva
  extendedBat,   // Extiende la barra para tapar el hueco
}

extension PowerUpTypeExtension on PowerUpType {
  String get name {
    switch (this) {
      case PowerUpType.tripleBall:
        return 'TRIPLE BALL';
      case PowerUpType.curvedBat:
        return 'CURVED BAT';
      case PowerUpType.extendedBat:
        return 'EXTENDED BAT';
    }
  }

  String get description {
    switch (this) {
      case PowerUpType.tripleBall:
        return '3 balls at once!';
      case PowerUpType.curvedBat:
        return 'Curved platform';
      case PowerUpType.extendedBat:
        return 'Extended bat for 30s';
    }
  }
}
