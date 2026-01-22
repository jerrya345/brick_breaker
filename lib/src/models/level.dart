class Level {
  final int number;
  final int requiredScore;
  final double difficultyMultiplier;
  final int brickRows;
  final int brickCols;
  final bool hasEnemies;
  final int timeLimit; // en segundos

  Level({
    required this.number,
    required this.requiredScore,
    required this.difficultyMultiplier,
    required this.brickRows,
    required this.brickCols,
    this.hasEnemies = false,
    required this.timeLimit,
  });

  static List<Level> generateLevels() {
    final levels = <Level>[];
    for (int i = 1; i <= 50; i++) {
      final requiredScore = i == 1 ? 0 : 200 * (i - 1);
      final difficultyMultiplier = 1.0 + (i - 1) * 0.05;
      final brickRows = 5 + (i ~/ 5);
      final brickCols = 10 + (i ~/ 10);
      final hasEnemies = i >= 5;
      // Últimos 10 niveles tienen 120 segundos, el resto 200
      final timeLimit = i > 40 ? 120 : 200;

      levels.add(Level(
        number: i,
        requiredScore: requiredScore,
        difficultyMultiplier: difficultyMultiplier,
        brickRows: brickRows.clamp(5, 8),
        brickCols: brickCols.clamp(10, 12),
        hasEnemies: hasEnemies,
        timeLimit: timeLimit,
      ));
    }
    return levels;
  }
}
