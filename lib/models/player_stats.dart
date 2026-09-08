class PlayerStats {
  int highScore;
  int collectedCoins;
  int currentLevel;

  PlayerStats({
    this.highScore = 0,
    this.collectedCoins = 0,
    this.currentLevel = 1,
  });

  Map<String, dynamic> toJson() => {
        'highScore': highScore,
        'collectedCoins': collectedCoins,
        'currentLevel': currentLevel,
      };

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      highScore: json['highScore'] ?? 0,
      collectedCoins: json['collectedCoins'] ?? 0,
      currentLevel: json['currentLevel'] ?? 1,
    );
  }
}
