import "dart:async";

import "package:flutter/material.dart";
import "package:pedometer/pedometer.dart";
import "package:permission_handler/permission_handler.dart";
import "package:shared_preferences/shared_preferences.dart";

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

  static const int _stepsPerEnergy = 25;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  int get _energyPoints => _displaySteps ~/ _stepsPerEnergy;

  int get _stepsToNextEnergy {
    final remainder = _displaySteps % _stepsPerEnergy;
    return remainder == 0 ? 0 : _stepsPerEnergy - remainder;
  }

  double get _energyProgress {
    final remainder = _displaySteps % _stepsPerEnergy;
    return (remainder / _stepsPerEnergy).clamp(0, 1).toDouble();
  }

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
      granted = await Permission.activityRecognition.request() ==
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
    _baselineDate =
        storedDate != null ? DateTime.tryParse(storedDate) : null;

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
                energyPoints: _energyPoints,
                energyProgress: _energyProgress,
                stepsToNextEnergy: _stepsToNextEnergy,
                status: _status,
                stepError: _stepError,
              ),
              QuestsPage(
                displaySteps: _displaySteps,
                stepsPerEnergy: _stepsPerEnergy,
              ),
              EnergyPage(
                energyPoints: _energyPoints,
                stepsToNextEnergy: _stepsToNextEnergy,
              ),
              ShopPage(energyPoints: _energyPoints),
              ProfilePage(
                displaySteps: _displaySteps,
                energyPoints: _energyPoints,
                status: _status,
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
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flag_rounded),
              label: 'Quests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bolt_rounded),
              label: 'Energy',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_rounded),
              label: 'Shop',
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
