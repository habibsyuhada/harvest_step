import "package:flutter/material.dart";

import "../../models/todo_task.dart";
import "../widgets/shared.dart";

class TodoPage extends StatefulWidget {
  final List<TodoTask> tasks;
  final int topazPoints;
  final void Function(TodoTask task) onAddTask;
  final void Function(int index, bool value) onToggleTask;

  const TodoPage({
    super.key,
    required this.tasks,
    required this.topazPoints,
    required this.onAddTask,
    required this.onToggleTask,
  });

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(
    text: "Umum",
  );
  String _selectedCategoryFilter = "Semua";
  RepeatCycle _selectedRepeat = RepeatCycle.none;

  @override
  void dispose() {
    _taskController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>{
      "Semua",
      "Umum",
      ...widget.tasks.map((t) => _categoryOf(t)),
    };
    final recurringTasks = widget.tasks
        .asMap()
        .entries
        .where(
          (entry) =>
              _repeatOf(entry.value) != RepeatCycle.none &&
              _matchesFilter(entry.value),
        )
        .toList();
    final oneTimeTasks = widget.tasks
        .asMap()
        .entries
        .where(
          (entry) =>
              _repeatOf(entry.value) == RepeatCycle.none &&
              _matchesFilter(entry.value),
        )
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleText("Todo Task"),
          const SizedBox(height: 8),
          const Text(
            "Checklist harian, setiap selesai task dapet Topaz point.",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Topaz point",
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.topazPoints}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _taskController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.restart_alt_rounded),
                  tooltip: "Clear input",
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _taskInputCard(),
          const SizedBox(height: 14),
          _categoryFilter(categories.toList()),
          if (recurringTasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            _recurringSection(recurringTasks),
          ],
          const SizedBox(height: 12),
          _tasksSection(oneTimeTasks),
        ],
      ),
    );
  }

  Widget _taskInputCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: "Tambah tugas",
            subtitle: "Kategori + repeat biar rapi dan terjadwal.",
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _taskController,
            decoration: const InputDecoration(
              labelText: "Nama tugas",
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submitTask(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              labelText: "Kategori",
              helperText: "Contoh: Kesehatan, Pekerjaan, Rumah",
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submitTask(),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final cat in {
                "Umum",
                "Kesehatan",
                "Pekerjaan",
                "Rumah",
                "Pribadi",
              })
                ChoiceChip(
                  label: Text(cat),
                  selected:
                      _categoryController.text.trim().toLowerCase() ==
                      cat.toLowerCase(),
                  onSelected: (_) {
                    _categoryController.text = cat;
                    setState(() {});
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<RepeatCycle>(
            initialValue: _selectedRepeat,
            decoration: const InputDecoration(
              labelText: "Repeat",
              border: OutlineInputBorder(),
            ),
            items: RepeatCycle.values
                .map(
                  (repeat) => DropdownMenuItem(
                    value: repeat,
                    child: Text(repeat.label),
                  ),
                )
                .toList(),
            onChanged: (repeat) {
              if (repeat == null) return;
              setState(() => _selectedRepeat = repeat);
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _submitTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              icon: const Icon(Icons.add_task_rounded),
              label: const Text("Tambah"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryFilter(List<String> categories) {
    final uniqueCategories = categories.toSet().toList()
      ..sort(
        (a, b) => a == "Semua"
            ? -1
            : b == "Semua"
            ? 1
            : a.toLowerCase().compareTo(b.toLowerCase()),
      );
    if (uniqueCategories.isEmpty) uniqueCategories.add("Semua");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Filter berdasarkan kategori",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: uniqueCategories
              .map(
                (cat) => ChoiceChip(
                  label: Text(cat),
                  selected:
                      _selectedCategoryFilter.toLowerCase() ==
                      cat.toLowerCase(),
                  onSelected: (_) {
                    setState(() => _selectedCategoryFilter = cat);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _recurringSection(List<MapEntry<int, TodoTask>> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SectionHeader(
              title: "Tugas berulang",
              subtitle: "Tugas rutin harian/mingguan.",
            ),
            TextButton.icon(
              onPressed: _resetRecurringStatus,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Reset selesai"),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _taskTile(entry.key, entry.value),
          ),
        ),
      ],
    );
  }

  Widget _tasksSection(List<MapEntry<int, TodoTask>> entries) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          "Belum ada tugas di kategori ini.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Semua tugas",
          subtitle: "Checklist harian dan tugas satu kali.",
        ),
        const SizedBox(height: 8),
        ...entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _taskTile(entry.key, entry.value),
          ),
        ),
      ],
    );
  }

  Widget _taskTile(int index, TodoTask task) {
    final repeat = _repeatOf(task);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: task.isDone,
                activeColor: Colors.orange,
                onChanged: (value) {
                  widget.onToggleTask(index, value ?? false);
                  setState(() {});
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: task.isDone ? Colors.black45 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _infoBadge(Icons.folder_rounded, _categoryOf(task)),
                        if (repeat != RepeatCycle.none)
                          _infoBadge(Icons.refresh_rounded, repeat.label),
                      ],
                    ),
                  ],
                ),
              ),
              if (task.isDone)
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.orange,
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitTask() {
    final text = _taskController.text.trim();
    final category = _categoryController.text.trim().isEmpty
        ? "Umum"
        : _categoryController.text.trim();
    if (text.isEmpty) return;
    widget.onAddTask(
      TodoTask(title: text, category: category, repeat: _selectedRepeat),
    );
    _taskController.clear();
    _categoryController.text = category;
    setState(() {});
  }

  bool _matchesFilter(TodoTask task) {
    final category = _categoryOf(task).toLowerCase();
    return _selectedCategoryFilter.toLowerCase() == "semua" ||
        category == _selectedCategoryFilter.toLowerCase();
  }

  void _resetRecurringStatus() {
    final entries = widget.tasks.asMap().entries.where(
      (entry) =>
          _repeatOf(entry.value) != RepeatCycle.none && entry.value.isDone,
    );
    for (final entry in entries) {
      widget.onToggleTask(entry.key, false);
    }
    setState(() {});
  }

  Widget _infoBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.orange, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _categoryOf(TodoTask task) {
    final value = task.category ?? "Umum";
    if (value.trim().isEmpty) return "Umum";
    return value;
  }

  RepeatCycle _repeatOf(TodoTask task) {
    final repeat = task.repeat ?? RepeatCycle.none;
    return repeat;
  }
}
