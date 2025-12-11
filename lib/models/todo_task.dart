enum RepeatCycle { none, daily, weekly }

extension RepeatCycleLabel on RepeatCycle {
  String get label {
    switch (this) {
      case RepeatCycle.none:
        return "Tidak berulang";
      case RepeatCycle.daily:
        return "Harian";
      case RepeatCycle.weekly:
        return "Mingguan";
    }
  }
}

class TodoTask {
  TodoTask({
    required this.title,
    this.category = "Umum",
    this.repeat = RepeatCycle.none,
    this.isDone = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String title;
  String? category;
  RepeatCycle? repeat;
  bool isDone;
  DateTime createdAt;
}
