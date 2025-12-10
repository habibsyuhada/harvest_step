enum WeightGoalDirection { lose, gain }

extension WeightGoalDirectionLabel on WeightGoalDirection {
  String get label => switch (this) {
        WeightGoalDirection.lose => "Turunkan berat",
        WeightGoalDirection.gain => "Naikkan berat",
      };
}
