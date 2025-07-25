class RiskPrediction {
  final double score;

  RiskPrediction({required this.score});

  factory RiskPrediction.fromRawString(String raw) {
    return RiskPrediction(score: double.parse(raw));
  }
}
