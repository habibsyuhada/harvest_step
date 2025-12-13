import "package:flutter/material.dart";

import "../../models/todo_task.dart";
import "../widgets/shared.dart";
import "create_task_page.dart";
import "category_manage_page.dart";

class TodoPage extends StatefulWidget {
  final List<TodoTask> tasks;
  final int achievementPoints;
  final List<String> categories;
  final void Function(TodoTask task) onAddTask;
  final void Function(int index, TodoTask task) onUpdateTask;
  final void Function(int index) onDeleteTask;
  final void Function(int index, bool value) onToggleTask;
  final void Function(List<String> categories) onCategoriesChanged;

  const TodoPage({
    super.key,
    required this.tasks,
    required this.achievementPoints,
    required this.categories,
    required this.onAddTask,
    required this.onUpdateTask,
    required this.onDeleteTask,
    required this.onToggleTask,
    required this.onCategoriesChanged,
  });

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  String _selectedCategoryFilter = "All";

  @override
  Widget build(BuildContext context) {
    final allCategories = <String>{
      "All",
      ...widget.categories,
      ...widget.tasks.map((t) => _categoryOf(t)),
    };
    final filteredTasks = widget.tasks
        .asMap()
        .entries
        .where((entry) => _matchesFilter(entry.value))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageTitleText("Todo Task"),
          const SizedBox(height: 8),
          const Text(
            "Daily checklist, complete tasks to earn Achievement points.",
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
                        "Achievement point",
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${widget.achievementPoints}",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _actionButtons(),
          const SizedBox(height: 14),
          _categoryFilter(allCategories.toList()),
          const SizedBox(height: 12),
          _tasksSection(filteredTasks),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateTaskPage(
                    categories: widget.categories,
                    onSubmit: widget.onAddTask,
                  ),
                ),
              );
              if (result != null) {
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.add_task_rounded),
            label: const Text("Add Task"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CategoryManagePage(
                    categories: widget.categories,
                    onCategoriesChanged: widget.onCategoriesChanged,
                  ),
                ),
              );
              setState(() {});
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.teal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.category_rounded),
            label: const Text("Manage Categories"),
          ),
        ),
      ],
    );
  }

  Widget _categoryFilter(List<String> categories) {
    final uniqueCategories = categories.toSet().toList()
      ..sort(
        (a, b) => a == "All"
            ? -1
            : b == "All"
            ? 1
            : a.toLowerCase().compareTo(b.toLowerCase()),
      );
    if (uniqueCategories.isEmpty) uniqueCategories.add("All");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Filter by category",
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

  Widget _tasksSection(List<MapEntry<int, TodoTask>> entries) {
    if (entries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          "No tasks in this category yet.",
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "All tasks",
          subtitle: "Daily checklist and one-time tasks.",
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateTaskPage(
                task: task,
                categories: widget.categories,
                onSubmit: (updatedTask) {
                  widget.onUpdateTask(index, updatedTask);
                },
                onDelete: () {
                  Navigator.of(context).pop();
                  _confirmDeleteTask(index, task);
                },
              ),
            ),
          );
          if (result != null) {
            setState(() {});
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: AppCard(
          child: Row(
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
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: task.isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isDone ? Colors.black45 : Colors.black87,
                  ),
                ),
              ),
              if (task.isDone)
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.orange,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteTask(int index, TodoTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: Text("Are you sure you want to delete task \"${task.title}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              widget.onDeleteTask(index);
              Navigator.of(context).pop();
              setState(() {});
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }


  bool _matchesFilter(TodoTask task) {
    final category = _categoryOf(task).toLowerCase();
    return _selectedCategoryFilter.toLowerCase() == "all" ||
        category == _selectedCategoryFilter.toLowerCase();
  }

  String _categoryOf(TodoTask task) {
    final value = task.category ?? "General";
    if (value.trim().isEmpty) return "General";
    return value;
  }
}
