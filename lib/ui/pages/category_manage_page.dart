import "package:flutter/material.dart";

import "../widgets/shared.dart";

class CategoryManagePage extends StatefulWidget {
  final List<String> categories;
  final void Function(List<String> categories) onCategoriesChanged;

  const CategoryManagePage({
    super.key,
    required this.categories,
    required this.onCategoriesChanged,
  });

  @override
  State<CategoryManagePage> createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends State<CategoryManagePage> {
  late List<String> _categories;
  final TextEditingController _newCategoryController = TextEditingController();
  final Map<String, bool> _editingStates = {};
  final Map<String, TextEditingController> _editControllers = {};

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
    // Remove "All" from the list as it's a filter option, not a real category
    _categories.removeWhere((c) => c == "All");
    // Ensure "General" exists as default
    if (!_categories.contains("General")) {
      _categories.insert(0, "General");
    }
    // Initialize editing states
    for (final category in _categories) {
      _editingStates[category] = false;
      _editControllers[category] = TextEditingController(text: category);
    }
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    for (final controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Category Management"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageTitleText("Category Management"),
            const SizedBox(height: 8),
            const Text(
              "Manage categories to organize your tasks.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: "Add New Category",
                    subtitle: "Add new category to organize tasks.",
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newCategoryController,
                          decoration: const InputDecoration(
                            labelText: "Category name",
                            border: OutlineInputBorder(),
                            hintText: "Example: Health, Work",
                          ),
                          onSubmitted: (_) => _addCategory(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _addCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text("Add"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: "Category List",
                    subtitle: "Available categories. Tap to edit or delete.",
                  ),
                  const SizedBox(height: 16),
                  if (_categories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "No categories yet. Add new category above.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  else
                    ..._categories.map(
                      (category) => _categoryTile(category),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTile(String category) {
    final isDefault = category == "General";
    final isEditing = _editingStates[category] ?? false;
    final editController = _editControllers[category]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: isEditing
          ? Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: editController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    autofocus: true,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final newName = editController.text.trim();
                    if (newName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Category name cannot be empty"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (newName != category && _categories.contains(newName)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Category already exists"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      final index = _categories.indexOf(category);
                      if (index != -1) {
                        _categories[index] = newName;
                        _editingStates[newName] = false;
                        _editingStates.remove(category);
                        _editControllers[newName] = editController;
                        _editControllers.remove(category);
                      }
                    });
                    _saveCategories();
                  },
                  icon: const Icon(Icons.check_rounded, color: Colors.green),
                  tooltip: "Save",
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _editingStates[category] = false;
                      editController.text = category;
                    });
                  },
                  icon: const Icon(Icons.close_rounded, color: Colors.red),
                  tooltip: "Cancel",
                ),
              ],
            )
          : Row(
              children: [
                Icon(
                  Icons.folder_rounded,
                  color: Colors.teal,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Default",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (!isDefault) ...[
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _editingStates[category] = true;
                      });
                    },
                    icon: const Icon(Icons.edit_rounded, color: Colors.blue),
                    tooltip: "Edit",
                  ),
                  IconButton(
                    onPressed: () => _deleteCategory(category),
                    icon: const Icon(Icons.delete_rounded, color: Colors.red),
                    tooltip: "Delete",
                  ),
                ],
              ],
            ),
    );
  }

  void _addCategory() {
    final newCategory = _newCategoryController.text.trim();
    if (newCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Category name cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_categories.contains(newCategory)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Category already exists"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _categories.add(newCategory);
      _editingStates[newCategory] = false;
      _editControllers[newCategory] = TextEditingController(text: newCategory);
      _newCategoryController.clear();
    });
    _saveCategories();
  }

  void _deleteCategory(String category) {
    if (category == "General") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Default category cannot be deleted"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category"),
        content: Text(
          "Are you sure you want to delete category \"$category\"?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _categories.remove(category);
                _editingStates.remove(category);
                _editControllers[category]?.dispose();
                _editControllers.remove(category);
              });
              _saveCategories();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _saveCategories() {
    widget.onCategoriesChanged(_categories);
  }
}

