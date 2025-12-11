import "dart:async";
import "dart:convert";

import "package:flutter/material.dart";
import "package:pedometer/pedometer.dart";
import "package:permission_handler/permission_handler.dart";
import "package:shared_preferences/shared_preferences.dart";

import "models/money_entry.dart";
import "models/todo_task.dart";
import "models/weight_goal.dart";
import "models/wellness_log.dart";
import "ui/pages/dashboard_page.dart";
import "ui/pages/energy_page.dart";
import "ui/pages/profile_page.dart";
import "ui/pages/quests_page.dart";
import "ui/pages/shop_page.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  late SharedPreferences _prefs;
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<PedestrianStatus>? _statusSubscription;
  int? _baselineSteps;
  DateTime? _baselineDate;
  int _displaySteps = 0;
  int _currentIndex = 0;
  String _status = '?';
  String? _stepError;
  final double _waterGoalLiters = 2;
  double _waterIntakeLiters = 0;
  int _hydrationPoints = 0;
  int _bodyPoints = 0;
  int _topazPoints = 0;
  int _diamondPoints = 0;
  WeightGoalDirection _weightGoalDirection = WeightGoalDirection.lose;
  final List<WellnessLog> _wellnessLogs = [];
  final List<TodoTask> _tasks = [
    TodoTask(
      title: "Stretch ringan 5 menit",
      category: "Kesehatan",
      repeat: RepeatCycle.daily,
    ),
    TodoTask(
      title: "Rapikan meja kerja",
      category: "Rumah",
      repeat: RepeatCycle.weekly,
    ),
    TodoTask(title: "Siapkan meal plan", category: "Kesehatan"),
  ];
  final List<MoneyEntry> _moneyEntries = [];

  static const int _stepsPerEnergy = 25;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  int get _sapphirePoints => _displaySteps ~/ _stepsPerEnergy;

  int get _stepsToNextSapphire {
    final remainder = _displaySteps % _stepsPerEnergy;
    return remainder == 0 ? 0 : _stepsPerEnergy - remainder;
  }

  double get _sapphireProgress {
    final remainder = _displaySteps % _stepsPerEnergy;
    return (remainder / _stepsPerEnergy).clamp(0, 1).toDouble();
  }

  int get _energyPoints => _sapphirePoints + _hydrationPoints + _bodyPoints;

  List<double> get _weightEntries => _wellnessLogs
      .where((l) => l.weight != null)
      .map((l) => l.weight!)
      .toList();

  void onStepCount(StepCount event) {
    final int current = event.steps;
    final now = DateTime.now();
    final bool isNewDay =
        _baselineDate == null || !_isSameDay(now, _baselineDate!);

    if (_baselineSteps == null || current < _baselineSteps! || isNewDay) {
      _baselineSteps = current;
      _baselineDate = now;
      _prefs.setInt('baselineSteps', _baselineSteps!);
      _prefs.setString('baselineDate', _baselineDate!.toIso8601String());
      _resetDailyTrackers();
    }

    setState(() {
      _displaySteps = current - (_baselineSteps ?? 0);
      _stepError = null;
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(Object error) {
    setState(() {
      _status = 'Pedestrian Status not available';
    });
  }

  void onStepCountError(Object error) {
    setState(() {
      _stepError = 'Step count not available';
    });
  }

  Future<bool> _checkActivityRecognitionPermission() async {
    bool granted = await Permission.activityRecognition.isGranted;

    if (!granted) {
      granted =
          await Permission.activityRecognition.request() ==
          PermissionStatus.granted;
    }

    return granted;
  }

  Future<void> initPlatformState() async {
    bool granted = await _checkActivityRecognitionPermission();
    if (!granted) {
      setState(() {
        _stepError = 'Permission for activity recognition is needed.';
      });
    }

    _prefs = await SharedPreferences.getInstance();
    _baselineSteps = _prefs.getInt('baselineSteps');
    final storedDate = _prefs.getString('baselineDate');
    _baselineDate = storedDate != null ? DateTime.tryParse(storedDate) : null;
    await _loadWellnessLogs();

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _statusSubscription = _pedestrianStatusStream.listen(
      onPedestrianStatusChanged,
      onError: onPedestrianStatusError,
    );

    _stepCountStream = Pedometer.stepCountStream;
    _stepSubscription = _stepCountStream.listen(
      onStepCount,
      onError: onStepCountError,
    );

    if (!mounted) return;
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _loadWellnessLogs() async {
    final stored = _prefs.getString('wellnessLogs');
    if (stored != null) {
      final List<dynamic> data = jsonDecode(stored);
      _wellnessLogs
        ..clear()
        ..addAll(
          data.whereType<Map<String, dynamic>>().map(
            (map) => WellnessLog.fromMap(map),
          ),
        );
    }
    final goalString = _prefs.getString('weightGoalDirection');
    if (goalString != null) {
      final loadedGoal = WeightGoalDirection.values.firstWhere(
        (g) => g.name == goalString,
        orElse: () => WeightGoalDirection.lose,
      );
      setState(() {
        _weightGoalDirection = loadedGoal;
      });
    }
    _trimWellnessLogs();
    _recomputeWellnessPoints();
  }

  void _saveWellnessLogs() {
    _trimWellnessLogs();
    _prefs.setString(
      'wellnessLogs',
      jsonEncode(_wellnessLogs.map((log) => log.toMap()).toList()),
    );
    _prefs.setString('weightGoalDirection', _weightGoalDirection.name);
  }

  void _trimWellnessLogs() {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    _wellnessLogs.removeWhere(
      (log) =>
          log.date.isBefore(DateTime(cutoff.year, cutoff.month, cutoff.day)),
    );
  }

  WellnessLog _getOrCreateTodayLog() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existingIndex = _wellnessLogs.indexWhere(
      (log) => _isSameDay(log.date, today),
    );
    if (existingIndex != -1) {
      return _wellnessLogs[existingIndex];
    }
    final newLog = WellnessLog(date: today);
    _wellnessLogs.add(newLog);
    _trimWellnessLogs();
    return newLog;
  }

  void _recomputeWellnessPoints() {
    final today = DateTime.now();
    final sortedLogs = [..._wellnessLogs]
      ..sort((a, b) => a.date.compareTo(b.date));

    int hydrationPoints = 0;
    double todayWater = 0;
    for (final log in sortedLogs) {
      if (log.waterLiters >= _waterGoalLiters) {
        hydrationPoints++;
      }
      if (_isSameDay(log.date, today)) {
        todayWater = log.waterLiters;
      }
    }

    int bodyPoints = 0;
    final weightLogs = sortedLogs
        .where((log) => log.weight != null)
        .toList(growable: false);
    for (var i = 1; i < weightLogs.length; i++) {
      final prev = weightLogs[i - 1].weight!;
      final curr = weightLogs[i].weight!;
      final progressed = _weightGoalDirection == WeightGoalDirection.lose
          ? curr < prev
          : curr > prev;
      if (progressed) bodyPoints++;
    }

    setState(() {
      _hydrationPoints = hydrationPoints;
      _bodyPoints = bodyPoints;
      _waterIntakeLiters = todayWater;
    });
  }

  void _resetDailyTrackers() {
    final log = _getOrCreateTodayLog();
    log.waterLiters = 0;
    _saveWellnessLogs();
    _recomputeWellnessPoints();
  }

  void _addWater(double liters) {
    if (liters <= 0) return;
    final log = _getOrCreateTodayLog();
    log.waterLiters += liters;
    _saveWellnessLogs();
    _recomputeWellnessPoints();
  }

  void _addWeight(double weight) {
    if (weight <= 0) return;
    final log = _getOrCreateTodayLog();
    log.weight = weight;
    _saveWellnessLogs();
    _recomputeWellnessPoints();
  }

  void _updateWeightGoal(WeightGoalDirection goal) {
    setState(() {
      _weightGoalDirection = goal;
    });
    _saveWellnessLogs();
    _recomputeWellnessPoints();
  }

  void _toggleTask(int index, bool value) {
    setState(() {
      if (!_tasks[index].isDone && value) {
        _topazPoints++;
      }
      _tasks[index].isDone = value;
    });
  }

  void _addTask(TodoTask task) {
    final text = task.title.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks.add(
        TodoTask(title: text, category: task.category, repeat: task.repeat),
      );
    });
  }

  void _addMoneyEntry(String label, double amount) {
    final entryLabel = label.trim();
    if (entryLabel.isEmpty || amount <= 0) return;
    setState(() {
      final double? previous = _moneyEntries.isNotEmpty
          ? _moneyEntries.last.amount
          : null;
      _moneyEntries.add(
        MoneyEntry(label: entryLabel, amount: amount, date: DateTime.now()),
      );
      if (previous != null && amount > previous) {
        _diamondPoints++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Harvest Step',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF7F7F9),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              DashboardPage(
                displaySteps: _displaySteps,
                sapphirePoints: _sapphirePoints,
                sapphireProgress: _sapphireProgress,
                stepsToNextSapphire: _stepsToNextSapphire,
                energyPoints: _energyPoints,
                hydrationPoints: _hydrationPoints,
                status: _status,
                stepError: _stepError,
                waterGoalLiters: _waterGoalLiters,
                waterIntakeLiters: _waterIntakeLiters,
                onAddWater: _addWater,
                weightEntries: _weightEntries,
                weightGoalDirection: _weightGoalDirection,
                onAddWeight: _addWeight,
                onUpdateWeightGoal: _updateWeightGoal,
                bodyPoints: _bodyPoints,
              ),
              TodoPage(
                tasks: _tasks,
                topazPoints: _topazPoints,
                onAddTask: _addTask,
                onToggleTask: _toggleTask,
              ),
              MoneyPage(
                entries: _moneyEntries,
                onAddEntry: _addMoneyEntry,
                diamondPoints: _diamondPoints,
              ),
              const GamePlaceholderPage(),
              ProfilePage(
                displaySteps: _displaySteps,
                sapphirePoints: _sapphirePoints,
                energyPoints: _energyPoints,
                status: _status,
                topazPoints: _topazPoints,
                diamondPoints: _diamondPoints,
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.health_and_safety_rounded),
              label: 'Wellness',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_rounded),
              label: 'Todo',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_rounded),
              label: 'Money',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports_rounded),
              label: 'Game',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
