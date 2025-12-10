class WellnessLog {
  WellnessLog({
    required this.date,
    this.waterLiters = 0,
    this.weight,
  });

  final DateTime date;
  double waterLiters;
  double? weight;

  Map<String, dynamic> toMap() => {
        "date": date.toIso8601String(),
        "waterLiters": waterLiters,
        "weight": weight,
      };

  static WellnessLog fromMap(Map<String, dynamic> map) {
    return WellnessLog(
      date: DateTime.parse(map["date"] as String),
      waterLiters: (map["waterLiters"] as num?)?.toDouble() ?? 0,
      weight: (map["weight"] as num?)?.toDouble(),
    );
  }
}
