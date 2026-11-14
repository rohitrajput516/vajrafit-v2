import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const VajraFitApp());
}

// ============================================================================
// VOICE COACH ENGINE (OFFLINE HINDI + ENGLISH TTS)
// ============================================================================
class VoiceCoach {
  static final FlutterTts _tts = FlutterTts();
  static bool isHindi = true;
  static bool isMuted = false;

  static Future<void> init() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.48);
    await _tts.setPitch(1.0);
    await setLanguage(isHindi);
  }

  static Future<void> setLanguage(bool hindi) async {
    isHindi = hindi;
    await _tts.setLanguage(hindi ? "hi-IN" : "en-IN");
  }

  static Future<void> speak(String hiText, String enText) async {
    if (isMuted) return;
    await _tts.stop();
    await _tts.speak(isHindi ? hiText : enText);
  }
}

// ============================================================================
// MAIN APP & DUAL ADAPTIVE THEME (SUNLIGHT DAY MODE + TACTICAL DARK MODE)
// ============================================================================
class VajraFitApp extends StatefulWidget {
  const VajraFitApp({super.key});

  @override
  State<VajraFitApp> createState() => _VajraFitAppState();
}

class _VajraFitAppState extends State<VajraFitApp> {
  // false = High-Contrast Outdoor Sunlight Mode, true = Indoor Tactical Dark Mode
  bool _isDarkMode = false;
  bool _isHindiVoice = true;

  @override
  void initState() {
    super.initState();
    VoiceCoach.init();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _isHindiVoice = prefs.getBool('isHindiVoice') ?? true;
    });
    VoiceCoach.setLanguage(_isHindiVoice);
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = !_isDarkMode);
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> _toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isHindiVoice = !_isHindiVoice);
    await prefs.setBool('isHindiVoice', _isHindiVoice);
    await VoiceCoach.setLanguage(_isHindiVoice);
    VoiceCoach.speak(
      "Hindi voice coach chalu hai. Taiyar ho jao!",
      "English voice coach activated. Get ready!",
    );
  }

  @override
  Widget build(BuildContext context) {
    final sunlightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      primaryColor: const Color(0xFFF97316),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFF97316), // Tactical Orange
        secondary: Color(0xFF4D7C0F), // Military Olive/Lime
        surface: Colors.white,
        onSurface: Color(0xFF0F172A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );

    final tacticalDarkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B1120),
      primaryColor: const Color(0xFF10B981),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF10B981), // Tactical Emerald
        secondary: Color(0xFFF97316), // High-Vis Orange
        surface: Color(0xFF1E293B),
        onSurface: Color(0xFFF8FAFC),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );

    return MaterialApp(
      title: 'VajraFit Coach',
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? tacticalDarkTheme : sunlightTheme,
      home: MainShell(
        isDarkMode: _isDarkMode,
        isHindiVoice: _isHindiVoice,
        onToggleTheme: _toggleTheme,
        onToggleLanguage: _toggleLanguage,
      ),
    );
  }
}

// ============================================================================
// NAVIGATION SHELL
// ============================================================================
class MainShell extends StatefulWidget {
  final bool isDarkMode;
  final bool isHindiVoice;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLanguage;

  const MainShell({
    super.key,
    required this.isDarkMode,
    required this.isHindiVoice,
    required this.onToggleTheme,
    required this.onToggleLanguage,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      const RunCoachScreen(),
      const RepCounterScreen(),
      const PftSimulatorScreen(),
      const StaminaAndDietScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shield, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'VAJRAFIT',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
                fontSize: 19,
              ),
            ),
          ],
        ),
        actions: [
          // Hindi / English Voice Toggle
          TextButton.icon(
            onPressed: widget.onToggleLanguage,
            icon: const Icon(Icons.record_voice_over, color: Colors.amber, size: 18),
            label: Text(
              widget.isHindiVoice ? 'HI' : 'EN',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Sunlight / Tactical Dark Theme Toggle
          IconButton(
            tooltip: widget.isDarkMode ? 'Switch to Sunlight Mode' : 'Switch to Tactical Dark',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              color: widget.isDarkMode ? Colors.amber : Colors.orangeAccent,
            ),
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.military_tech), label: 'HQ'),
          NavigationDestination(icon: Icon(Icons.directions_run), label: '1600m Run'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'AI Reps'),
          NavigationDestination(icon: Icon(Icons.timer), label: 'Bharti Test'),
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Diet & Lung'),
        ],
      ),
    );
  }
}

