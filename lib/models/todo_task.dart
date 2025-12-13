enum RepeatCycle { none, daily, weekly }

extension RepeatCycleLabel on RepeatCycle {
  String get label {
    switch (this) {
      case RepeatCycle.none:
        return "No repeat";
      case RepeatCycle.daily:
        return "Daily";
      case RepeatCycle.weekly:
        return "Weekly";
    }
  }
}

class TodoChecklistItem {
  TodoChecklistItem({
    required this.text,
    this.isDone = false,
  });

  String text;
  bool isDone;
}

class TodoTask {
  TodoTask({
    required this.title,
    this.category = "General",
    this.repeat = RepeatCycle.none,
    this.weeklyDays,
    this.isDone = false,
    this.checklist,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String title;
  String? category;
  RepeatCycle? repeat;
  List<int>? weeklyDays; // 1=Monday, 7=Sunday
  bool isDone;
  List<TodoChecklistItem>? checklist;
  DateTime createdAt;
}
