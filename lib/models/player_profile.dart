class PlayerProfile {
  final String title;
  final String badge;
  final int minScore;

  PlayerProfile({required this.title, required this.badge, required this.minScore});

  static PlayerProfile getProfileForScore(int score) {
    if (score >= 10000) {
      return PlayerProfile(title: 'CYBER GOD', badge: '👑', minScore: 10000);
    } else if (score >= 5000) {
      return PlayerProfile(title: 'NEON PHANTOM', badge: '⚡', minScore: 5000);
    } else if (score >= 2000) {
      return PlayerProfile(title: 'STREET RUNNER', badge: '🔥', minScore: 2000);
    } else {
      return PlayerProfile(title: 'ROOKIE OPERATIVE', badge: '🤖', minScore: 0);
    }
  }
}
