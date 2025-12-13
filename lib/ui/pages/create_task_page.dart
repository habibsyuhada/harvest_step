import "package:flutter/material.dart";

import "../../models/todo_task.dart";
import "../widgets/shared.dart";

class CreateTaskPage extends StatefulWidget {
  final TodoTask? task;
  final List<String> categories;
  final void Function(TodoTask task) onSubmit;
  final void Function()? onDelete;

  const CreateTaskPage({
    super.key,
    this.task,
    required this.categories,
    required this.onSubmit,
    this.onDelete,
  });

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  late TextEditingController _taskController;
  late TextEditingController _categoryController;
  late RepeatCycle _selectedRepeat;
  late Set<int> _selectedDays; // 1=Monday, 7=Sunday
  late List<TodoChecklistItem> _checklist;
  final Map<int, TextEditingController> _checklistControllers = {};

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.task?.title ?? "");
    _categoryController = TextEditingController(
      text: widget.task?.category ?? "General",
    );
    _selectedRepeat = widget.task?.repeat ?? RepeatCycle.none;
    _selectedDays = Set.from(widget.task?.weeklyDays ?? []);
    _checklist = widget.task?.checklist != null
        ? widget.task!.checklist!.map((item) => TodoChecklistItem(
              text: item.text,
              isDone: item.isDone,
            )).toList()
        : [];
    for (var i = 0; i < _checklist.length; i++) {
      _checklistControllers[i] = TextEditingController(text: _checklist[i].text);
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _categoryController.dispose();
    for (final controller in _checklistControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = widget.categories.isEmpty
        ? ["General"]
        : widget.categories.where((c) => c != "All").toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "Add Task" : "Edit Task"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: widget.onDelete != null
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Task"),
                        content: Text(
                          "Are you sure you want to delete task \"${widget.task?.title}\"?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onDelete!();
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text("Delete"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageTitleText(
              widget.task == null ? "Add New Task" : "Edit Task",
            ),
            const SizedBox(height: 8),
            const Text(
              "Fill in task details completely to make tracking easier.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: "Task Details",
                    subtitle: "Category + repeat to keep organized and scheduled.",
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      labelText: "Task name",
                      border: OutlineInputBorder(),
                      hintText: "Example: Light stretch 5 minutes",
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _categoryController.text.isEmpty
                        ? null
                        : _categoryController.text,
                    decoration: const InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(),
                      helperText: "Choose appropriate category",
                    ),
                    items: availableCategories
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _categoryController.text = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  if (availableCategories.isNotEmpty) ...[
                    const Text(
                      "Quick categories:",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableCategories
                          .map(
                            (cat) => ChoiceChip(
                              label: Text(cat),
                              selected: _categoryController.text.trim() == cat,
                              onSelected: (_) {
                                setState(() {
                                  _categoryController.text = cat;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  DropdownButtonFormField<RepeatCycle>(
                    initialValue: _selectedRepeat,
                    decoration: const InputDecoration(
                      labelText: "Repeat",
                      border: OutlineInputBorder(),
                      helperText: "Choose task repetition pattern",
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
                      if (repeat != null) {
                        setState(() {
                          _selectedRepeat = repeat;
                          if (repeat != RepeatCycle.weekly) {
                            _selectedDays.clear();
                          }
                        });
                      }
                    },
                  ),
                  if (_selectedRepeat == RepeatCycle.weekly) ...[
                    const SizedBox(height: 16),
                    const Text(
                      "Select days:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _dayChip(1, "Monday"),
                        _dayChip(2, "Tuesday"),
                        _dayChip(3, "Wednesday"),
                        _dayChip(4, "Thursday"),
                        _dayChip(5, "Friday"),
                        _dayChip(6, "Saturday"),
                        _dayChip(7, "Sunday"),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Checklist",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addChecklistItem,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text("Add Item"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_checklist.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No checklist yet. Add checklist items to break down tasks into smaller steps.",
                        style: TextStyle(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...List.generate(
                      _checklist.length,
                      (index) => _checklistItem(index),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _submitTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        widget.task == null
                            ? Icons.add_task_rounded
                            : Icons.save_rounded,
                      ),
                      label: Text(
                        widget.task == null ? "Add Task" : "Save Changes",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayChip(int day, String label) {
    final isSelected = _selectedDays.contains(day);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedDays.add(day);
          } else {
            _selectedDays.remove(day);
          }
        });
      },
    );
  }

  void _addChecklistItem() {
    setState(() {
      final index = _checklist.length;
      _checklist.add(TodoChecklistItem(text: ""));
      _checklistControllers[index] = TextEditingController();
    });
  }

  void _removeChecklistItem(int index) {
    setState(() {
      _checklistControllers[index]?.dispose();
      _checklistControllers.remove(index);
      _checklist.removeAt(index);
      // Rebuild controllers map
      final newControllers = <int, TextEditingController>{};
      for (var i = 0; i < _checklist.length; i++) {
        if (_checklistControllers.containsKey(i)) {
          newControllers[i] = _checklistControllers[i]!;
        } else {
          newControllers[i] = TextEditingController(text: _checklist[i].text);
        }
      }
      _checklistControllers.clear();
      _checklistControllers.addAll(newControllers);
    });
  }

  Widget _checklistItem(int index) {
    if (!_checklistControllers.containsKey(index)) {
      _checklistControllers[index] = TextEditingController(
        text: _checklist[index].text,
      );
    }
    final controller = _checklistControllers[index]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Item checklist ${index + 1}",
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                _checklist[index].text = value;
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _removeChecklistItem(index),
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            tooltip: "Delete",
          ),
        ],
      ),
    );
  }

  void _submitTask() {
    final text = _taskController.text.trim();
    final category = _categoryController.text.trim().isEmpty
        ? "General"
        : _categoryController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task name cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedRepeat == RepeatCycle.weekly && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select at least one day for weekly tasks"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final weeklyDaysList = _selectedRepeat == RepeatCycle.weekly
        ? (List<int>.from(_selectedDays)..sort())
        : null;
    final checklistList = _checklist
        .where((item) => item.text.trim().isNotEmpty)
        .map((item) => TodoChecklistItem(text: item.text.trim()))
        .toList();
    widget.onSubmit(
      TodoTask(
        title: text,
        category: category,
        repeat: _selectedRepeat,
        weeklyDays: weeklyDaysList,
        checklist: checklistList.isEmpty ? null : checklistList,
      ),
    );
    Navigator.of(context).pop();
  }
}

