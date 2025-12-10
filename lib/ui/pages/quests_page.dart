import "package:flutter/material.dart";

import "../../models/todo_task.dart";
import "../widgets/shared.dart";

class TodoPage extends StatefulWidget {
  final List<TodoTask> tasks;
  final int topazPoints;
  final void Function(String title) onAddTask;
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

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  child: const Icon(Icons.check_circle_rounded,
                      color: Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Topaz point",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
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
          _taskInput(),
          const SizedBox(height: 12),
          ...widget.tasks.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _taskTile(entry.key, entry.value),
                ),
              ),
        ],
      ),
    );
  }

  Widget _taskInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _taskController,
            decoration: const InputDecoration(
              labelText: "Tambah tugas",
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submitTask(),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _submitTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          child: const Text("Tambah"),
        ),
      ],
    );
  }

  Widget _taskTile(int index, TodoTask task) {
    return AppCard(
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
                fontWeight: FontWeight.w600,
                decoration:
                    task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
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
    );
  }

  void _submitTask() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;
    widget.onAddTask(text);
    _taskController.clear();
    setState(() {});
  }
}
