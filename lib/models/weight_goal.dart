enum WeightGoalDirection { lose, gain }

extension WeightGoalDirectionLabel on WeightGoalDirection {
  String get label => switch (this) {
        WeightGoalDirection.lose => "Lose weight",
        WeightGoalDirection.gain => "Gain weight",
      };
}