// ============================================================================
// 1. HQ DASHBOARD, MILITARY RANK, BMI & BACKUP
// ============================================================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _xp = 0;
  int _totalRuns = 0;
  int _totalReps = 0;
  int _streakDays = 1;
  double _best1600mSec = 0;
  double _heightCm = 166;
  double _weightKg = 58;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _xp = prefs.getInt('xp') ?? 120;
      _totalRuns = prefs.getInt('totalRuns') ?? 0;
      _totalReps = prefs.getInt('totalReps') ?? 0;
      _streakDays = prefs.getInt('streakDays') ?? 1;
      _best1600mSec = prefs.getDouble('best1600mSec') ?? 0;
      _heightCm = prefs.getDouble('heightCm') ?? 166;
      _weightKg = prefs.getDouble('weightKg') ?? 58;
    });
  }

  String _getRankTitle() {
    if (_xp >= 2500) return 'PARA COMMANDO';
    if (_xp >= 1500) return 'CAPTAIN';
    if (_xp >= 800) return 'LIEUTENANT';
    if (_xp >= 300) return 'CADET';
    return 'RECRUIT';
  }

  int _getNextRankXp() {
    if (_xp < 300) return 300;
    if (_xp < 800) return 800;
    if (_xp < 1500) return 1500;
    if (_xp < 2500) return 2500;
    return 5000;
  }

  void _shareProgressCard() {
    final bestRunStr = _best1600mSec > 0
        ? '${(_best1600mSec ~/ 60)}m ${(_best1600mSec % 60).toInt()}s'
        : 'Not set';
    final msg = '''
🛡️ *VAJRAFIT DEFENCE REPORT* 🛡️
🎖️ Rank: ${_getRankTitle()} ($_xp XP)
🔥 Discipline Streak: $_streakDays Days
🏃 Total Runs Completed: $_totalRuns (1600m Best: $bestRunStr)
💪 Total Strength Reps: $_totalReps
⚡ Train Hard. Zero Excuses!
''';
    Share.share(msg);
  }

  Future<void> _exportBackupJson() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'xp': _xp,
      'totalRuns': _totalRuns,
      'totalReps': _totalReps,
      'streakDays': _streakDays,
      'best1600mSec': _best1600mSec,
      'heightCm': _heightCm,
      'weightKg': _weightKg,
    };
    await Share.share(jsonEncode(data), subject: 'VajraFit_Backup.json');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup JSON ready to save or share!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bmi = _weightKg / pow(_heightCm / 100, 2);
    final nextXp = _getNextRankXp();
    final progress = (_xp / nextXp).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rank Banner Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.primary.withOpacity(0.5), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    backgroundColor: cs.primary,
                    label: Text(
                      _getRankTitle(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '🔥 $_streakDays Day Streak',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'XP: $_xp / $nextXp',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: Colors.white12,
                color: cs.primary,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _shareProgressCard,
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Share Report Card'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: 'Export Offline JSON Backup',
                    onPressed: _exportBackupJson,
                    icon: const Icon(Icons.download),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Key Metrics Grid
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: '1600m Best',
                value: _best1600mSec > 0
                    ? '${(_best1600mSec ~/ 60)}:${(_best1600mSec % 60).toInt().toString().padLeft(2, '0')}'
                    : '--:--',
                subtitle: 'Target: 05:30',
                icon: Icons.timer_outlined,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Total Reps',
                value: '$_totalReps',
                subtitle: 'Pushup/Squat/Situp',
                icon: Icons.fitness_center,
                color: cs.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Defence BMI & Weight Gain Calculator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.onSurface.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DEFENCE BMI & CHEST/WEIGHT STANDARD',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Height: ${_heightCm.toInt()} cm'),
                  Text('Weight: ${_weightKg.toStringAsFixed(1)} kg'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (bmi >= 18.5 && bmi <= 25)
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'BMI: ${bmi.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (bmi >= 18.5 && bmi <= 25) ? Colors.green : Colors.deepOrange,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: _weightKg,
                min: 40,
                max: 95,
                divisions: 110,
                label: '${_weightKg.toStringAsFixed(1)} kg',
                onChanged: (v) async {
                  setState(() => _weightKg = v);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setDouble('weightKg', v);
                },
              ),
              Text(
                bmi < 18.5
                    ? 'Tip: Increase daily milk, curd, chana & dumbbell chest workouts to gain solid mass.'
                    : 'Status: Fit for NDA & Air Force Agniveervayu Medical Standard!',
                style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(0.75)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
          ),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. 1600m / 5km SMART GPS VOICE RUN COACH + GHOST PACER
// ============================================================================
class RunCoachScreen extends StatefulWidget {
  const RunCoachScreen({super.key});

  @override
  State<RunCoachScreen> createState() => _RunCoachScreenState();
}

class _RunCoachScreenState extends State<RunCoachScreen> {
  double _targetDistanceM = 1600;
  int _targetTimeSec = 330; // 5:30 default
  bool _isRunning = false;
  bool _simulationMode = false;
  bool _metronomeOn = false;

  double _coveredDistanceM = 0.0;
  int _elapsedSec = 0;
  int _lastAnnouncedLap = 0;

  Timer? _clockTimer;
  Timer? _metronomeTimer;
  StreamSubscription<Position>? _gpsSub;
  Position? _lastPos;

  void _startRun() async {
    if (!_simulationMode) {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GPS Permission denied! Switched to Indoor Track Simulation Mode.'),
            ),
          );
        }
        setState(() => _simulationMode = true);
      }
    }

    setState(() {
      _isRunning = true;
      _coveredDistanceM = 0;
      _elapsedSec = 0;
      _lastAnnouncedLap = 0;
      _lastPos = null;
    });

    VoiceCoach.speak(
      "${_targetDistanceM.toInt()} meter daud shuru! Target time ${_targetTimeSec ~/ 60} minute ${_targetTimeSec % 60} second. Shuru mein kadam lambe rakho!",
      "${_targetDistanceM.toInt()} meters run started! Maintain steady pace.",
    );

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSec++;
        if (_simulationMode) {
          // Simulate ~4.9 meters/sec (~5:25 for 1600m)
          _coveredDistanceM += 4.9;
        }
      });
      _checkPaceAndAnnounce();
    });

    if (!_simulationMode) {
      _gpsSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 2,
        ),
      ).listen((Position pos) {
        if (_lastPos != null) {
          final d = Geolocator.distanceBetween(
            _lastPos!.latitude,
            _lastPos!.longitude,
            pos.latitude,
            pos.longitude,
          );
          if (d > 0.5 && d < 25) {
            setState(() => _coveredDistanceM += d);
          }
        }
        _lastPos = pos;
      });
    }
  }

  void _checkPaceAndAnnounce() {
    // Check every 200m split
    final currentLap = (_coveredDistanceM ~/ 200);
    if (currentLap > _lastAnnouncedLap && _coveredDistanceM < _targetDistanceM) {
      _lastAnnouncedLap = currentLap;
      final distDone = currentLap * 200;
      final distLeft = (_targetDistanceM - _coveredDistanceM).toInt();
      final expectedSecAtThisPoint = (_targetTimeSec * (distDone / _targetDistanceM)).toInt();
      final diff = expectedSecAtThisPoint - _elapsedSec;

      if (diff >= 0) {
        VoiceCoach.speak(
          "$distDone meter poore! Aap target se $diff second aage chal rahe hain. Speed banaye rakho, sirf $distLeft meter baki hai!",
          "$distDone meters completed! You are $diff seconds ahead of target. $distLeft meters remaining!",
        );
      } else {
        final behind = diff.abs();
        VoiceCoach.speak(
          "$distDone meter poore! Aap target se $behind second peeche hain! Kadam tez karo, $distLeft meter bacha hai, jaldi bhago!",
          "$distDone meters done! You are $behind seconds behind target. Speed up now, $distLeft meters left!",
        );
      }
    }

    if (_coveredDistanceM >= _targetDistanceM) {
      _finishRun();
    }
  }

  Future<void> _finishRun() async {
    _stopTimers();
    final mins = _elapsedSec ~/ 60;
    final secs = _elapsedSec % 60;
    final passed = _elapsedSec <= _targetTimeSec;

    VoiceCoach.speak(
      passed
          ? "Shabaash Fauji! Daud poori hui $mins minute $secs second mein! Aapne target pass kar liya!"
          : "Daud poori hui $mins minute $secs second mein. Target se thoda peeche reh gaye, kal aur zor lagana!",
      passed
          ? "Run completed in $mins minutes $secs seconds! Target achieved!"
          : "Run completed in $mins minutes $secs seconds. Keep pushing!",
    );

    final prefs = await SharedPreferences.getInstance();
    final xp = (prefs.getInt('xp') ?? 120) + 100;
    final runs = (prefs.getInt('totalRuns') ?? 0) + 1;
    await prefs.setInt('xp', xp);
    await prefs.setInt('totalRuns', runs);

    if (_targetDistanceM == 1600) {
      final prevBest = prefs.getDouble('best1600mSec') ?? 9999;
      if (_elapsedSec < prevBest) {
        await prefs.setDouble('best1600mSec', _elapsedSec.toDouble());
      }
    }
  }

  void _stopTimers() {
    _clockTimer?.cancel();
    _metronomeTimer?.cancel();
    _gpsSub?.cancel();
    setState(() {
      _isRunning = false;
      _metronomeOn = false;
    });
  }

  void _toggleMetronome() {
    setState(() => _metronomeOn = !_metronomeOn);
    _metronomeTimer?.cancel();
    if (_metronomeOn) {
      // 175 BPM = ~342ms per step
      _metronomeTimer = Timer.periodic(const Duration(milliseconds: 342), (_) {
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click);
      });
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _metronomeTimer?.cancel();
    _gpsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ghostDistanceM = (_elapsedSec / _targetTimeSec) * _targetDistanceM;
    final leadMeters = (_coveredDistanceM - ghostDistanceM).toInt();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Preset Chips
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('1600m (5:15 Group-1)'),
              selected: _targetDistanceM == 1600 && _targetTimeSec == 315,
              onSelected: _isRunning
                  ? null
                  : (_) => setState(() {
                        _targetDistanceM = 1600;
                        _targetTimeSec = 315;
                      }),
            ),
            ChoiceChip(
              label: const Text('1600m (5:30 NDA/IAF)'),
              selected: _targetDistanceM == 1600 && _targetTimeSec == 330,
              onSelected: _isRunning
                  ? null
                  : (_) => setState(() {
                        _targetDistanceM = 1600;
                        _targetTimeSec = 330;
                      }),
            ),
            ChoiceChip(
              label: const Text('5km (24:00 SSC GD)'),
              selected: _targetDistanceM == 5000,
              onSelected: _isRunning
                  ? null
                  : (_) => setState(() {
                        _targetDistanceM = 5000;
                        _targetTimeSec = 1440;
                      }),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Main Big High-Contrast Display
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.primary, width: 2),
          ),
          child: Column(
            children: [
              Text(
                '${(_elapsedSec ~/ 60).toString().padLeft(2, '0')}:${(_elapsedSec % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                'TARGET: ${(_targetTimeSec ~/ 60).toString().padLeft(2, '0')}:${(_targetTimeSec % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${_coveredDistanceM.toInt()} m',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: cs.primary,
                        ),
                      ),
                      const Text('COVERED'),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${max(0, (_targetDistanceM - _coveredDistanceM).toInt())} m',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text('REMAINING'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ghost Runner Comparison Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: leadMeters >= 0
                      ? Colors.green.withOpacity(0.15)
                      : Colors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      leadMeters >= 0 ? Icons.trending_up : Icons.warning_amber_rounded,
                      color: leadMeters >= 0 ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      leadMeters >= 0
                          ? 'Ghost Pacer: +$leadMeters m AHEAD of Target!'
                          : 'Ghost Pacer: ${leadMeters.abs()} m BEHIND Target!',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: leadMeters >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Indoor Simulation & 175 BPM Cadence Controls
        SwitchListTile(
          title: const Text(
            'Indoor Track Simulation Mode',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Test voice alerts & splits without going outside'),
          value: _simulationMode,
          onChanged: _isRunning ? null : (v) => setState(() => _simulationMode = v),
        ),
        SwitchListTile(
          title: const Text(
            '175 BPM Cadence Footstep Pacer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: const Text('Rhythmic tick & vibration to match military step speed'),
          value: _metronomeOn,
          onChanged: (_) => _toggleMetronome(),
        ),
        const SizedBox(height: 16),

        // Start / Stop Button
        SizedBox(
          height: 58,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRunning ? Colors.red : cs.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isRunning ? _stopTimers : _startRun,
            icon: Icon(_isRunning ? Icons.stop_circle : Icons.play_arrow, size: 28),
            label: Text(
              _isRunning ? 'STOP RUN' : 'START VOICE-GUIDED RUN',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 3. SENSOR & TOUCHLESS AI REP COUNTER (PUSH-UPS, SQUATS, SIT-UPS)
// ============================================================================
class RepCounterScreen extends StatefulWidget {
  const RepCounterScreen({super.key});

  @override
  State<RepCounterScreen> createState() => _RepCounterScreenState();
}

class _RepCounterScreenState extends State<RepCounterScreen> {
  String _exercise = 'Push-ups';
  int _reps = 0;
  int _targetReps = 20;
  bool _sensorActive = false;
  DateTime _lastRepTime = DateTime.now().subtract(const Duration(seconds: 5));
  StreamSubscription<AccelerometerEvent>? _accelSub;

  final List<String> _exercises = [
    'Push-ups',
    'Squats',
    'Sit-ups',
    'Jumping Jacks',
    'Dumbbell Chest Press',
  ];

  void _toggleSensorMode() {
    if (_sensorActive) {
      _accelSub?.cancel();
      setState(() => _sensorActive = false);
      return;
    }

    setState(() {
      _sensorActive = true;
      _reps = 0;
    });

    VoiceCoach.speak(
      "$_exercise shuru! Phone ko pocket mein rakhein ya haath mein pakad kar poora neeche aur upar jayein.",
      "$_exercise started! Perform full range reps.",
    );

    bool goingDown = false;
    _accelSub = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (magnitude > 13.8 && !goingDown) {
        goingDown = true;
      } else if (magnitude < 8.5 && goingDown) {
        goingDown = false;
        _registerRep();
      }
    });
  }

  Future<void> _registerRep() async {
    final now = DateTime.now();
    final diffMs = now.difference(_lastRepTime).inMilliseconds;

    // Anti-cheat form check: reps faster than 750ms are half-reps!
    if (diffMs < 750) {
      VoiceCoach.speak(
        "Bahut tez kar rahe ho! Poora neeche jao aur sahi form rakho!",
        "Too fast! Go full range and maintain form!",
      );
      return;
    }

    _lastRepTime = now;
    HapticFeedback.heavyImpact();

    setState(() => _reps++);

    if (_reps >= _targetReps) {
      VoiceCoach.speak(
        "$_reps! Shabaash, $_exercise ka target poora hua!",
        "$_reps! Target set completed! Great job!",
      );
      _accelSub?.cancel();
      setState(() => _sensorActive = false);
    } else {
      VoiceCoach.speak("$_reps", "$_reps");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalReps', (prefs.getInt('totalReps') ?? 0) + 1);
    await prefs.setInt('xp', (prefs.getInt('xp') ?? 120) + 5);
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Exercise Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _exercises.map((ex) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(ex),
                  selected: _exercise == ex,
                  onSelected: (_) => setState(() {
                    _exercise = ex;
                    _reps = 0;
                  }),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Giant Tap / Nose-Hover Target Pad (For Floor Push-ups) + Sensor Count
        GestureDetector(
          onTap: _registerRep,
          child: Container(
            height: 290,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _exercise.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: cs.primary,
                  ),
                ),
                Text(
                  '$_reps / $_targetReps',
                  style: const TextStyle(
                    fontSize: 78,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Place phone under chest & touch with nose/chin OR use Motion Sensor',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Target Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [10, 20, 30, 50].map((t) {
            return OutlinedButton(
              onPressed: () => setState(() => _targetReps = t),
              child: Text('Target: $t'),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Motion Sensor Button
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _sensorActive ? Colors.red : cs.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _toggleSensorMode,
            icon: Icon(_sensorActive ? Icons.stop : Icons.sensors),
            label: Text(
              _sensorActive
                  ? 'STOP MOTION SENSOR'
                  : 'START AUTOMATIC MOTION SENSOR',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 4. OFFICIAL BHARTI PHYSICAL TEST SIMULATOR (IAF PHASE-II / NDA / AGNIVEER)
// ============================================================================
class PftSimulatorScreen extends StatefulWidget {
  const PftSimulatorScreen({super.key});

  @override
  State<PftSimulatorScreen> createState() => _PftSimulatorScreenState();
}

class _PftSimulatorScreenState extends State<PftSimulatorScreen> {
  int _stage = 0; // 0: Ready, 1: Push-ups, 2: Sit-ups, 3: Squats, 4: Completed
  int _secLeft = 60;
  int _stageReps = 0;
  Timer? _timer;

  final List> _stages = [

    {'name': 'Ready for Official PFT', 'target': 0, 'time': 60},
    {'name': 'STAGE 1: 10 PUSH-UPS (1 Min)', 'target': 10, 'time': 60},
    {'name': 'STAGE 2: 10 SIT-UPS (1 Min)', 'target': 10, 'time': 60},
    {'name': 'STAGE 3: 20 SQUATS (1 Min)', 'target': 20, 'time': 60},
    {'name': 'PFT SELECTION RESULT: FIT!', 'target': 0, 'time': 0},
  ];

  void _startNextStage() {
    _timer?.cancel();
    if (_stage >= 3) {
      setState(() => _stage = 4);
      VoiceCoach.speak(
        "Badhai ho! Aapne Air Force Phase 2 aur NDA ka physical test pass kar liya hai!",
        "Congratulations! You have passed the official physical fitness test!",
      );
      return;
    }

    setState(() {
      _stage++;
      _stageReps = 0;
      _secLeft = 60;
    });

    final stName = _stages[_stage]['name'];
    final target = _stages[_stage]['target'];
    VoiceCoach.speak(
      "$stName shuru! Aapko 60 second mein $target reps lagane hain. Down... Up!",
      "$stName started! Complete $target reps in 60 seconds.",
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secLeft > 0) {
        setState(() => _secLeft--);
      } else {
        timer.cancel();
        VoiceCoach.speak("Time khatam!", "Time up!");
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final current = _stages[_stage];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.primary, width: 2),
          ),
          child: Column(
            children: [
              const Text(
                'IAF AGNIVEERVAYU PHASE-II & NDA PFT',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                current['name'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 20),
              if (_stage >= 1 && _stage <= 3) ...[
                Text(
                  '$_secLeft s',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Text(
                  'Completed: $_stageReps / ${current['target']}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _stageReps++);
                      VoiceCoach.speak("$_stageReps", "$_stageReps");
                      if (_stageReps >= current['target']) {
                        _startNextStage();
                      }
                    },
                    child: const Text(
                      'TAP TO COUNT REP (+1)',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ] else if (_stage == 4) ...[
                const Icon(Icons.verified, color: Colors.green, size: 72),
                const SizedBox(height: 10),
                const Text(
                  'STATUS: FIT FOR SELECTION!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _stage = 0),
                  child: const Text('Restart Simulator'),
                ),
              ] else ...[
                const Text(
                  'Official Sequence:\n• Stage 1: 10 Push-ups in 60s\n• Stage 2: 10 Sit-ups in 60s\n• Stage 3: 20 Squats in 60s',
                  style: TextStyle(fontSize: 15, height: 1.6),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _startNextStage,
                    icon: const Icon(Icons.play_circle_fill),
                    label: const Text(
                      'START OFFICIAL MOCK TEST',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 5. STAMINA BREATHING DRILL & DESI VEGETARIAN DIET / HYDRATION TRACKER
// ============================================================================
class StaminaAndDietScreen extends StatefulWidget {
  const StaminaAndDietScreen({super.key});

  @override
  State<StaminaAndDietScreen> createState() => _StaminaAndDietScreenState();
}

class _StaminaAndDietScreenState extends State<StaminaAndDietScreen> {
  int _waterGlasses = 0;
  int _holdSec = 0;
  bool _holding = false;
  Timer? _breathTimer;

  final Map<String, bool> _dietItems = {
    'Cow Milk (500ml) — 16g Protein': false,
    'Fresh Curd / Dahi (250g) — 10g Protein': false,
    'Roasted Chana / Sattu (100g) — 20g Protein': false,
    'Soya Chunks Boiled (50g) — 26g Protein': false,
    'Dal + 4 Roti + Veg — 18g Protein': false,
    'Dumbbell Chest & Core Workout Done': false,
  };

  void _toggleBreathHold() {
    if (_holding) {
      _breathTimer?.cancel();
      setState(() => _holding = false);
      VoiceCoach.speak(
        "Shabaash! Aapne $_holdSec second tak saans roki. Isse 1600 meter ke aakhiri round mein saans nahi phoolegi.",
        "Great! You held your breath for $_holdSec seconds.",
      );
      return;
    }

    setState(() {
      _holding = true;
      _holdSec = 0;
    });
    VoiceCoach.speak(
      "Gehri saans andar bharo aur rok kar rakho!",
      "Take a deep breath in and hold!",
    );
    _breathTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _holdSec++);
    });
  }

  int _calculateProtein() {
    int p = 0;
    if (_dietItems['Cow Milk (500ml) — 16g Protein']!) p += 16;
    if (_dietItems['Fresh Curd / Dahi (250g) — 10g Protein']!) p += 10;
    if (_dietItems['Roasted Chana / Sattu (100g) — 20g Protein']!) p += 20;
    if (_dietItems['Soya Chunks Boiled (50g) — 26g Protein']!) p += 26;
    if (_dietItems['Dal + 4 Roti + Veg — 18g Protein']!) p += 18;
    return p;
  }

  @override
  void dispose() {
    _breathTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalProtein = _calculateProtein();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Lung Stamina Breath-Hold Builder
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.primary.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              const Text(
                'LUNG CAPACITY & STAMINA BREATH-HOLD',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                '$_holdSec sec',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: cs.primary,
                ),
              ),
              const Text('Target: 60+ seconds for 1600m last-lap stamina'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _holding ? Colors.red : cs.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _toggleBreathHold,
                icon: Icon(_holding ? Icons.stop : Icons.air),
                label: Text(_holding ? 'RELEASE BREATH' : 'START BREATH HOLD'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Hydration Tracker
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DAILY HYDRATION',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text('$_waterGlasses / 12 Glasses (${_waterGlasses * 250} ml)'),
                ],
              ),
              FilledButton.icon(
                onPressed: () => setState(() => _waterGlasses++),
                icon: const Icon(Icons.water_drop),
                label: const Text('+1 Glass'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pure Vegetarian Desi Muscle & Stamina Diet Checklist
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DESI VEG DIET & HOME WORKOUT',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  Chip(
                    label: Text(
                      '$totalProtein / 90g Protein',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              ..._dietItems.keys.map((item) {
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item, style: const TextStyle(fontSize: 14)),
                  value: _dietItems[item],
                  onChanged: (v) => setState(() => _dietItems[item] = v ?? false),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}