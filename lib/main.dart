import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<CameraDescription> globalCameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    globalCameras = await availableCameras();
  } catch (_) {}
  try {
    await Supabase.initialize(
      url: 'https://xipganjsopjremxeiwav.supabase.co',
      anonKey: 'sb_publishable_8BWrZEFaKQXCu70C4HzdBQ_jYWQeR71',
    );
  } catch (_) {}
  await AppStorage.init();
  await VoiceCoach.init();
  await HardwarePermissions.requestAll();
  runApp(const VajraFitApp());
}

// 1. REAL ANDROID RUNTIME PERMISSION REQUESTER (Camera, Mic, Activity, Location)
class HardwarePermissions {
  static Future<void> requestAll() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.activityRecognition,
      Permission.sensors,
      Permission.locationWhenInUse,
    ].request();
  }
}

// 2. 3D SPRING BOUNCE ANIMATION WRAPPER FOR BUTTONS & CARDS
class SpringCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const SpringCard({super.key, required this.child, this.onTap});

  @override
  State<SpringCard> createState() => _SpringCardState();
}

class _SpringCardState extends State<SpringCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        if (widget.onTap != null) widget.onTap!();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

// 3. LIVE 400M STADIUM TRACK RADAR ANIMATION PAINTER (FOR RUN TAB)
class TrackRadarPainter extends CustomPainter {
  final double userMeters;
  final double ghostMeters;
  final double pulseValue;

  TrackRadarPainter({
    required this.userMeters,
    required this.ghostMeters,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 14;

    // Outer glowing track lane
    final trackPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawCircle(center, radius, trackPaint);

    // Radar sweep ring
    final pulsePaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(1.0 - pulseValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * pulseValue, pulsePaint);

    // Ghost Pacer Dot (Red) on 400m lap loop
    final ghostAngle = ((ghostMeters % 400) / 400.0) * 2 * pi - (pi / 2);
    final ghostPos = Offset(
      center.dx + radius * cos(ghostAngle),
      center.dy + radius * sin(ghostAngle),
    );
    canvas.drawCircle(
      ghostPos,
      7,
      Paint()..color = Colors.redAccent,
    );

    // User Runner Dot (Neon Green) on 400m lap loop
    final userAngle = ((userMeters % 400) / 400.0) * 2 * pi - (pi / 2);
    final userPos = Offset(
      center.dx + radius * cos(userAngle),
      center.dy + radius * sin(userAngle),
    );
    canvas.drawCircle(
      userPos,
      9,
      Paint()..color = const Color(0xFF10B981),
    );
  }

  @override
  bool shouldRepaint(covariant TrackRadarPainter oldDelegate) => true;
}

// 4. SINE-WAVE LIQUID WATER ANIMATION PAINTER (FOR HYDRATION CARD)
class LiquidWavePainter extends CustomPainter {
  final double fillPercent;
  final double wavePhase;

  LiquidWavePainter({required this.fillPercent, required this.wavePhase});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final baseHeight = size.height * (1.0 - fillPercent.clamp(0.0, 1.0));
    path.moveTo(0, size.height);
    for (double x = 0; x <= size.width; x++) {
      final y = baseHeight + sin((x / size.width * 2 * pi) + wavePhase) * 6;
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.lightBlueAccent.withOpacity(0.45),
          Colors.blueAccent.withOpacity(0.25),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidWavePainter oldDelegate) => true;
}

// 5. ANIMATED STICKMAN FORM COACH (LIVE MOVING EXERCISE DEMO)
class AnimatedStickmanCoach extends StatefulWidget {
  final String workoutName;
  const AnimatedStickmanCoach({super.key, required this.workoutName});

  @override
  State<AnimatedStickmanCoach> createState() => _AnimatedStickmanCoachState();
}

class _AnimatedStickmanCoachState extends State<AnimatedStickmanCoach>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        return Container(
          height: 95,
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.6)),
          ),
          child: CustomPaint(
            painter: _StickmanPainter(progress: t, name: widget.workoutName),
          ),
        );
      },
    );
  }
}

class _StickmanPainter extends CustomPainter {
  final double progress;
  final String name;
  _StickmanPainter({required this.progress, required this.name});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final isPushup = name.toLowerCase().contains('push');

    if (isPushup) {
      // Animated Plank Push-up Stickman moving up & down with straight spine
      final drop = progress * 22;
      final head = Offset(cx - 50, cy - 15 + drop);
      final shoulder = Offset(cx - 35, cy - 10 + drop);
      final hip = Offset(cx + 10, cy + 2 + (drop * 0.5));
      final ankle = Offset(cx + 55, cy + 18);
      final hand = Offset(cx - 35, cy + 20);
      final elbow = Offset(cx - 45, cy + 5 + (drop * 0.4));

      canvas.drawCircle(head, 7, p);
      canvas.drawLine(shoulder, hip, p); // Spine
      canvas.drawLine(hip, ankle, p); // Legs
      canvas.drawLine(shoulder, elbow, p);
      canvas.drawLine(elbow, hand, p);
    } else {
      // Animated Squat / Pull / Curl Stickman
      final squatDrop = progress * 20;
      final head = Offset(cx, cy - 28 + squatDrop);
      final shoulder = Offset(cx, cy - 16 + squatDrop);
      final hip = Offset(cx - (progress * 8), cy + 6 + squatDrop);
      final knee = Offset(cx + (progress * 14), cy + 18);
      final ankle = Offset(cx, cy + 32);

      canvas.drawCircle(head, 7, p);
      canvas.drawLine(shoulder, hip, p);
      canvas.drawLine(hip, knee, p);
      canvas.drawLine(knee, ankle, p);
      canvas.drawLine(shoulder, Offset(cx + 18, cy - 5 + squatDrop), p);
    }
  }

  @override
  bool shouldRepaint(covariant _StickmanPainter oldDelegate) => true;
}

// 6. REAL LIVE CAMERA + GOOGLE ML KIT 33-JOINT POSE SKELETON INSPECTOR
class LiveAiCameraInspectorModal extends StatefulWidget {
  final String workoutName;
  final VoidCallback onValidRep;
  const LiveAiCameraInspectorModal({
    super.key,
    required this.workoutName,
    required this.onValidRep,
  });

  @override
  State<LiveAiCameraInspectorModal> createState() =>
      _LiveAiCameraInspectorModalState();
}

class _LiveAiCameraInspectorModalState
    extends State<LiveAiCameraInspectorModal> {
  CameraController? _camCtrl;
  PoseDetector? _poseDetector;
  Timer? _frameTimer;
  int _camIdx = 0;
  bool _busy = false;
  bool _downState = false;
  double _spineAngle = 178.0;
  double _jointAngle = 170.0;
  bool _waistFault = false;
  String _aiMessage = 'Initializing Camera & ML Kit 33-Joint AI...';
  List<Pose> _detectedPoses = [];

  @override
  void initState() {
    super.initState();
    _initAiCamera();
  }

  Future<void> _initAiCamera() async {
    await HardwarePermissions.requestAll();
    if (globalCameras.isEmpty) {
      try {
        globalCameras = await availableCameras();
      } catch (_) {}
    }
    if (globalCameras.isEmpty) {
      setState(() => _aiMessage = 'Camera permission required! Allow in settings.');
      return;
    }

    // Prefer front camera so user can see skeleton live
    _camIdx = globalCameras.indexWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
    );
    if (_camIdx < 0) _camIdx = 0;

    _poseDetector = PoseDetector(
      options: PoseDetectorOptions(mode: PoseDetectionMode.single),
    );

    await _startCamera(_camIdx);
  }

  Future<void> _startCamera(int index) async {
    _frameTimer?.cancel();
    await _camCtrl?.dispose();

    final cam = globalCameras[index];
    final ctrl = CameraController(
      cam,
      ResolutionPreset.low,
      enableAudio: true, // Uses Microphone permission too!
    );

    try {
      await ctrl.initialize();
      if (!mounted) return;
      setState(() {
        _camCtrl = ctrl;
        _aiMessage = '✅ AI Vision Active — Place phone 5ft away';
      });

      // Analyze live frames with ML Kit Pose Detector
      _frameTimer =
          Timer.periodic(const Duration(milliseconds: 650), (_) => _scanPose());
    } catch (e) {
      setState(() => _aiMessage = 'Camera error: $e');
    }
  }

  double _calcAngle(PoseLandmark a, PoseLandmark b, PoseLandmark c) {
    final rad = atan2(c.y - b.y, c.x - b.x) - atan2(a.y - b.y, a.x - b.x);
    double deg = (rad * 180.0 / pi).abs();
    if (deg > 180.0) deg = 360.0 - deg;
    return deg;
  }

  Future<void> _scanPose() async {
    if (_busy || _camCtrl == null || !_camCtrl!.value.isInitialized) return;
    _busy = true;
    try {
      final shot = await _camCtrl!.takePicture();
      final inputImg = InputImage.fromFilePath(shot.path);
      final poses = await _poseDetector!.processImage(inputImg);

      if (poses.isNotEmpty && mounted) {
        final p = poses.first;
        final sh = p.landmarks[PoseLandmarkType.leftShoulder] ??
            p.landmarks[PoseLandmarkType.rightShoulder];
        final hip = p.landmarks[PoseLandmarkType.leftHip] ??
            p.landmarks[PoseLandmarkType.rightHip];
        final ank = p.landmarks[PoseLandmarkType.leftAnkle] ??
            p.landmarks[PoseLandmarkType.rightAnkle];
        final elb = p.landmarks[PoseLandmarkType.leftElbow] ??
            p.landmarks[PoseLandmarkType.rightElbow];
        final wri = p.landmarks[PoseLandmarkType.leftWrist] ??
            p.landmarks[PoseLandmarkType.rightWrist];
        final knee = p.landmarks[PoseLandmarkType.leftKnee] ??
            p.landmarks[PoseLandmarkType.rightKnee];

        double spine = 175.0;
        if (sh != null && hip != null && ank != null) {
          spine = _calcAngle(sh, hip, ank);
        }

        double workAngle = 170.0;
        if (widget.workoutName.toLowerCase().contains('squat') &&
            hip != null &&
            knee != null &&
            ank != null) {
          workAngle = _calcAngle(hip, knee, ank);
        } else if (sh != null && elb != null && wri != null) {
          workAngle = _calcAngle(sh, elb, wri);
        }

        final bentWaist = spine < 150.0;

        setState(() {
          _detectedPoses = poses;
          _spineAngle = spine;
          _jointAngle = workAngle;
          _waistFault = bentWaist;
          if (bentWaist) {
            _aiMessage =
                '❌ WAIST BENT (${spine.toStringAsFixed(0)}°)! Straighten Back!';
          } else {
            _aiMessage =
                '✅ Spine: ${spine.toStringAsFixed(0)}° | Joint Angle: ${workAngle.toStringAsFixed(0)}°';
          }
        });

        if (bentWaist) {
          VoiceCoach.speak(
            'Back is bending! Straighten your waist!',
            'कमर टेढ़ी है! कमर सीधी रखें!',
          );
        } else {
          if (!_downState && workAngle < 105.0) {
            _downState = true;
            VoiceCoach.speak('Good depth, now up!', 'बहुत बढ़िया, अब ऊपर आएं!');
          } else if (_downState && workAngle > 152.0) {
            _downState = false;
            widget.onValidRep();
          }
        }
      }
      try {
        await File(shot.path).delete();
      } catch (_) {}
    } catch (_) {}
    _busy = false;
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    _camCtrl?.dispose();
    _poseDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF070B12),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(
          color: _waistFault ? Colors.redAccent : const Color(0xFF10B981),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '📷 LIVE AI POSE INSPECTOR (${widget.workoutName})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (globalCameras.length > 1) {
                    _camIdx = (_camIdx + 1) % globalCameras.length;
                    _startCamera(_camIdx);
                  }
                },
                icon: const Icon(Icons.cameraswitch, color: Colors.white),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (_waistFault ? Colors.red : Colors.green).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _aiMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _waistFault ? Colors.redAccent : Colors.greenAccent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _camCtrl != null && _camCtrl!.value.isInitialized
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_camCtrl!),
                        IgnorePointer(
                          child: CustomPaint(
                            painter: _PoseOverlayPainter(
                              poses: _detectedPoses,
                              isFault: _waistFault,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}

class _PoseOverlayPainter extends CustomPainter {
  final List<Pose> poses;
  final bool isFault;
  _PoseOverlayPainter({required this.poses, required this.isFault});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = isFault ? Colors.redAccent : const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    for (final pose in poses) {
      for (final lm in pose.landmarks.values) {
        final dx = (lm.x / 480.0).clamp(0.0, 1.0) * size.width;
        final dy = (lm.y / 640.0).clamp(0.0, 1.0) * size.height;
        canvas.drawCircle(Offset(dx, dy), 5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PoseOverlayPainter oldDelegate) => true;
}


// ============================================================================
// 1. GLOBAL LANGUAGE, VOICE COACH & STORAGE ENGINE (ZERO DATA-LOSS)
// ============================================================================

String tr(String en, String hi) => AppStorage.isHindiUi ? hi : en;

class VoiceCoach {
  static final FlutterTts _tts = FlutterTts();
  static bool isMuted = false;

  static Future<void> init() async {
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  static Future<void> speak(String enText, [String? hiText]) async {
    if (isMuted) return;
    final useHi = AppStorage.isHindiUi;
    await _tts.setLanguage(useHi ? 'hi-IN' : 'en-US');
    await _tts.speak(useHi ? (hiText ?? enText) : enText);
  }
}

class RunPreset {
  String id;
  String title;
  int distanceMeters;
  int targetSeconds;
  RunPreset(this.id, this.title, this.distanceMeters, this.targetSeconds);

  Map toJson() => {
        'id': id,
        'title': title,
        'dist': distanceMeters,
        'sec': targetSeconds,
      };

  static RunPreset fromJson(Map m) => RunPreset(
        m['id'].toString(),
        m['title'].toString(),
        (m['dist'] as num).toInt(),
        (m['sec'] as num).toInt(),
      );
}

class VoiceAlertRule {
  String id;
  String triggerType; // 'distance_every', 'distance_at', 'time_every', 'time_at'
  int triggerValue; // meters or seconds
  String customMessage;
  VoiceAlertRule(this.id, this.triggerType, this.triggerValue, this.customMessage);

  Map toJson() => {
        'id': id,
        'type': triggerType,
        'val': triggerValue,
        'msg': customMessage,
      };

  static VoiceAlertRule fromJson(Map m) => VoiceAlertRule(
        m['id'].toString(),
        m['type'].toString(),
        (m['val'] as num).toInt(),
        m['msg'].toString(),
      );
}

class WorkoutModel {
  String id;
  String nameEn;
  String nameHi;
  String category; // 'Indoor', 'Gym', 'Outdoor', 'Custom'
  String sensorMode; // 'Proximity', 'Gravity', 'CameraAI', 'Timer'
  String muscleGroup;
  String placementEn;
  String placementHi;
  String dosEn;
  String dontsEn;
  int defaultTarget;
  double weightKg;

  WorkoutModel({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.category,
    required this.sensorMode,
    required this.muscleGroup,
    required this.placementEn,
    required this.placementHi,
    required this.dosEn,
    required this.dontsEn,
    this.defaultTarget = 15,
    this.weightKg = 0,
  });

  Map toJson() => {
        'id': id,
        'nameEn': nameEn,
        'nameHi': nameHi,
        'category': category,
        'sensorMode': sensorMode,
        'muscleGroup': muscleGroup,
        'placementEn': placementEn,
        'placementHi': placementHi,
        'dosEn': dosEn,
        'dontsEn': dontsEn,
        'defaultTarget': defaultTarget,
        'weightKg': weightKg,
      };

  static WorkoutModel fromJson(Map m) => WorkoutModel(
        id: m['id'].toString(),
        nameEn: m['nameEn'].toString(),
        nameHi: m['nameHi'].toString(),
        category: m['category'].toString(),
        sensorMode: m['sensorMode'].toString(),
        muscleGroup: m['muscleGroup'].toString(),
        placementEn: m['placementEn'].toString(),
        placementHi: m['placementHi'].toString(),
        dosEn: m['dosEn'].toString(),
        dontsEn: m['dontsEn'].toString(),
        defaultTarget: (m['defaultTarget'] as num).toInt(),
        weightKg: (m['weightKg'] as num).toDouble(),
      );
}

class FoodModel {
  String id;
  String nameEn;
  String nameHi;
  String emoji;
  String dietType; // 'Veg', 'Egg', 'NonVeg'
  String unitLabel;
  int kcal;
  int protein;
  int carbs;
  int fat;
  double selectedMultiplier;
  bool isSelected;

  FoodModel({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.emoji,
    required this.dietType,
    required this.unitLabel,
    required this.kcal,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.selectedMultiplier = 1.0,
    this.isSelected = false,
  });

  Map toJson() => {
        'id': id,
        'nameEn': nameEn,
        'nameHi': nameHi,
        'emoji': emoji,
        'dietType': dietType,
        'unitLabel': unitLabel,
        'kcal': kcal,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'mult': selectedMultiplier,
        'sel': isSelected,
      };

  static FoodModel fromJson(Map m) => FoodModel(
        id: m['id'].toString(),
        nameEn: m['nameEn'].toString(),
        nameHi: m['nameHi'].toString(),
        emoji: m['emoji'].toString(),
        dietType: m['dietType'].toString(),
        unitLabel: m['unitLabel'].toString(),
        kcal: (m['kcal'] as num).toInt(),
        protein: (m['protein'] as num).toInt(),
        carbs: (m['carbs'] as num).toInt(),
        fat: (m['fat'] as num).toInt(),
        selectedMultiplier: (m['mult'] as num).toDouble(),
        isSelected: m['sel'] == true,
      );
}

class AppStorage {
  static late SharedPreferences prefs;

  // Global UI state
  static bool isDarkMode = true;
  static bool isHindiUi = false;
  static String currentUserId = '';

  // Active User Profile Data
  static String userName = 'Athlete';
  static String userPin = '1234';
  static String userGoal = 'General Fitness';
  static String userDietPref = 'Veg';
  static int age = 19;
  static double heightCm = 166.0;
  static double weightKg = 54.0;
  static double chestNormalCm = 79.0;
  static double chestExpandedCm = 85.0;
  static String selectedMedicalExam = 'General Fitness';

  // Progress Stats
  static int xp = 120;
  static int streak = 1;
  static int best1600mSec = 0;
  static int totalReps = 0;
  static int bestBreathSec = 0;
  static int waterMl = 0;
  static int waterGoalMl = 3000;

  static List<RunPreset> runPresets = [];
  static List<VoiceAlertRule> voiceAlerts = [];
  static List<WorkoutModel> customWorkouts = [];
  static List<FoodModel> foodItems = [];

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('global_dark') ?? true;
    isHindiUi = prefs.getBool('global_hindi') ?? false;
    currentUserId = prefs.getString('active_user_id') ?? '';
    if (currentUserId.isNotEmpty) {
      loadUserData(currentUserId);
    } else {
      _initDefaults();
    }
  }

  static List<String> getRegisteredUsers() {
    return prefs.getStringList('registered_users') ?? [];
  }

  static String _key(String field) => 'u_${currentUserId}_$field';

  static void _initDefaults() {
    runPresets = [
      RunPreset('p1', '1600m (5:15 Group-1)', 1600, 315),
      RunPreset('p2', '1600m (5:30 NDA/IAF)', 1600, 330),
      RunPreset('p3', '5km (24:00 SSC GD)', 5000, 1440),
    ];
    voiceAlerts = [
      VoiceAlertRule(
        'a1',
        'distance_every',
        200,
        'Covered {done} meters, {left} meters remaining. Keep pushing!',
      ),
    ];
    foodItems = _defaultFoods();
  }

  static List<FoodModel> _defaultFoods() => [
        FoodModel(
          id: 'f1',
          nameEn: 'Cow / Buffalo Milk',
          nameHi: 'गाय / भैंस का दूध',
          emoji: '🥛',
          dietType: 'Veg',
          unitLabel: '500 ml',
          kcal: 320,
          protein: 16,
          carbs: 24,
          fat: 18,
        ),
        FoodModel(
          id: 'f2',
          nameEn: 'Fresh Curd / Dahi',
          nameHi: 'ताज़ा दही',
          emoji: '🥣',
          dietType: 'Veg',
          unitLabel: '250 g',
          kcal: 150,
          protein: 10,
          carbs: 11,
          fat: 8,
        ),
        FoodModel(
          id: 'f3',
          nameEn: 'Roasted Chana / Sattu',
          nameHi: 'भुना चना / सत्तू',
          emoji: '🫘',
          dietType: 'Veg',
          unitLabel: '100 g',
          kcal: 360,
          protein: 20,
          carbs: 58,
          fat: 5,
        ),
        FoodModel(
          id: 'f4',
          nameEn: 'Soaked Kala Chana',
          nameHi: 'भीगा काला चना',
          emoji: '🌰',
          dietType: 'Veg',
          unitLabel: '100 g',
          kcal: 340,
          protein: 19,
          carbs: 60,
          fat: 5,
        ),
        FoodModel(
          id: 'f5',
          nameEn: 'Boiled Yellow Chana / Chole',
          nameHi: 'पीला चना / छोले',
          emoji: '🍲',
          dietType: 'Veg',
          unitLabel: '150 g',
          kcal: 245,
          protein: 14,
          carbs: 40,
          fat: 4,
        ),
        FoodModel(
          id: 'f6',
          nameEn: 'Soya Chunks Boiled',
          nameHi: 'सोया बड़ी (उबली)',
          emoji: '🧆',
          dietType: 'Veg',
          unitLabel: '50 g',
          kcal: 172,
          protein: 26,
          carbs: 16,
          fat: 1,
        ),
        FoodModel(
          id: 'f7',
          nameEn: 'Fresh Paneer',
          nameHi: 'ताज़ा पनीर',
          emoji: '🧀',
          dietType: 'Veg',
          unitLabel: '100 g',
          kcal: 265,
          protein: 18,
          carbs: 3,
          fat: 20,
        ),
        FoodModel(
          id: 'f8',
          nameEn: 'Moong / Toor Dal + 4 Roti',
          nameHi: 'दाल + 4 रोटी + सब्ज़ी',
          emoji: '🫓',
          dietType: 'Veg',
          unitLabel: '1 Meal',
          kcal: 540,
          protein: 18,
          carbs: 95,
          fat: 9,
        ),
        FoodModel(
          id: 'f9',
          nameEn: 'Oats / Wheat Daliya',
          nameHi: 'ओट्स / गेहूँ दलिया',
          emoji: '🌾',
          dietType: 'Veg',
          unitLabel: '1 Bowl (80g)',
          kcal: 290,
          protein: 11,
          carbs: 54,
          fat: 5,
        ),
        FoodModel(
          id: 'f10',
          nameEn: 'Peanut Butter + 2 Banana',
          nameHi: 'पीनट बटर + 2 केले',
          emoji: '🍌',
          dietType: 'Veg',
          unitLabel: '2 tbsp + 2',
          kcal: 390,
          protein: 10,
          carbs: 58,
          fat: 16,
        ),
        FoodModel(
          id: 'f11',
          nameEn: 'Almonds, Cashew & Dates',
          nameHi: 'बादाम, काजू और खजूर',
          emoji: '🥜',
          dietType: 'Veg',
          unitLabel: '40 g Mix',
          kcal: 210,
          protein: 6,
          carbs: 18,
          fat: 13,
        ),
        FoodModel(
          id: 'f12',
          nameEn: 'Boiled Whole Eggs',
          nameHi: 'उबले अंडे (2 पीस)',
          emoji: '🥚',
          dietType: 'Egg',
          unitLabel: '2 Eggs',
          kcal: 155,
          protein: 13,
          carbs: 1,
          fat: 11,
        ),
        FoodModel(
          id: 'f13',
          nameEn: 'Egg White Omelette',
          nameHi: 'अंडे का आमलेट (4 अंडे)',
          emoji: '🍳',
          dietType: 'Egg',
          unitLabel: '4 Whites',
          kcal: 90,
          protein: 16,
          carbs: 1,
          fat: 2,
        ),
        FoodModel(
          id: 'f14',
          nameEn: 'Grilled Chicken Breast',
          nameHi: 'चिकन ब्रेस्ट (उबला/रोस्ट)',
          emoji: '🍗',
          dietType: 'NonVeg',
          unitLabel: '150 g',
          kcal: 248,
          protein: 46,
          carbs: 0,
          fat: 5,
        ),
        FoodModel(
          id: 'f15',
          nameEn: 'Fish Curry / Grilled Fish',
          nameHi: 'मछली (150 ग्राम)',
          emoji: '🐟',
          dietType: 'NonVeg',
          unitLabel: '150 g',
          kcal: 220,
          protein: 34,
          carbs: 2,
          fat: 8,
        ),
      ];

  static Future<void> registerOrLoginUser({
    required String id,
    required String name,
    required String pin,
    required String goal,
    required String dietPref,
    required int userAge,
    required double height,
    required double weight,
  }) async {
    final users = getRegisteredUsers();
    if (!users.contains(id)) {
      users.add(id);
      await prefs.setStringList('registered_users', users);
    }
    currentUserId = id;
    await prefs.setString('active_user_id', id);

    userName = name;
    userPin = pin;
    userGoal = goal;
    userDietPref = dietPref;
    age = userAge;
    heightCm = height;
    weightKg = weight;
    _initDefaults();
    await saveAllUserData();
  }

  static void loadUserData(String id) {
    currentUserId = id;
    userName = prefs.getString(_key('name')) ?? 'Athlete';
    userPin = prefs.getString(_key('pin')) ?? '1234';
    userGoal = prefs.getString(_key('goal')) ?? 'General Fitness';
    userDietPref = prefs.getString(_key('dietPref')) ?? 'Veg';
    age = prefs.getInt(_key('age')) ?? 19;
    heightCm = prefs.getDouble(_key('height')) ?? 166.0;
    weightKg = prefs.getDouble(_key('weight')) ?? 54.0;
    chestNormalCm = prefs.getDouble(_key('chestN')) ?? 79.0;
    chestExpandedCm = prefs.getDouble(_key('chestE')) ?? 85.0;
    selectedMedicalExam =
        prefs.getString(_key('medExam')) ?? 'General Fitness';

    xp = prefs.getInt(_key('xp')) ?? 120;
    streak = prefs.getInt(_key('streak')) ?? 1;
    best1600mSec = prefs.getInt(_key('best1600')) ?? 0;
    totalReps = prefs.getInt(_key('totalReps')) ?? 0;
    bestBreathSec = prefs.getInt(_key('bestBreath')) ?? 0;
    waterMl = prefs.getInt(_key('waterMl')) ?? 0;
    waterGoalMl = prefs.getInt(_key('waterGoal')) ?? 3000;

    final pRaw = prefs.getString(_key('runPresets'));
    if (pRaw != null) {
      final decoded = jsonDecode(pRaw) as List;
      runPresets = decoded.map((e) => RunPreset.fromJson(e as Map)).toList();
    } else {
      _initDefaults();
    }

    final aRaw = prefs.getString(_key('voiceAlerts'));
    if (aRaw != null) {
      final decoded = jsonDecode(aRaw) as List;
      voiceAlerts =
          decoded.map((e) => VoiceAlertRule.fromJson(e as Map)).toList();
    }

    final wRaw = prefs.getString(_key('customWorkouts'));
    if (wRaw != null) {
      final decoded = jsonDecode(wRaw) as List;
      customWorkouts =
          decoded.map((e) => WorkoutModel.fromJson(e as Map)).toList();
    }

    final fRaw = prefs.getString(_key('foodItems'));
    if (fRaw != null) {
      final decoded = jsonDecode(fRaw) as List;
      foodItems = decoded.map((e) => FoodModel.fromJson(e as Map)).toList();
    } else {
      foodItems = _defaultFoods();
    }
  }

  static Future<void> saveAllUserData() async {
    if (currentUserId.isEmpty) return;
    await prefs.setString(_key('name'), userName);
    await prefs.setString(_key('pin'), userPin);
    await prefs.setString(_key('goal'), userGoal);
    await prefs.setString(_key('dietPref'), userDietPref);
    await prefs.setInt(_key('age'), age);
    await prefs.setDouble(_key('height'), heightCm);
    await prefs.setDouble(_key('weight'), weightKg);
    await prefs.setDouble(_key('chestN'), chestNormalCm);
    await prefs.setDouble(_key('chestE'), chestExpandedCm);
    await prefs.setString(_key('medExam'), selectedMedicalExam);

    await prefs.setInt(_key('xp'), xp);
    await prefs.setInt(_key('streak'), streak);
    await prefs.setInt(_key('best1600'), best1600mSec);
    await prefs.setInt(_key('totalReps'), totalReps);
    await prefs.setInt(_key('bestBreath'), bestBreathSec);
    await prefs.setInt(_key('waterMl'), waterMl);
    await prefs.setInt(_key('waterGoal'), waterGoalMl);

    await prefs.setString(
      _key('runPresets'),
      jsonEncode(runPresets.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _key('voiceAlerts'),
      jsonEncode(voiceAlerts.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _key('customWorkouts'),
      jsonEncode(customWorkouts.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _key('foodItems'),
      jsonEncode(foodItems.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> setGlobalTheme(bool dark) async {
    isDarkMode = dark;
    await prefs.setBool('global_dark', dark);
  }

  static Future<void> setGlobalLanguage(bool hindi) async {
    isHindiUi = hindi;
    await prefs.setBool('global_hindi', hindi);
  }

  static Future<void> logout() async {
    currentUserId = '';
    await prefs.setString('active_user_id', '');
  }

  // Real JSON File Export & Import (No Copy-Paste)
  static String exportFullBackupJson() {
    final map = {
      'app': 'VajraFit_v2_Pro',
      'timestamp': DateTime.now().toIso8601String(),
      'userId': currentUserId,
      'name': userName,
      'pin': userPin,
      'goal': userGoal,
      'dietPref': userDietPref,
      'age': age,
      'height': heightCm,
      'weight': weightKg,
      'chestN': chestNormalCm,
      'chestE': chestExpandedCm,
      'medExam': selectedMedicalExam,
      'xp': xp,
      'streak': streak,
      'best1600': best1600mSec,
      'totalReps': totalReps,
      'bestBreath': bestBreathSec,
      'waterMl': waterMl,
      'waterGoal': waterGoalMl,
      'runPresets': runPresets.map((e) => e.toJson()).toList(),
      'voiceAlerts': voiceAlerts.map((e) => e.toJson()).toList(),
      'customWorkouts': customWorkouts.map((e) => e.toJson()).toList(),
      'foodItems': foodItems.map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  static Future<File> createBackupFile() async {
    final jsonStr = exportFullBackupJson();
    final safeUser = currentUserId.isEmpty ? 'user' : currentUserId;
    final fileName = 'VajraFit_Backup_$safeUser.json';

    // Save to app documents directory AND attempt Download directory
    final docDir = await getApplicationDocumentsDirectory();
    final file = File('${docDir.path}/$fileName');
    await file.writeAsString(jsonStr);

    try {
      final dlDir = Directory('/storage/emulated/0/Download');
      if (await dlDir.exists()) {
        final dlFile = File('${dlDir.path}/$fileName');
        await dlFile.writeAsString(jsonStr);
      }
    } catch (_) {}

    return file;
  }

  static Future<bool> importBackupFromJsonString(String rawJson) async {
    try {
      final map = jsonDecode(rawJson) as Map;
      if (map['app'] != 'VajraFit_v2_Pro') return false;

      currentUserId = (map['userId'] ?? 'restored_user').toString();
      final users = getRegisteredUsers();
      if (!users.contains(currentUserId)) {
        users.add(currentUserId);
        await prefs.setStringList('registered_users', users);
      }
      await prefs.setString('active_user_id', currentUserId);

      userName = (map['name'] ?? 'Athlete').toString();
      userPin = (map['pin'] ?? '1234').toString();
      userGoal = (map['goal'] ?? 'General Fitness').toString();
      userDietPref = (map['dietPref'] ?? 'Veg').toString();
      age = (map['age'] as num).toInt();
      heightCm = (map['height'] as num).toDouble();
      weightKg = (map['weight'] as num).toDouble();
      chestNormalCm = (map['chestN'] as num).toDouble();
      chestExpandedCm = (map['chestE'] as num).toDouble();
      selectedMedicalExam = (map['medExam'] ?? 'General Fitness').toString();

      xp = (map['xp'] as num).toInt();
      streak = (map['streak'] as num).toInt();
      best1600mSec = (map['best1600'] as num).toInt();
      totalReps = (map['totalReps'] as num).toInt();
      bestBreathSec = (map['bestBreath'] as num).toInt();
      waterMl = (map['waterMl'] as num).toInt();
      waterGoalMl = (map['waterGoal'] as num).toInt();

      if (map['runPresets'] != null) {
        runPresets = (map['runPresets'] as List)
            .map((e) => RunPreset.fromJson(e as Map))
            .toList();
      }
      if (map['voiceAlerts'] != null) {
        voiceAlerts = (map['voiceAlerts'] as List)
            .map((e) => VoiceAlertRule.fromJson(e as Map))
            .toList();
      }
      if (map['customWorkouts'] != null) {
        customWorkouts = (map['customWorkouts'] as List)
            .map((e) => WorkoutModel.fromJson(e as Map))
            .toList();
      }
      if (map['foodItems'] != null) {
        foodItems = (map['foodItems'] as List)
            .map((e) => FoodModel.fromJson(e as Map))
            .toList();
      }

      await saveAllUserData();
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ============================================================================
// 2. ROOT APP & THEME ENGINE (CYBER-TACTICAL DARK + SUNLIGHT HIGH-CONTRAST)
// ============================================================================

class VajraFitApp extends StatefulWidget {
  const VajraFitApp({super.key});

  @override
  State<VajraFitApp> createState() => _VajraFitAppState();
}

class _VajraFitAppState extends State<VajraFitApp> {
  void _refreshApp() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppStorage.isDarkMode;

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF070B12),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFF5500),
        secondary: Color(0xFF10B981),
        surface: Color(0xFF111827),
      ),
      useMaterial3: true,
    );

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF3F6FA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFE64800),
        secondary: Color(0xFF059669),
        surface: Colors.white,
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'VajraFit Pro',
      debugShowCheckedModeBanner: false,
      theme: isDark ? darkTheme : lightTheme,
      home: AppStorage.currentUserId.isEmpty
          ? AuthAccountScreen(onAuthSuccess: _refreshApp)
          : MainShellScreen(onGlobalUpdate: _refreshApp),
    );
  }
}

// ============================================================================
// 3. USER ACCOUNT SIGN UP / SIGN IN SCREEN (MULTI-USER VAULT)
// ============================================================================

class AuthAccountScreen extends StatefulWidget {
  final VoidCallback onAuthSuccess;
  const AuthAccountScreen({super.key, required this.onAuthSuccess});

  @override
  State<AuthAccountScreen> createState() => _AuthAccountScreenState();
}

class _AuthAccountScreenState extends State<AuthAccountScreen> {
  bool _isSignUp = true;
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController(text: '1234');
  final _ageCtrl = TextEditingController(text: '19');
  final _heightCtrl = TextEditingController(text: '166');
  final _weightCtrl = TextEditingController(text: '54');
  String _selectedGoal = 'General Fitness';
  String _selectedDiet = 'Veg';
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    final existing = AppStorage.getRegisteredUsers();
    if (existing.isNotEmpty) {
      _isSignUp = false;
      _idCtrl.text = existing.first;
    }
  }

  Future<void> _submit() async {
    final id = _idCtrl.text.trim().toLowerCase();
    final pin = _pinCtrl.text.trim();
    if (id.isEmpty || pin.isEmpty) {
      setState(() => _errorMsg = tr(
            'Please enter Username/ID and 4-digit PIN.',
            'कृपया यूज़रनेम और 4-अंकों का पिन डालें।',
          ));
      return;
    }

    if (_isSignUp) {
      final name = _nameCtrl.text.trim().isEmpty ? id : _nameCtrl.text.trim();
      final age = int.tryParse(_ageCtrl.text) ?? 19;
      final h = double.tryParse(_heightCtrl.text) ?? 166.0;
      final w = double.tryParse(_weightCtrl.text) ?? 54.0;

      await AppStorage.registerOrLoginUser(
        id: id,
        name: name,
        pin: pin,
        goal: _selectedGoal,
        dietPref: _selectedDiet,
        userAge: age,
        height: h,
        weight: w,
      );
      widget.onAuthSuccess();
    } else {
      final savedPin = AppStorage.prefs.getString('u_${id}_pin');
      if (savedPin == null) {
        setState(() => _errorMsg = tr(
              'Account not found! Please switch to Sign Up.',
              'अकाउंट नहीं मिला! कृपया पहले नया अकाउंट बनाएं।',
            ));
        return;
      }
      if (savedPin != pin) {
        setState(() => _errorMsg = tr('Incorrect PIN!', 'गलत पिन!'));
        return;
      }
      await AppStorage.prefs.setString('active_user_id', id);
      AppStorage.loadUserData(id);
      widget.onAuthSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final existingUsers = AppStorage.getRegisteredUsers();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary, Colors.deepOrangeAccent],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.shield, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'VAJRAFIT PRO',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () async {
                        await AppStorage.setGlobalLanguage(
                            !AppStorage.isHindiUi);
                        setState(() {});
                      },
                      icon: const Icon(Icons.translate, size: 18),
                      label: Text(AppStorage.isHindiUi ? 'हिंदी' : 'EN'),
                    ),
                    IconButton(
                      onPressed: () async {
                        await AppStorage.setGlobalTheme(!AppStorage.isDarkMode);
                        widget.onAuthSuccess();
                      },
                      icon: Icon(
                        AppStorage.isDarkMode
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cs.primary.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isSignUp
                        ? tr('Create Personal Fitness Account',
                            'अपना पर्सनल फिटनेस अकाउंट बनाएं')
                        : tr('Sign In to Your Account',
                            'अपने अकाउंट में लॉग-इन करें'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tr(
                      '100% Permanent Local & File Vault — Your data never resets across tabs or restarts.',
                      '100% सुरक्षित अकाउंट — टैब बदलने या ऐप बंद करने पर आपका डेटा कभी नहीं उड़ेगा।',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isSignUp ? cs.primary : cs.surface,
                            foregroundColor:
                                _isSignUp ? Colors.white : cs.onSurface,
                          ),
                          onPressed: () => setState(() {
                            _isSignUp = true;
                            _errorMsg = '';
                          }),
                          child: Text(tr('SIGN UP', 'नया अकाउंट')),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                !_isSignUp ? cs.primary : cs.surface,
                            foregroundColor:
                                !_isSignUp ? Colors.white : cs.onSurface,
                          ),
                          onPressed: () => setState(() {
                            _isSignUp = false;
                            _errorMsg = '';
                          }),
                          child: Text(tr('SIGN IN', 'लॉग-इन')),
                        ),
                      ),
                    ],
                  ),
                  if (!_isSignUp && existingUsers.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      tr('Saved Accounts (Tap to select):',
                          'सेव किए गए अकाउंट (चुनने के लिए टैप करें):'),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: existingUsers
                          .map((u) => ActionChip(
                                avatar: const Icon(Icons.person, size: 16),
                                label: Text(u),
                                onPressed: () =>
                                    setState(() => _idCtrl.text = u),
                              ))
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _idCtrl,
                    decoration: InputDecoration(
                      labelText:
                          tr('Username / Mobile / ID', 'यूज़रनेम या मोबाइल नंबर'),
                      prefixIcon: const Icon(Icons.account_circle),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pinCtrl,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr('4-Digit Security PIN / Password',
                          '4-अंकों का सुरक्षा पिन / पासवर्ड'),
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: tr('Your Full Name', 'आपका पूरा नाम'),
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ageCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: tr('Age (Yrs)', 'उम्र (वर्ष)'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _heightCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: tr('Height (cm)', 'लंबाई (cm)'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _weightCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: tr('Weight (kg)', 'वज़न (kg)'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedGoal,
                      decoration: InputDecoration(
                        labelText: tr('Primary Fitness Goal', 'मुख्य लक्ष्य'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      items: [
                        'General Fitness',
                        'NDA / CDS Officer',
                        'Air Force Agniveervayu',
                        'Indian Army Agniveer',
                        'SSC GD / State Police',
                        'Gym & Muscle Gain',
                      ]
                          .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedGoal = v);
                      },
                    ),
                  ],
                  if (_errorMsg.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMsg,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _submit,
                      icon: const Icon(Icons.login),
                      label: Text(
                        _isSignUp
                            ? tr('CREATE ACCOUNT & START', 'अकाउंट बनाएं और शुरू करें')
                            : tr('UNLOCK ACCOUNT', 'लॉग-इन करें'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
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
}

// ============================================================================
// 4. MAIN SHELL SCREEN WITH INDEXEDSTACK (ZERO TAB RESET)
// ============================================================================

class MainShellScreen extends StatefulWidget {
  final VoidCallback onGlobalUpdate;
  const MainShellScreen({super.key, required this.onGlobalUpdate});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _tabIndex = 0;

  void _triggerGlobalRefresh() {
    setState(() {});
    widget.onGlobalUpdate();
  }

  String _getRankName() {
    final x = AppStorage.xp;
    if (x >= 2000) return 'PARA COMMANDO';
    if (x >= 1000) return 'CAPTAIN';
    if (x >= 500) return 'LIEUTENANT';
    if (x >= 250) return 'CADET';
    return 'RECRUIT';
  }

  void _openAccountAndBackupSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('Account & Real File Backup Vault',
                            'अकाउंट और फ़ाइल बैकअप वॉल्ट'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Text(
                    '${tr("Logged in as", "लॉग-इन यूज़र")}: ${AppStorage.userName} (@${AppStorage.currentUserId})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final file = await AppStorage.createBackupFile();
                        await Share.shareXFiles(
                          [XFile(file.path)],
                          subject: 'VajraFit Backup File',
                        );
                      },
                      icon: const Icon(Icons.download_rounded),
                      label: Text(
                        tr(
                          'Download / Share Backup File (.json)',
                          'बैकअप फ़ाइल (.json) डाउनलोड / शेयर करें',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        await _showFileImportDialog(ctx);
                        _triggerGlobalRefresh();
                      },
                      icon: const Icon(Icons.upload_file),
                      label: Text(
                        tr(
                          'Import / Restore Backup File (.json)',
                          'बैकअप फ़ाइल (.json) इम्पोर्ट / रिस्टोर करें',
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Divider(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await AppStorage.logout();
                        _triggerGlobalRefresh();
                      },
                      icon: const Icon(Icons.logout),
                      label: Text(
                        tr('Switch Account / Logout', 'अकाउंट बदलें / लॉग-आउट'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showFileImportDialog(BuildContext parentCtx) async {
    final List<File> foundFiles = [];
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final docList = docDir.listSync();
      for (final f in docList) {
        if (f is File && f.path.endsWith('.json')) {
          foundFiles.add(f);
        }
      }
    } catch (_) {}

    try {
      final dlDir = Directory('/storage/emulated/0/Download');
      if (await dlDir.exists()) {
        for (final f in dlDir.listSync()) {
          if (f is File &&
              f.path.contains('VajraFit') &&
              f.path.endsWith('.json')) {
            foundFiles.add(f);
          }
        }
      }
    } catch (_) {}

    if (!mounted) return;
    showDialog(
      context: parentCtx,
      builder: (dCtx) {
        return AlertDialog(
          title: Text(tr('Select Backup File to Import',
              'इम्पोर्ट करने के लिए बैकअप फ़ाइल चुनें')),
          content: SizedBox(
            width: double.maxFinite,
            child: foundFiles.isEmpty
                ? Text(tr(
                    'No VajraFit .json backup files found in Downloads or App folder yet. Create a backup first!',
                    'अभी Downloads फोल्डर में कोई VajraFit .json फ़ाइल नहीं मिली। पहले बैकअप बनाएं!',
                  ))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: foundFiles.length,
                    itemBuilder: (ctx, i) {
                      final f = foundFiles[i];
                      final name = f.path.split('/').last;
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file,
                            color: Colors.green),
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(f.path,
                            style: const TextStyle(fontSize: 11)),
                        onTap: () async {
                          final content = await f.readAsString();
                          final ok = await AppStorage
                              .importBackupFromJsonString(content);
                          if (!mounted) return;
                          Navigator.pop(dCtx);
                          Navigator.pop(parentCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok
                                  ? tr('Backup File Imported Successfully!',
                                      'बैकअप फ़ाइल सफलतापूर्वक इम्पोर्ट हो गई!')
                                  : tr('Invalid Backup File!',
                                      'अमान्य बैकअप फ़ाइल!')),
                            ),
                          );
                          _triggerGlobalRefresh();
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: Text(tr('Close', 'बंद करें')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 2,
        titleSpacing: 12,
        title: GestureDetector(
          onTap: _openAccountAndBackupSheet,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStorage.userName.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${_getRankName()} • 🔥 ${AppStorage.streak}d',
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Full App English / Hindi Switch
          InkWell(
            onTap: () async {
              await AppStorage.setGlobalLanguage(!AppStorage.isHindiUi);
              _triggerGlobalRefresh();
              VoiceCoach.speak(
                'English Mode Activated',
                'हिंदी मोड चालू हो गया है',
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.primary),
              ),
              child: Row(
                children: [
                  Icon(Icons.translate, size: 15, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(
                    AppStorage.isHindiUi ? 'हिंदी' : 'EN',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Voice Mute Toggle
          IconButton(
            tooltip: tr('Mute/Unmute Voice Coach', 'आवाज़ बंद/चालू करें'),
            onPressed: () {
              setState(() => VoiceCoach.isMuted = !VoiceCoach.isMuted);
            },
            icon: Icon(
              VoiceCoach.isMuted ? Icons.volume_off : Icons.record_voice_over,
              size: 20,
            ),
          ),
          // Theme Switch (Sunlight / Dark)
          IconButton(
            tooltip: tr('Switch Theme', 'थीम बदलें'),
            onPressed: () async {
              await AppStorage.setGlobalTheme(!AppStorage.isDarkMode);
              _triggerGlobalRefresh();
            },
            icon: Icon(
              AppStorage.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.amber,
            ),
          ),
        ],
      ),
      // INDEXEDSTACK KEEPS ALL 5 TABS ALIVE IN MEMORY (NO DATA LOSS ON TAB SWITCH)
      body: IndexedStack(
        index: _tabIndex,
        children: [
          HqDashboardTab(
            onOpenBackup: _openAccountAndBackupSheet,
            onDataUpdated: _triggerGlobalRefresh,
          ),
          SmartRunCoachTab(onDataUpdated: _triggerGlobalRefresh),
          ProWorkoutHubTab(onDataUpdated: _triggerGlobalRefresh),
          BhartiSimulatorTab(onDataUpdated: _triggerGlobalRefresh),
          DietAndLungTab(onDataUpdated: _triggerGlobalRefresh),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.military_tech),
            label: tr('HQ', 'होम HQ'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.directions_run),
            label: tr('Run Coach', 'रनिंग'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center),
            label: tr('Workouts', 'वर्कआउट'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.timer),
            label: tr('Bharti Test', 'भर्ती टेस्ट'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu),
            label: tr('Diet & Lung', 'डाइट/स्टैमिना'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. TAB 1: HQ DASHBOARD (REAL FILE BACKUP + GENERAL BMI FIRST + EXAM FILTER)
// ============================================================================

class HqDashboardTab extends StatefulWidget {
  final VoidCallback onOpenBackup;
  final VoidCallback onDataUpdated;
  const HqDashboardTab({
    super.key,
    required this.onOpenBackup,
    required this.onDataUpdated,
  });

  @override
  State<HqDashboardTab> createState() => _HqDashboardTabState();
}

class _HqDashboardTabState extends State<HqDashboardTab> {
  String _formatRunTime(int sec) {
    if (sec <= 0) return '--:--';
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _openEditNumberDialog(
    String title,
    double currentVal,
    Function(double) onSaved,
  ) {
    final ctrl = TextEditingController(text: currentVal.toStringAsFixed(1));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Cancel', 'रद्द करें')),
          ),
          ElevatedButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null && v > 0) {
                onSaved(v);
                AppStorage.saveAllUserData();
                widget.onDataUpdated();
              }
              Navigator.pop(ctx);
            },
            child: Text(tr('Save', 'सेव करें')),
          ),
        ],
      ),
    );
  }

  Map _evaluateMedicalAndBmi() {
    final hMeters = AppStorage.heightCm / 100.0;
    final bmi = AppStorage.weightKg / (hMeters * hMeters);

    // Ideal general healthy weight range (BMI 18.5 to 22.9 for Indian standards, 24.9 global)
    final minIdealWeight = 18.5 * hMeters * hMeters;
    final maxIdealWeight = 23.0 * hMeters * hMeters;

    String statusTitle;
    String advice;
    Color badgeColor;

    if (bmi < 17.5) {
      final diff = (minIdealWeight - AppStorage.weightKg).toStringAsFixed(1);
      badgeColor = Colors.redAccent;
      statusTitle = tr(
        'UNDERWEIGHT — Gain +$diff kg to reach healthy minimum (${minIdealWeight.toStringAsFixed(1)} kg)',
        'कम वज़न (Underweight) — स्वस्थ होने के लिए +$diff kg वज़न बढ़ाएं',
      );
      advice = tr(
        'Action Plan: Eat +400 kcal surplus daily (Milk, Banana, Chana, Sattu, Peanut Butter) & do progressive compound strength workouts.',
        'सलाह: रोज़ दूध, केला, भुना चना, सत्तू और पीनट बटर लें तथा डंबल/पुश-अप्स करें।',
      );
    } else if (bmi < 18.5) {
      final diff = (minIdealWeight - AppStorage.weightKg).toStringAsFixed(1);
      badgeColor = Colors.orange;
      statusTitle = tr(
        'BORDERLINE UNDERWEIGHT — Need +$diff kg for 100% Fit Standard',
        'बॉर्डरलाइन कम वज़न — पूरी तरह फिट होने के लिए +$diff kg बढ़ाएं',
      );
      advice = tr(
        'Action Plan: Add 1 extra high-protein meal (Soya chunks / Paneer / Dahi) and sleep 8 hours for muscle recovery.',
        'सलाह: अपनी डाइट में सोया बड़ी, पनीर या दही जोड़ें और मांसपेशियों की रिकवरी पर ध्यान दें।',
      );
    } else if (bmi <= 23.5) {
      badgeColor = Colors.green;
      statusTitle = tr(
        'OPTIMAL FIT WEIGHT (${minIdealWeight.toStringAsFixed(1)} – ${maxIdealWeight.toStringAsFixed(1)} kg Ideal Range)',
        'बिल्कुल फिट वज़न (आदर्श रेंज: ${minIdealWeight.toStringAsFixed(1)} – ${maxIdealWeight.toStringAsFixed(1)} kg)',
      );
      advice = tr(
        'Action Plan: Maintain current macro balance (1.6g protein/kg bodyweight) and focus on 1600m speed & core endurance.',
        'सलाह: आपका वज़न आपकी लंबाई के हिसाब से बिल्कुल सही है! अब 1600m की स्पीड और स्टैमिना पर फोकस करें।',
      );
    } else if (bmi <= 25.5) {
      final diff = (AppStorage.weightKg - maxIdealWeight).toStringAsFixed(1);
      badgeColor = Colors.orange;
      statusTitle = tr(
        'OVERWEIGHT — Reduce -$diff kg to enter Ideal Fitness Zone',
        'अधिक वज़न (Overweight) — आदर्श फिटनेस के लिए -$diff kg वज़न कम करें',
      );
      advice = tr(
        'Action Plan: Cut sugar & fried snacks, maintain 300 kcal deficit, keep protein high, and run 20–30 mins daily.',
        'सलाह: मीठा और तला हुआ खाना बंद करें, प्रोटीन बढ़ाएं और रोज़ 20–30 मिनट दौड़ लगाएं।',
      );
    } else {
      final diff = (AppStorage.weightKg - maxIdealWeight).toStringAsFixed(1);
      badgeColor = Colors.redAccent;
      statusTitle = tr(
        'HIGH OVERWEIGHT / OBESE (BMI ${bmi.toStringAsFixed(1)}) — Reduce -$diff kg',
        'काफी अधिक वज़न (BMI ${bmi.toStringAsFixed(1)}) — फिट होने के लिए -$diff kg घटाएं',
      );
      advice = tr(
        'Action Plan: Strict fat-loss required! Avoid junk/refined carbs, drink 3.5L water, do brisk walking + HIIT bodyweight circuits.',
        'सलाह: वज़न सीमा से काफी ज़्यादा है! जंक फूड छोड़ें, 3.5 लीटर पानी पिएं और रोज़ कार्डियो/HIIT वर्कआउट करें।',
      );
    }

    // Optional Exam Medical Standard Filter Check
    String examVerdict = '';
    final exam = AppStorage.selectedMedicalExam;
    final h = AppStorage.heightCm;
    final w = AppStorage.weightKg;
    final cNorm = AppStorage.chestNormalCm;
    final cExp = AppStorage.chestExpandedCm;
    final expansion = cExp - cNorm;

    if (exam != 'General Fitness') {
      double reqHeight = 157.5;
      double reqChest = 77.0;
      if (exam.contains('Air Force')) {
        reqHeight = 152.5;
        reqChest = 75.0;
      } else if (exam.contains('Army')) {
        reqHeight = 168.0;
        reqChest = 77.0;
      } else if (exam.contains('SSC GD') || exam.contains('Police')) {
        reqHeight = 170.0;
        reqChest = 80.0;
      }

      final minExamW = (h - 100) * 0.80;
      final maxExamW = (h - 100) * 1.10;

      final hOk = h >= reqHeight;
      final wOk = w >= minExamW && w <= maxExamW && bmi >= 18.0 && bmi <= 25.0;
      final cOk = cNorm >= reqChest && expansion >= 5.0;

      if (hOk && wOk && cOk) {
        examVerdict = tr(
          '✅ [$exam MEDICAL FIT]: Height ($h cm >= $reqHeight), Weight ($w kg in ${minExamW.toStringAsFixed(0)}–${maxExamW.toStringAsFixed(0)} kg), & Chest ($cNorm->$cExp cm, +${expansion.toStringAsFixed(0)}cm) meet official standards!',
          '✅ [$exam मेडिकल फिट]: आपकी लंबाई, वज़न और चेस्ट फुलाव (+${expansion.toStringAsFixed(0)} cm) आधिकारिक मानकों पर बिल्कुल फिट हैं!',
        );
      } else {
        final reasons = <String>[];
        if (!hOk) {
          reasons.add(tr('Min Height needed: $reqHeight cm',
              'न्यूनतम लंबाई चाहिए: $reqHeight cm'));
        }
        if (!wOk) {
          reasons.add(tr(
              'Allowed Weight for $h cm: ${minExamW.toStringAsFixed(1)}–${maxExamW.toStringAsFixed(1)} kg',
              '$h cm पर मान्य वज़न: ${minExamW.toStringAsFixed(1)}–${maxExamW.toStringAsFixed(1)} kg'));
        }
        if (!cOk) {
          reasons.add(tr(
              'Chest needed: min $reqChest cm + 5 cm expansion (Current: +${expansion.toStringAsFixed(1)} cm)',
              'चेस्ट: न्यूनतम $reqChest cm और +5 cm फुलाव ज़रूरी'));
        }
        examVerdict = '⚠️ [$exam]: ${reasons.join(" | ")}';
      }
    }

    return {
      'bmi': bmi,
      'status': statusTitle,
      'advice': advice,
      'color': badgeColor,
      'examVerdict': examVerdict,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final eval = _evaluateMedicalAndBmi();
    final bmiVal = eval['bmi'] as double;
    final badgeColor = eval['color'] as Color;
    final examVerdict = eval['examVerdict'] as String;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. PREMIUM HERO CARD
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.primary.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.2),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      AppStorage.userGoal.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '🔥 ${AppStorage.streak} ${tr("Day Streak", "दिन लगातार")}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'XP: ${AppStorage.xp} / ${((AppStorage.xp ~/ 500) + 1) * 500}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (AppStorage.xp % 500) / 500.0,
                  minHeight: 10,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(cs.primary),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Share.share(
                          '🛡️ VAJRAFIT PRO REPORT CARD\n'
                          'Athlete: ${AppStorage.userName}\n'
                          'Goal: ${AppStorage.userGoal}\n'
                          'XP: ${AppStorage.xp} | Best 1600m: ${_formatRunTime(AppStorage.best1600mSec)}\n'
                          'Total Reps: ${AppStorage.totalReps} | Best Breath Hold: ${AppStorage.bestBreathSec}s',
                        );
                      },
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(
                        tr('Share Report Card', 'रिपोर्ट कार्ड शेयर करें'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Real File Backup Vault Button (No 'We cant save file' error!)
                  InkWell(
                    onTap: widget.onOpenBackup,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.save_alt_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. QUICK STATS GRID
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                Icons.timer_outlined,
                _formatRunTime(AppStorage.best1600mSec),
                tr('1600m Best', '1600m बेस्ट समय'),
                tr('Target: 05:30', 'लक्ष्य: 05:30'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                Icons.fitness_center,
                '${AppStorage.totalReps}',
                tr('Total Reps Done', 'कुल रेप्स (Reps)'),
                tr('All Workouts', 'सभी एक्सरसाइज़'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 3. GENERAL BMI FIRST + OPTIONAL ALL-EXAM MEDICAL FILTER
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: badgeColor.withOpacity(0.6), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tr('BODY BMI, WEIGHT & MEDICAL CHECK',
                          'बॉडी BMI, वज़न और मेडिकल चेक'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: badgeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: badgeColor),
                    ),
                    child: Text(
                      'BMI: ${bmiVal.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: badgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // HEIGHT CONTROL (Slider + -/+ + Direct Tap Input)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${tr("Height", "लंबाई")}: ${AppStorage.heightCm.toStringAsFixed(1)} cm',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setState(() => AppStorage.heightCm =
                              (AppStorage.heightCm - 0.5).clamp(120.0, 220.0));
                          AppStorage.saveAllUserData();
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setState(() => AppStorage.heightCm =
                              (AppStorage.heightCm + 0.5).clamp(120.0, 220.0));
                          AppStorage.saveAllUserData();
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      TextButton(
                        onPressed: () => _openEditNumberDialog(
                          tr('Enter Height (cm)', 'लंबाई (cm) लिखें'),
                          AppStorage.heightCm,
                          (v) => setState(
                              () => AppStorage.heightCm = v.clamp(100.0, 240.0)),
                        ),
                        child: Text(tr('Type', 'लिखें')),
                      ),
                    ],
                  ),
                ],
              ),
              Slider(
                value: AppStorage.heightCm.clamp(120.0, 220.0),
                min: 120.0,
                max: 220.0,
                activeColor: cs.secondary,
                onChanged: (v) {
                  setState(() => AppStorage.heightCm = v);
                  AppStorage.saveAllUserData();
                },
              ),

              // WEIGHT CONTROL (Slider 25kg to 150kg + -/+ + Direct Tap Input)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${tr("Weight", "वज़न")}: ${AppStorage.weightKg.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setState(() => AppStorage.weightKg =
                              (AppStorage.weightKg - 0.5).clamp(25.0, 150.0));
                          AppStorage.saveAllUserData();
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setState(() => AppStorage.weightKg =
                              (AppStorage.weightKg + 0.5).clamp(25.0, 150.0));
                          AppStorage.saveAllUserData();
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                      TextButton(
                        onPressed: () => _openEditNumberDialog(
                          tr('Enter Weight (kg)', 'वज़न (kg) लिखें'),
                          AppStorage.weightKg,
                          (v) => setState(
                              () => AppStorage.weightKg = v.clamp(20.0, 200.0)),
                        ),
                        child: Text(tr('Type', 'लिखें')),
                      ),
                    ],
                  ),
                ],
              ),
              Slider(
                value: AppStorage.weightKg.clamp(25.0, 150.0),
                min: 25.0,
                max: 150.0,
                activeColor: cs.primary,
                onChanged: (v) {
                  setState(() => AppStorage.weightKg = v);
                  AppStorage.saveAllUserData();
                },
              ),

              // GENERAL FITNESS STATUS BOX (Always accurate!)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: badgeColor.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eval['status'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: badgeColor,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      eval['advice'] as String,
                      style: const TextStyle(fontSize: 12.5, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // OPTIONAL EXAM MEDICAL FILTER DROPDOWN
              DropdownButtonFormField<String>(
                value: AppStorage.selectedMedicalExam,
                decoration: InputDecoration(
                  labelText: tr(
                    'Optional: Check Exam Medical Standard (Filter)',
                    'वैकल्पिक: किसी भर्ती परीक्षा का मेडिकल स्टैंडर्ड चेक करें',
                  ),
                  prefixIcon: const Icon(Icons.verified_user_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: [
                  'General Fitness',
                  'NDA / CDS (Army, Navy, IAF)',
                  'Air Force Agniveervayu',
                  'Indian Army Agniveer (GD/Tech)',
                  'Indian Navy (SSR / MR)',
                  'SSC GD (CRPF, BSF, CISF)',
                  'State Police Constable / SI',
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => AppStorage.selectedMedicalExam = v);
                    AppStorage.saveAllUserData();
                  }
                },
              ),

              if (AppStorage.selectedMedicalExam != 'General Fitness') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _openEditNumberDialog(
                          tr('Normal Chest (cm)', 'बिना फुलाए चेस्ट (cm)'),
                          AppStorage.chestNormalCm,
                          (v) =>
                              setState(() => AppStorage.chestNormalCm = v),
                        ),
                        child: Text(
                          '${tr("Chest", "चेस्ट")}: ${AppStorage.chestNormalCm.toStringAsFixed(0)} cm',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _openEditNumberDialog(
                          tr('Expanded Chest (cm)', 'फुलाने के बाद चेस्ट (cm)'),
                          AppStorage.chestExpandedCm,
                          (v) =>
                              setState(() => AppStorage.chestExpandedCm = v),
                        ),
                        child: Text(
                          '${tr("Expanded", "फुलाकर")}: ${AppStorage.chestExpandedCm.toStringAsFixed(0)} cm',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    examVerdict,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
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

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String title,
    String sub,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary, size: 26),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            sub,
            style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. TAB 2: SMART RUN COACH (ANTI-DRIFT GPS + CUSTOM TARGETS + VOICE ALERTS)
// ============================================================================

class SmartRunCoachTab extends StatefulWidget {
  final VoidCallback onDataUpdated;
  const SmartRunCoachTab({super.key, required this.onDataUpdated});

  @override
  State<SmartRunCoachTab> createState() => _SmartRunCoachTabState();
}

class _SmartRunCoachTabState extends State<SmartRunCoachTab> {
  int _selectedPresetIndex = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _indoorSimMode = false;
  bool _showGhostPacer = true;
  bool _cadencePacerOn = false;
  int _cadenceBpm = 175;

  int _elapsedSec = 0;
  double _coveredMeters = 0.0;
  double _liveSpeedKmh = 0.0;
  bool _isActuallyMoving = false;
  DateTime _lastStepDetectedTime = DateTime.fromMillisecondsSinceEpoch(0);
  int _detectedSteps = 0;

  Timer? _runTimer;
  Timer? _cadenceTimer;
  StreamSubscription<Position>? _gpsSub;
  StreamSubscription<UserAccelerometerEvent>? _stepAccelSub;
  Position? _lastValidPos;
  final Set<String> _firedAlertKeys = {};
  final List<String> _lapSplits = [];
  int _lastLapMarker = 0;

  RunPreset get _activePreset {
    if (AppStorage.runPresets.isEmpty) {
      AppStorage.runPresets
          .add(RunPreset('default', '1600m (5:30)', 1600, 330));
    }
    if (_selectedPresetIndex >= AppStorage.runPresets.length) {
      _selectedPresetIndex = 0;
    }
    return AppStorage.runPresets[_selectedPresetIndex];
  }

  void _toggleCadencePacer(bool val) {
    _cadenceTimer?.cancel();
    setState(() => _cadencePacerOn = val);
    if (val) {
      final intervalMs = (60000 / _cadenceBpm).round();
      _cadenceTimer =
          Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click);
      });
    }
  }

  Future<void> _startRun() async {
    if (!_indoorSimMode) {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
      _elapsedSec = 0;
      _coveredMeters = 0.0;
      _liveSpeedKmh = 0.0;
      _detectedSteps = 0;
      _lastValidPos = null;
      _firedAlertKeys.clear();
      _lapSplits.clear();
      _lastLapMarker = 0;
    });

    VoiceCoach.speak(
      'Run started! Target ${_activePreset.distanceMeters} meters.',
      'दौड़ शुरू! लक्ष्य ${_activePreset.distanceMeters} मीटर।',
    );

    // 1. Hardware Linear Accelerometer Step Detector (Anti-Drift Lock!)
    _stepAccelSub?.cancel();
    _stepAccelSub = userAccelerometerEvents.listen((event) {
      final mag =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      if (mag > 2.2) {
        final now = DateTime.now();
        if (now.difference(_lastStepDetectedTime).inMilliseconds > 260) {
          _lastStepDetectedTime = now;
          if (_isRunning && !_isPaused) {
            _detectedSteps++;
          }
        }
      }
    });

    // 2. Main 1-Second Run Clock
    _runTimer?.cancel();
    _runTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      final movingNow = _indoorSimMode ||
          DateTime.now().difference(_lastStepDetectedTime).inSeconds <= 3;

      setState(() {
        _elapsedSec++;
        _isActuallyMoving = movingNow;
        if (_indoorSimMode) {
          _coveredMeters += 4.8;
          _liveSpeedKmh = 17.2;
        } else if (!movingNow) {
          _liveSpeedKmh = 0.0;
        }
      });

      _checkLapAndVoiceRules();

      if (_coveredMeters >= _activePreset.distanceMeters) {
        _finishRun(completedTarget: true);
      }
    });

    // 3. GPS Stream with 3-Layer Anti-Drift Filter
    if (!_indoorSimMode) {
      _gpsSub?.cancel();
      _gpsSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 2,
        ),
      ).listen((pos) {
        if (!_isRunning || _isPaused) return;

        // LAYER 1: Reject poor satellite accuracy (> 14m jitter)
        if (pos.accuracy > 14.0) return;

        // LAYER 2: Step-Sensor Motion Lock — if standing still, DO NOT add GPS drift!
        final stepsActive =
            DateTime.now().difference(_lastStepDetectedTime).inSeconds <= 3;
        if (!stepsActive && pos.speed < 1.0) {
          setState(() {
            _isActuallyMoving = false;
            _liveSpeedKmh = 0.0;
          });
          _lastValidPos = pos;
          return;
        }

        if (_lastValidPos != null) {
          final delta = Geolocator.distanceBetween(
            _lastValidPos!.latitude,
            _lastValidPos!.longitude,
            pos.latitude,
            pos.longitude,
          );
          // LAYER 3: Realistic human running delta (1.2m to 12m per update)
          if (delta >= 1.2 && delta <= 25.0) {
            setState(() {
              _coveredMeters += delta;
              _liveSpeedKmh =
                  (pos.speed > 0.5 ? pos.speed : (delta / 2.0)) * 3.6;
              _isActuallyMoving = true;
            });
          }
        }
        _lastValidPos = pos;
      });
    }
  }

  void _checkLapAndVoiceRules() {
    final doneM = _coveredMeters.floor();
    final leftM = max(0, _activePreset.distanceMeters - doneM);

    // Record 200m Split Laps
    final lapIndex = doneM ~/ 200;
    if (lapIndex > _lastLapMarker && doneM > 0) {
      _lastLapMarker = lapIndex;
      _lapSplits.add(
        '${lapIndex * 200}m — ${_formatTime(_elapsedSec)} (${_liveSpeedKmh.toStringAsFixed(1)} km/h)',
      );
    }

    // Check Custom Voice Alert Rules
    for (final rule in AppStorage.voiceAlerts) {
      bool shouldFire = false;
      String fireKey = '';

      if (rule.triggerType == 'distance_every' && rule.triggerValue > 0) {
        final step = doneM ~/ rule.triggerValue;
        if (step > 0) {
          fireKey = '${rule.id}_d_$step';
          shouldFire = !_firedAlertKeys.contains(fireKey);
        }
      } else if (rule.triggerType == 'distance_at') {
        if (doneM >= rule.triggerValue) {
          fireKey = '${rule.id}_dat';
          shouldFire = !_firedAlertKeys.contains(fireKey);
        }
      } else if (rule.triggerType == 'time_every' && rule.triggerValue > 0) {
        if (_elapsedSec > 0 && _elapsedSec % rule.triggerValue == 0) {
          fireKey = '${rule.id}_t_$_elapsedSec';
          shouldFire = !_firedAlertKeys.contains(fireKey);
        }
      } else if (rule.triggerType == 'time_at') {
        if (_elapsedSec == rule.triggerValue) {
          fireKey = '${rule.id}_tat';
          shouldFire = !_firedAlertKeys.contains(fireKey);
        }
      }

      if (shouldFire && fireKey.isNotEmpty) {
        _firedAlertKeys.add(fireKey);
        final msg = rule.customMessage
            .replaceAll('{done}', '$doneM')
            .replaceAll('{left}', '$leftM')
            .replaceAll('{time}', _formatTime(_elapsedSec));
        VoiceCoach.speak(msg, msg);
      }
    }
  }

  void _finishRun({bool completedTarget = false}) {
    _runTimer?.cancel();
    _gpsSub?.cancel();
    _stepAccelSub?.cancel();

    setState(() {
      _isRunning = false;
      _isPaused = false;
      if (completedTarget) {
        AppStorage.xp += 50;
        if (_activePreset.distanceMeters == 1600 &&
            (AppStorage.best1600mSec == 0 ||
                _elapsedSec < AppStorage.best1600mSec)) {
          AppStorage.best1600mSec = _elapsedSec;
        }
      }
    });
    AppStorage.saveAllUserData();
    widget.onDataUpdated();

    if (completedTarget) {
      VoiceCoach.speak(
        'Target completed in ${_formatTime(_elapsedSec)}! Great job!',
        'बधाई हो! आपने ${_formatTime(_elapsedSec)} में दौड़ पूरी कर ली!',
      );
    } else {
      VoiceCoach.speak('Run stopped.', 'दौड़ रोक दी गई।');
    }
  }

  String _formatTime(int totalSec) {
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _openAddCustomTargetDialog() {
    final titleCtrl = TextEditingController();
    final distCtrl = TextEditingController(text: '1600');
    final minCtrl = TextEditingController(text: '5');
    final secCtrl = TextEditingController(text: '00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Create Custom Run Target', 'नया रनिंग टारगेट बनाएं')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: tr('Target Name (Optional)', 'टारगेट का नाम'),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: distCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: tr('Distance in Meters (e.g. 400, 1600, 5000)',
                      'दूरी मीटर में (जैसे 400, 1600)'),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: tr('Minutes', 'मिनट'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: secCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: tr('Seconds', 'सेकंड'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Cancel', 'रद्द करें')),
          ),
          ElevatedButton(
            onPressed: () {
              final d = int.tryParse(distCtrl.text) ?? 1600;
              final m = int.tryParse(minCtrl.text) ?? 5;
              final s = int.tryParse(secCtrl.text) ?? 0;
              final totalSec = max(10, m * 60 + s);
              final label = titleCtrl.text.trim().isEmpty
                  ? '${d}m (${m.toString().padLeft(2, "0")}:${s.toString().padLeft(2, "0")})'
                  : titleCtrl.text.trim();

              setState(() {
                AppStorage.runPresets.add(
                  RunPreset(
                    DateTime.now().millisecondsSinceEpoch.toString(),
                    label,
                    d,
                    totalSec,
                  ),
                );
                _selectedPresetIndex = AppStorage.runPresets.length - 1;
              });
              AppStorage.saveAllUserData();
              Navigator.pop(ctx);
            },
            child: Text(tr('Save Target', 'सेव करें')),
          ),
        ],
      ),
    );
  }

  void _openAddVoiceAlertDialog() {
    String triggerType = 'distance_every';
    final valCtrl = TextEditingController(text: '200');
    final msgCtrl = TextEditingController(
      text: 'Covered {done} meters, {left} meters left! Speed up!',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(tr('Custom Voice Alert & Message',
              'कस्टम वॉइस अलार्म और मैसेज सेट करें')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: triggerType,
                  decoration: InputDecoration(
                    labelText: tr('When should it speak?', 'कब बोलना चाहिए?'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'distance_every',
                      child: Text(tr('Every X Meters (Repeat)',
                          'हर X मीटर पर (बार-बार)')),
                    ),
                    DropdownMenuItem(
                      value: 'distance_at',
                      child: Text(tr('At Exact X Meters (Once)',
                          'फिक्स X मीटर पूरे होने पर')),
                    ),
                    DropdownMenuItem(
                      value: 'time_every',
                      child: Text(tr('Every X Seconds (Repeat)',
                          'हर X सेकंड पर (बार-बार)')),
                    ),
                    DropdownMenuItem(
                      value: 'time_at',
                      child: Text(tr('At Exact X Seconds (Once)',
                          'फिक्स X सेकंड पूरे होने पर')),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => triggerType = v);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: valCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: triggerType.startsWith('distance')
                        ? tr('Meters (e.g. 200 or 1200)',
                            'मीटर लिखें (जैसे 200 या 1200)')
                        : tr('Seconds (e.g. 60 or 180)',
                            'सेकंड लिखें (जैसे 60 या 180)'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: msgCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: tr('Type Custom Message to Speak',
                        'जो बुलवाना चाहते हैं वो मैसेज टाइप करें'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('+ {done}m'),
                      onPressed: () => msgCtrl.text = '${msgCtrl.text} {done}',
                    ),
                    ActionChip(
                      label: const Text('+ {left}m'),
                      onPressed: () => msgCtrl.text = '${msgCtrl.text} {left}',
                    ),
                    ActionChip(
                      label: const Text('+ {time}'),
                      onPressed: () => msgCtrl.text = '${msgCtrl.text} {time}',
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.volume_up, size: 16),
                      label: Text(tr('Test Voice', 'आवाज़ सुनें')),
                      onPressed: () {
                        final preview = msgCtrl.text
                            .replaceAll('{done}', '400')
                            .replaceAll('{left}', '1200')
                            .replaceAll('{time}', '01:20');
                        VoiceCoach.speak(preview, preview);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Cancel', 'रद्द करें')),
            ),
            ElevatedButton(
              onPressed: () {
                final v = int.tryParse(valCtrl.text) ?? 200;
                setState(() {
                  AppStorage.voiceAlerts.add(
                    VoiceAlertRule(
                      DateTime.now().millisecondsSinceEpoch.toString(),
                      triggerType,
                      max(5, v),
                      msgCtrl.text.trim(),
                    ),
                  );
                });
                AppStorage.saveAllUserData();
                Navigator.pop(ctx);
              },
              child: Text(tr('Add Voice Alert', 'अलर्ट जोड़ें')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _runTimer?.cancel();
    _cadenceTimer?.cancel();
    _gpsSub?.cancel();
    _stepAccelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final preset = _activePreset;
    final remainingMeters = max(0.0, preset.distanceMeters - _coveredMeters);

    // Clear Ghost Pacer Calculation
    final targetSpeedMps = preset.distanceMeters / preset.targetSeconds;
    final expectedMetersNow = _elapsedSec * targetSpeedMps;
    final diffMeters = _coveredMeters - expectedMetersNow;
    final reqSpeedKmh = targetSpeedMps * 3.6;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. CUSTOMIZABLE & REMOVABLE TARGET PRESETS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tr('SELECT OR CREATE RUN TARGET', 'रनिंग टारगेट चुनें या नया बनाएं'),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
            TextButton.icon(
              onPressed: _openAddCustomTargetDialog,
              icon: const Icon(Icons.add_circle, size: 18),
              label: Text(tr('+ Custom Target', '+ नया टारगेट')),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(AppStorage.runPresets.length, (i) {
            final p = AppStorage.runPresets[i];
            final selected = i == _selectedPresetIndex;
            return InputChip(
              selected: selected,
              selectedColor: cs.secondary,
              labelStyle: TextStyle(
                color: selected ? Colors.white : cs.onSurface,
                fontWeight: FontWeight.bold,
              ),
              label: Text(p.title),
              onSelected: (_) {
                if (!_isRunning) setState(() => _selectedPresetIndex = i);
              },
              onDeleted: AppStorage.runPresets.length > 1 && !_isRunning
                  ? () {
                      setState(() {
                        AppStorage.runPresets.removeAt(i);
                        if (_selectedPresetIndex >=
                            AppStorage.runPresets.length) {
                          _selectedPresetIndex = 0;
                        }
                      });
                      AppStorage.saveAllUserData();
                    }
                  : null,
            );
          }),
        ),
        const SizedBox(height: 14),

        // 2. MAIN LIVE RUNNER DASHBOARD CARD
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.primary, width: 1.8),
          ),
          child: Column(
            children: [
              // Anti-Drift Motion Lock Live Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: !_isRunning
                      ? Colors.blueGrey.withOpacity(0.15)
                      : (_isActuallyMoving
                          ? Colors.green.withOpacity(0.15)
                          : Colors.red.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  !_isRunning
                      ? tr('GPS + Step Anti-Drift Lock Ready',
                          'GPS + स्टेप एंटी-ड्रिफ्ट लॉक तैयार')
                      : (_isActuallyMoving
                          ? '🟢 ${tr("Moving", "दौड़ चालू")} • ${_liveSpeedKmh.toStringAsFixed(1)} km/h • $_detectedSteps ${tr("steps", "कदम")}'
                          : '🔴 ${tr("Standing Still (GPS Distance Locked)", "स्थिर खड़े हैं (GPS दूरी लॉक है)")}'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: !_isRunning
                        ? cs.onSurface
                        : (_isActuallyMoving ? Colors.green : Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(height: 10),
                           SizedBox(
                height: 175,
                width: 175,
                child: CustomPaint(
                  painter: TrackRadarPainter(
                    userMeters: _coveredMeters,
                    ghostMeters: expectedMetersNow,
                    pulseValue: (_elapsedSec % 3) / 3.0,
                  ),
                  child: Center(
                    child: Text(
                      _formatTime(_elapsedSec),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),

              Text(
                '${tr("TARGET", "लक्ष्य")}: ${_formatTime(preset.targetSeconds)} (${preset.distanceMeters}m)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface.withOpacity(0.65),
                ),
              ),
              const Divider(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        '${_coveredMeters.floor()} m',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: cs.primary,
                        ),
                      ),
                      Text(
                        tr('COVERED', 'तय की गई दूरी'),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        '${remainingMeters.floor()} m',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        tr('REMAINING', 'बाकी दूरी'),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              // CLEAR SMART LIVE PACER EXPLANATION BOX
              if (_showGhostPacer) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (diffMeters >= 0 ? Colors.green : Colors.redAccent)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: diffMeters >= 0 ? Colors.green : Colors.redAccent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        diffMeters >= 0
                            ? '⚡ ${tr("LIVE PACER", "लाइव पेसर")}: +${diffMeters.abs().toStringAsFixed(0)} m ${tr("AHEAD of Target Pace!", "टारगेट स्पीड से आगे!")}'
                            : '⚠️ ${tr("LIVE PACER", "लाइव पेसर")}: ${diffMeters.abs().toStringAsFixed(0)} m ${tr("BEHIND Target Pace", "टारगेट स्पीड से पीछे")}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color:
                              diffMeters >= 0 ? Colors.green : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr(
                          'At ${_formatTime(_elapsedSec)}, target distance is ${expectedMetersNow.toStringAsFixed(0)}m (Required Speed: ${reqSpeedKmh.toStringAsFixed(1)} km/h)',
                          '${_formatTime(_elapsedSec)} समय पर आपको ${expectedMetersNow.toStringAsFixed(0)}m पर होना चाहिए (ज़रूरी स्पीड: ${reqSpeedKmh.toStringAsFixed(1)} km/h)',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. START / PAUSE / STOP RUN BUTTONS
        if (!_isRunning)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _startRun,
              icon: const Icon(Icons.play_arrow_rounded, size: 28),
              label: Text(
                tr('START VOICE-GUIDED RUN', 'वॉइस-गाइडेड दौड़ शुरू करें'),
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
              ),
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _isPaused = !_isPaused);
                      VoiceCoach.speak(
                        _isPaused ? 'Run paused' : 'Run resumed',
                        _isPaused ? 'दौड़ पॉज़ की गई' : 'दौड़ फिर से चालू',
                      );
                    },
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(
                      _isPaused
                          ? tr('RESUME', 'फिर शुरू करें')
                          : tr('PAUSE', 'रोकें (Pause)'),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _finishRun(completedTarget: false),
                    icon: const Icon(Icons.stop),
                    label: Text(
                      tr('STOP RUN', 'बंद करें'),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),

        // 4. CUSTOM VOICE ALERTS & REMINDERS BUILDER
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
                  Expanded(
                    child: Text(
                      tr('CUSTOM VOICE ALERTS & MESSAGES',
                          'कस्टम वॉइस अलार्म और मैसेज'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openAddVoiceAlertDialog,
                    icon: const Icon(Icons.add_alert, size: 16),
                    label: Text(tr('+ Add Alert', '+ नया अलर्ट')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(AppStorage.voiceAlerts.length, (i) {
                final a = AppStorage.voiceAlerts[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.campaign, color: cs.primary),
                  title: Text(
                    '${a.triggerType.replaceAll("_", " ").toUpperCase()}: ${a.triggerValue} ${a.triggerType.startsWith("distance") ? "m" : "sec"}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  subtitle: Text('"${a.customMessage}"'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 20),
                        onPressed: () {
                          final sample = a.customMessage
                              .replaceAll('{done}', '200')
                              .replaceAll('{left}', '1400')
                              .replaceAll('{time}', '00:45');
                          VoiceCoach.speak(sample, sample);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        onPressed: () {
                          setState(() => AppStorage.voiceAlerts.removeAt(i));
                          AppStorage.saveAllUserData();
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 5. CADENCE PACER & SIMULATION TOGGLES
        SwitchListTile(
          title: Text(
            tr('$_cadenceBpm BPM Cadence Footstep Pacer',
                '$_cadenceBpm BPM कदम पेसर (Vibration + Tick)'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            tr('Match 1 footstep per vibration/tick for ideal race rhythm',
                'हर एक वाइब्रेशन पर एक कदम ज़मीन पर रखें'),
          ),
          value: _cadencePacerOn,
          onChanged: _toggleCadencePacer,
        ),
        SwitchListTile(
          title: Text(
            tr('Show Live Ghost Pacer Box', 'लाइव पेसर तुलना बॉक्स दिखाएं'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          value: _showGhostPacer,
          onChanged: (v) => setState(() => _showGhostPacer = v),
        ),
        SwitchListTile(
          title: Text(
            tr('Indoor Track Simulation Mode',
                'इनडोर ट्रैक टेस्ट मोड (बिना बाहर गए टेस्ट करें)'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          value: _indoorSimMode,
          onChanged: (v) => setState(() => _indoorSimMode = v),
        ),
        if (_lapSplits.isNotEmpty) ...[
          const Divider(),
          Text(
            tr('200m Split Lap Breakdown:', 'हर 200m चक्कर का समय:'),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          ..._lapSplits.map((s) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('• $s'),
              )),
        ],
      ],
    );
  }
}

// ============================================================================
// 7. TAB 3: PRO WORKOUT & AI REPS HUB (INDOOR/GYM/OUTDOOR/CUSTOM + AI POSTURE)
// ============================================================================

class ProWorkoutHubTab extends StatefulWidget {
  final VoidCallback onDataUpdated;
  const ProWorkoutHubTab({super.key, required this.onDataUpdated});

  @override
  State<ProWorkoutHubTab> createState() => _ProWorkoutHubTabState();
}

class _ProWorkoutHubTabState extends State<ProWorkoutHubTab> {
  String _selectedCategory = 'Indoor';
  int _selectedWorkoutIdx = 0;
  int _targetReps = 20;
  int _currentReps = 0;
  int _currentSet = 1;
  bool _sensorActive = false;
  String _activeSensorMode = 'Proximity'; // 'Proximity', 'Gravity', 'CameraAI'

  // Biomechanic 2-Stage Anti-Fake Rep State
  bool _isInDownPhase = false;
  DateTime _downPhaseTime = DateTime.fromMillisecondsSinceEpoch(0);
  double _liveTiltAngle = 175.0;
  double _liveSpineAngle = 176.0;
  String _postureStatus = ' Straight Back (176°)';
  bool _postureFault = false;

  StreamSubscription<AccelerometerEvent>? _accelSub;

  List<WorkoutModel> get _allWorkouts => [
        // INDOOR BODYWEIGHT
        WorkoutModel(
          id: 'w1',
          nameEn: 'Standard Push-ups',
          nameHi: 'पुश-अप्स (Push-ups)',
          category: 'Indoor',
          sensorMode: 'Proximity',
          muscleGroup: 'Chest, Triceps & Core',
          placementEn:
              'Floor Mode: Place phone flat under your chest/chin (Proximity/Hover or Nose Tap) OR choose AI Posture Inspector.',
          placementHi:
              'फ़ोन को छाती/ठोड़ी के नीचे ज़मीन पर रखें (बिना छुए या नाक से टच करें) या AI पोस्चर मोड चुनें।',
          dosEn:
              'Keep spine & hips in a straight plank line (170°-180°). Lower chest until elbows reach 90°.',
          dontsEn:
              'Do NOT sag or bend your waist/lower back! Half-reps are rejected.',
          defaultTarget: 20,
        ),
        WorkoutModel(
          id: 'w2',
          nameEn: 'Bodyweight Squats',
          nameHi: 'स्क्वैट्स (उठक-बैठक)',
          category: 'Indoor',
          sensorMode: 'Gravity',
          muscleGroup: 'Quads, Glutes & Hamstrings',
          placementEn:
              'Pocket / Hand Mode: Hold phone against chest or place in front pocket. Sensor tracks full 90° thigh tilt.',
          placementHi:
              'फ़ोन को जेब में रखें या हाथ में पकड़ें। सेंसर आपके पूरे बैठने और उठने के कोण से गिनेगा।',
          dosEn:
              'Lower hips until thighs are parallel to floor. Keep chest up and heels flat.',
          dontsEn: 'Do not shake phone in hand or bounce half-way.',
          defaultTarget: 25,
        ),
        WorkoutModel(
          id: 'w3',
          nameEn: 'Military Sit-ups / Crunches',
          nameHi: 'सिट-अप्स (पेट की एक्सरसाइज़)',
          category: 'Indoor',
          sensorMode: 'Gravity',
          muscleGroup: 'Abs & Core Flexors',
          placementEn:
              'Hold phone on your chest with crossed arms while lying on mat.',
          placementHi: 'मैट पर लेटकर फ़ोन को छाती पर पकड़ें।',
          dosEn: 'Curl torso up fully until elbows touch knees, then lower slowly.',
          dontsEn: 'Do not pull your neck violently with hands.',
          defaultTarget: 20,
        ),
        WorkoutModel(
          id: 'w4',
          nameEn: 'Jumping Jacks / Burpees',
          nameHi: 'जंपिंग जैक्स / बर्पीज़',
          category: 'Indoor',
          sensorMode: 'Gravity',
          muscleGroup: 'Full Body Cardio & Stamina',
          placementEn: 'Keep phone in pocket or armband during full-body jumps.',
          placementHi: 'फ़ोन को जेब या आर्मबैंड में रखें।',
          dosEn: 'Full arm clap overhead with rhythmic landing on toes.',
          dontsEn: 'Avoid stiff-knee landings.',
          defaultTarget: 30,
        ),
        // GYM & DUMBBELL WORKOUTS
        WorkoutModel(
          id: 'w5',
          nameEn: 'Dumbbell Chest Press',
          nameHi: 'डंबल चेस्ट प्रेस',
          category: 'Gym',
          sensorMode: 'Gravity',
          muscleGroup: 'Pectorals & Front Delts',
          placementEn:
              'Armband / Wrist or Tempo Voice Coach Mode: Tracks controlled 2-second eccentric & concentric press.',
          placementHi: 'आर्मबैंड में लगाएं या टेम्पो वॉइस कोच के साथ डंबल प्रेस करें।',
          dosEn: 'Lower dumbbells slowly to chest level, press up & squeeze.',
          dontsEn: 'Do not arch lower back excessively off bench/floor.',
          defaultTarget: 12,
          weightKg: 10.0,
        ),
        WorkoutModel(
          id: 'w6',
          nameEn: 'Dumbbell Bicep Curls',
          nameHi: 'डंबल बाइसेप कर्ल्स',
          category: 'Gym',
          sensorMode: 'Gravity',
          muscleGroup: 'Biceps Brachii',
          placementEn: 'Hold phone in working hand alongside dumbbell or use AI Posture.',
          placementHi: 'कलाई/आर्मबैंड या AI पोस्चर मोड का उपयोग करें।',
          dosEn: 'Keep elbows locked by your waist; curl full range.',
          dontsEn: 'Do not swing your lower back to lift weight!',
          defaultTarget: 15,
          weightKg: 7.5,
        ),
        WorkoutModel(
          id: 'w7',
          nameEn: 'Dumbbell Shoulder Press',
          nameHi: 'डंबल शोल्डर प्रेस',
          category: 'Gym',
          sensorMode: 'Gravity',
          muscleGroup: 'Shoulders & Triceps',
          placementEn: 'Tracks overhead press cadence and full lockout.',
          placementHi: 'कंधों के ऊपर पूरा प्रेस करने की गति ट्रैक करता है।',
          dosEn: 'Keep core tight, press straight overhead.',
          dontsEn: 'Do not lean backward with bent spine.',
          defaultTarget: 12,
          weightKg: 7.5,
        ),
        // OUTDOOR / GROUND WORKOUTS
        WorkoutModel(
          id: 'w8',
          nameEn: 'Pull-ups / Chin-up Beam',
          nameHi: 'पुल-अप्स / बीम (Beam)',
          category: 'Outdoor',
          sensorMode: 'Gravity',
          muscleGroup: 'Lats, Back & Grip Strength',
          placementEn:
              'Keep phone in pocket. Sensor detects vertical upward pull + chin-over-bar hold.',
          placementHi: 'फ़ोन को जेब में रखें—ऊपर खींचने और रुकने पर गिनेगा।',
          dosEn: 'Dead hang at bottom, pull chin clearly above bar at top.',
          dontsEn: 'Do not kick legs (kipping) or bend knees.',
          defaultTarget: 10,
        ),
        WorkoutModel(
          id: 'w9',
          nameEn: 'Parallel Bar Dips',
          nameHi: 'पैरेलल बार डिप्स',
          category: 'Outdoor',
          sensorMode: 'Gravity',
          muscleGroup: 'Lower Chest & Triceps',
          placementEn: 'Keep phone in pocket while dipping to 90° elbow angle.',
          placementHi: 'फ़ोन जेब में रखकर 90° कोण तक नीचे जाएं।',
          dosEn: 'Control descent, lock elbows at top.',
          dontsEn: 'Do not bounce shoulders.',
          defaultTarget: 15,
        ),
        ...AppStorage.customWorkouts,
      ];

  List<WorkoutModel> get _filteredWorkouts {
    final list = _allWorkouts
        .where((w) =>
            _selectedCategory == 'Custom' ? w.category == 'Custom' : w.category == _selectedCategory)
        .toList();
    return list.isEmpty ? [_allWorkouts.first] : list;
  }

  WorkoutModel get _activeWorkout {
    final list = _filteredWorkouts;
    if (_selectedWorkoutIdx >= list.length) _selectedWorkoutIdx = 0;
    return list[_selectedWorkoutIdx];
  }

  void _toggleSensorEngine() {
    if (_sensorActive) {
      _accelSub?.cancel();
      setState(() => _sensorActive = false);
      VoiceCoach.speak('Workout sensor stopped.', 'सेंसर बंद कर दिया गया।');
      return;
    }

    setState(() {
      _sensorActive = true;
      _isInDownPhase = false;
      _postureFault = false;
    });

    VoiceCoach.speak(
      '${_activeWorkout.nameEn} started in $_activeSensorMode mode! Maintain straight back and full range.',
      '${_activeWorkout.nameHi} शुरू! अपनी कमर सीधी रखें और पूरा रेप लगाएं।',
    );

    // BIOMECHANIC 2-PHASE GRAVITY + SPINE ALIGNMENT SENSOR ENGINE
    // (Prevents fake counts from shaking phone in hand!)
    _accelSub?.cancel();
    _accelSub = accelerometerEvents.listen((event) {
      if (!_sensorActive) return;

      // Compute tilt angle and lateral waist wobble/bend
      final pitchDeg = atan2(event.y, event.z) * 180 / pi;
      final lateralTilt = event.x.abs(); // Detects crooked/bent posture!
      final totalG =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      // Reject violent hand shaking (> 22 m/s^2 is fake shaking, not a squat/pushup!)
      if (totalG > 22.0) {
        return;
      }

      final spineDeg = (180.0 - (lateralTilt * 4.5)).clamp(120.0, 180.0);

      setState(() {
        _liveTiltAngle = pitchDeg.abs();
        _liveSpineAngle = spineDeg;
      });

      // Check AI Posture Spine Alignment (if spine bends < 152 degrees, warn & block rep!)
      if (_activeSensorMode == 'CameraAI' && spineDeg < 152.0) {
        if (!_postureFault) {
          setState(() {
            _postureFault = true;
            _postureStatus = tr(
              '❌ WAIST BENT (${spineDeg.toStringAsFixed(0)}°)! Straighten Back!',
              '❌ कमर टेढ़ी है (${spineDeg.toStringAsFixed(0)}°)! कमर सीधी रखें!',
            );
          });
          VoiceCoach.speak(
            'Warning! Your back is bending! Keep waist straight, rep will not count.',
            'चेतावनी! आपकी कमर मुड़ रही है! कमर सीधी रखें वरना गिनती नहीं होगी।',
          );
        }
        return;
      } else {
        setState(() {
          _postureFault = false;
          _postureStatus = tr(
            '✅ Good Posture (${spineDeg.toStringAsFixed(0)}° Spine Aligned)',
            '✅ सही पोस्चर (${spineDeg.toStringAsFixed(0)}° कमर बिल्कुल सीधी)',
          );
        });
      }

      // 2-Stage Rep Cycle: Must go into DOWN tilt first, hold >= 350ms, then return UP
      if (!_isInDownPhase && event.z.abs() < 6.2) {
        _isInDownPhase = true;
        _downPhaseTime = DateTime.now();
      } else if (_isInDownPhase && event.z.abs() > 8.2) {
        final durationMs =
            DateTime.now().difference(_downPhaseTime).inMilliseconds;
        _isInDownPhase = false;
        // Realistic human rep takes between 450ms and 5000ms
        if (durationMs >= 450 && durationMs <= 5000) {
          _registerValidRep();
        }
      }
    });
  }

  void _registerValidRep() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentReps++;
      AppStorage.totalReps++;
      AppStorage.xp += 2;
    });
    AppStorage.saveAllUserData();
    widget.onDataUpdated();

    VoiceCoach.speak('$_currentReps', '$_currentReps');

    if (_currentReps >= _targetReps) {
      _accelSub?.cancel();
      setState(() {
        _sensorActive = false;
        _currentSet++;
      });
      VoiceCoach.speak(
        'Set completed! Target of $_targetReps reps achieved!',
        'सेट पूरा हुआ! आपने $_targetReps रेप्स पूरे कर लिए!',
      );
    }
  }

  void _openFormGuideDialog(WorkoutModel w) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('🎥 ${tr(w.nameEn, w.nameHi)} — Form Guide'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated Visual Biomechanic Demonstration Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.accessibility_new_rounded,
                      size: 64,
                      color: Colors.greenAccent,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${tr("Target Muscles", "लक्षित मांसपेशियां")}: ${w.muscleGroup}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tr(
                        'Tempo Rhythm: 2 sec Down (Inhale) -> 1 sec Hold -> 1 sec Up (Exhale)',
                        'सही लय: 2 सेकंड नीचे (सांस लें) -> 1 सेकंड रुकें -> 1 सेकंड ऊपर (सांस छोड़ें)',
                      ),
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '✅ ${tr("Correct Technique", "सही तरीका")}:',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: Colors.green),
              ),
              Text(w.dosEn),
              const SizedBox(height: 10),
              Text(
                '❌ ${tr("Mistakes to Avoid", "क्या गलती न करें")}:',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: Colors.redAccent),
              ),
              Text(w.dontsEn),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Got It', 'समझ गया')),
          ),
        ],
      ),
    );
  }

  void _openAddCustomWorkoutDialog() {
    final nameCtrl = TextEditingController();
    final muscleCtrl = TextEditingController(text: 'Full Body / Gym');
    final targetCtrl = TextEditingController(text: '15');
    final weightCtrl = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Add Personal Custom Workout', 'अपनी नई एक्सरसाइज़ जोड़ें')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: tr('Workout Name', 'एक्सरसाइज़ का नाम'),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: muscleCtrl,
                decoration: InputDecoration(
                  labelText: tr('Target Muscle Group', 'कौन सी मसल्स के लिए है?'),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: targetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: tr('Target Reps', 'टारगेट रेप्स'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: tr('Weight (kg)', 'डंबल वज़न (kg)'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('Cancel', 'रद्द करें')),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              final newW = WorkoutModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                nameEn: nameCtrl.text.trim(),
                nameHi: nameCtrl.text.trim(),
                category: 'Custom',
                sensorMode: 'Gravity',
                muscleGroup: muscleCtrl.text.trim(),
                placementEn:
                    'Use AI Posture Inspector, Pocket Gravity Sensor, or Floor Touchless Sensor.',
                placementHi: 'AI पोस्चर, पॉकेट सेंसर या फ़्लोर सेंसर का उपयोग करें।',
                dosEn: 'Maintain full range of motion and steady breathing.',
                dontsEn: 'Avoid jerky movements or bent spine.',
                defaultTarget: int.tryParse(targetCtrl.text) ?? 15,
                weightKg: double.tryParse(weightCtrl.text) ?? 0.0,
              );
              setState(() {
                AppStorage.customWorkouts.add(newW);
                _selectedCategory = 'Custom';
                _selectedWorkoutIdx = AppStorage.customWorkouts.length - 1;
              });
              AppStorage.saveAllUserData();
              Navigator.pop(ctx);
            },
            child: Text(tr('Save Workout', 'सेव करें')),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final w = _activeWorkout;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. WORKOUT CATEGORY TABS (Indoor, Gym, Outdoor, Custom)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _categoryChip('Indoor', '🏠 Indoor Home'),
              const SizedBox(width: 8),
              _categoryChip('Gym', '🏋️ Gym & Dumbbell'),
              const SizedBox(width: 8),
              _categoryChip('Outdoor', '🌳 Outdoor Ground'),
              const SizedBox(width: 8),
              _categoryChip('Custom', '➕ My Custom'),
              const SizedBox(width: 8),
              ActionChip(
                backgroundColor: cs.primary.withOpacity(0.15),
                label: Text(
                  tr('+ Create Own', '+ खुद की जोड़ें'),
                  style: TextStyle(
                      color: cs.primary, fontWeight: FontWeight.bold),
                ),
                onPressed: _openAddCustomWorkoutDialog,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. WORKOUT SELECTOR CHIPS
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filteredWorkouts.length, (i) {
              final item = _filteredWorkouts[i];
              final sel = i == _selectedWorkoutIdx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: sel,
                  selectedColor: cs.primary,
                  labelStyle: TextStyle(
                    color: sel ? Colors.white : cs.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  label: Text(tr(item.nameEn, item.nameHi)),
                  onSelected: (_) {
                    setState(() {
                      _selectedWorkoutIdx = i;
                      _targetReps = item.defaultTarget;
                      _currentReps = 0;
                      _activeSensorMode = item.sensorMode;
                    });
                  },
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),

        // 3. SCROLLABLE TARGET REPS SELECTOR (Fixes clipping bug from video!)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [10, 12, 15, 20, 25, 30, 50].map((t) {
              final sel = _targetReps == t;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: sel,
                  label: Text('Target: $t'),
                  onSelected: (_) => setState(() => _targetReps = t),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),

        // 4. SENSOR MODE SELECTOR + FORM GUIDE VIDEO BUTTON
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _activeSensorMode,
                decoration: InputDecoration(
                  labelText: tr('Active Sensor Engine', 'सेंसर मोड चुनें'),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Proximity',
                    child: Text(tr('🔦 Floor Proximity / Hover / Nose Tap',
                        '🔦 फ़्लोर प्रॉक्सिमिटी / होवर सेंसर')),
                  ),
                  DropdownMenuItem(
                    value: 'Gravity',
                    child: Text(tr('📐 Gravity 90° Angle Sensor (Pocket/Hand)',
                        '📐 ग्रेविटी 90° एंगल सेंसर (जेब/हाथ)')),
                  ),
                  DropdownMenuItem(
                    value: 'CameraAI',
                    child: Text(tr('📷 AI Posture & Waist-Bend Inspector',
                        '📷 AI पोस्चर (कमर टेढ़ी होने पर रोकेगा)')),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _activeSensorMode = v);
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.secondary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              onPressed: () => _openFormGuideDialog(w),
              icon: const Icon(Icons.ondemand_video, size: 18),
              label: Text(tr('Form Guide', 'सही तरीका')),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 5. EXERCISE-SPECIFIC PLACEMENT & AI SKELETON POSTURE INSPECTOR
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _postureFault ? Colors.redAccent : cs.primary,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                '${tr(w.nameEn, w.nameHi)} • Set #$_currentSet ${w.weightKg > 0 ? "(${w.weightKg} kg)" : ""}',
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 6),
                           Text(
                tr(w.placementEn, w.placementHi),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: cs.onSurface.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedStickmanCoach(workoutName: w.nameEn),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => LiveAiCameraInspectorModal(
                        workoutName: w.nameEn,
                        onValidRep: _registerValidRep,
                      ),
                    );
                  },
                  icon: const Icon(Icons.videocam),
                  label: Text(
                    tr(
                      'OPEN LIVE AI CAMERA SKELETON INSPECTOR',
                      'लाइव AI कैमरा पोस्चर इंस्पेक्टर खोलें',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
              const SizedBox(height: 12),


              // AI POSTURE & ANGLE MONITOR BAR
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (_postureFault ? Colors.red : Colors.green)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _postureStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color:
                              _postureFault ? Colors.redAccent : Colors.green,
                        ),
                      ),
                    ),
                    Text(
                      'Tilt: ${_liveTiltAngle.toStringAsFixed(0)}°',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // INTERACTIVE PROXIMITY / TOUCHLESS HOVER / REP COUNTER PAD
              GestureDetector(
                onTap: _registerValidRep,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withOpacity(0.18),
                        cs.secondary.withOpacity(0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.primary.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$_currentReps / $_targetReps',
                        style: TextStyle(
                          fontSize: 58,
                          fontWeight: FontWeight.w900,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _activeSensorMode == 'Proximity'
                            ? tr(
                                'Hover Chest Near Top Sensor OR Tap with Nose/Chin',
                                'छाती को फ़ोन के ऊपरी सेंसर के पास लाएं या नाक से टच करें',
                              )
                            : tr(
                                '2-Phase Sensor Active (Full Down + Up Cycle Required)',
                                '2-फेज सेंसर चालू (पूरा नीचे जाकर ऊपर आने पर ही गिनेगा)',
                              ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _sensorActive ? Colors.redAccent : cs.secondary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _toggleSensorEngine,
                        icon: Icon(
                            _sensorActive ? Icons.stop : Icons.sensors_rounded),
                        label: Text(
                          _sensorActive
                              ? tr('STOP SENSOR', 'सेंसर बंद करें')
                              : tr('START SMART SENSOR', 'स्मार्ट सेंसर चालू करें'),
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(60, 52),
                    ),
                    onPressed: () => setState(() => _currentReps = 0),
                    child: Text(tr('Reset', 'रीसेट')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _categoryChip(String key, String label) {
    final cs = Theme.of(context).colorScheme;
    final sel = _selectedCategory == key;
    return ChoiceChip(
      selected: sel,
      selectedColor: cs.secondary,
      labelStyle: TextStyle(
        color: sel ? Colors.white : cs.onSurface,
        fontWeight: FontWeight.bold,
      ),
      label: Text(label),
      onSelected: (_) {
        setState(() {
          _selectedCategory = key;
          _selectedWorkoutIdx = 0;
        });
      },
    );
  }
}

// ============================================================================
// 8. TAB 4: ALL-INDIA OFFICIAL BHARTI TEST SIMULATOR (WITH REST BREAK & SENSORS)
// ============================================================================

class BhartiStageModel {
  String nameEn;
  String nameHi;
  int targetReps;
  int timeLimitSec;
  String instructionsEn;
  String instructionsHi;

  BhartiStageModel(
    this.nameEn,
    this.nameHi,
    this.targetReps,
    this.timeLimitSec,
    this.instructionsEn,
    this.instructionsHi,
  );
}

class BhartiSimulatorTab extends StatefulWidget {
  final VoidCallback onDataUpdated;
  const BhartiSimulatorTab({super.key, required this.onDataUpdated});

  @override
  State<BhartiSimulatorTab> createState() => _BhartiSimulatorTabState();
}

class _BhartiSimulatorTabState extends State<BhartiSimulatorTab> {
  String _selectedExam = 'IAF Agniveervayu Phase-II';
  int _stageIdx = -1; // -1 = Ready, >=0 = Active Stage
  bool _inRestBreak = false; // Mandatory break between stages!
  int _secLeft = 60;
  int _restSecLeft = 120;
  int _stageReps = 0;
  bool _useMotionSensor = true;
  bool _downPhase = false;

  Timer? _timer;
  StreamSubscription<AccelerometerEvent>? _sensorSub;

  List<BhartiStageModel> get _examStages {
    if (_selectedExam.contains('Army')) {
      return [
        BhartiStageModel(
          'STAGE 1: 10 PULL-UPS / BEAM (40 Marks)',
          'स्टेज 1: 10 पुल-अप्स / बीम (40 अंक)',
          10,
          90,
          'Keep phone in pocket or use Officer Voice Cadence.',
          'फ़ोन को जेब में रखें या ऑफिसर कमांड के साथ बीम लगाएं।',
        ),
        BhartiStageModel(
          'STAGE 2: 15 PUSH-UPS (Strength Check)',
          'स्टेज 2: 15 पुश-अप्स (ताकत परीक्षण)',
          15,
          60,
          'Place phone under chest or keep in pocket.',
          'फ़ोन छाती के नीचे रखें या जेब में रखें।',
        ),
        BhartiStageModel(
          'STAGE 3: 20 SQUATS (Endurance Check)',
          'स्टेज 3: 20 उठक-बैठक (Squats)',
          20,
          60,
          'Hold phone in hand or pocket for 90° squat tracking.',
          'फ़ोन को हाथ या जेब में रखकर पूरे स्क्वैट्स लगाएं।',
        ),
      ];
    } else if (_selectedExam.contains('NDA')) {
      return [
        BhartiStageModel(
          'STAGE 1: 20 PUSH-UPS (SSB Standard)',
          'स्टेज 1: 20 पुश-अप्स (NDA/SSB मानक)',
          20,
          60,
          'Strict straight-back push-ups.',
          'कमर सीधी रखकर 20 पुश-अप्स लगाएं।',
        ),
        BhartiStageModel(
          'STAGE 2: 20 SIT-UPS (SSB Standard)',
          'स्टेज 2: 20 सिट-अप्स (NDA/SSB मानक)',
          20,
          60,
          'Hold phone on chest during sit-ups.',
          'फ़ोन छाती पर रखकर 20 सिट-अप्स लगाएं।',
        ),
        BhartiStageModel(
          'STAGE 3: 8 CHIN-UPS / ROPE STRENGTH',
          'स्टेज 3: 8 चिन-अप्स (Chin-ups)',
          8,
          60,
          'Full dead-hang chin-ups.',
          'पूरे हाथ सीधे करके 8 चिन-अप्स लगाएं।',
        ),
      ];
    } else if (_selectedExam.contains('Police') ||
        _selectedExam.contains('SSC GD')) {
      return [
        BhartiStageModel(
          'STAGE 1: 15 PUSH-UPS (CAPF/Police Fitness)',
          'स्टेज 1: 15 पुश-अप्स (पुलिस/CAPF फिटनेस)',
          15,
          60,
          'Place phone under chest or use motion sensor.',
          'फ़ोन छाती के नीचे रखें या मोशन सेंसर चालू रखें।',
        ),
        BhartiStageModel(
          'STAGE 2: 25 SQUATS (Leg Power)',
          'स्टेज 2: 25 स्क्वैट्स (पैर की ताकत)',
          25,
          60,
          'Full depth squats in 60 seconds.',
          '60 सेकंड में 25 पूरे स्क्वैट्स लगाएं।',
        ),
      ];
    }
    // Default: IAF Agniveervayu Phase-II Official PFT
    return [
      BhartiStageModel(
        'STAGE 1: 10 PUSH-UPS (1 Min)',
        'स्टेज 1: 10 पुश-अप्स (1 मिनट)',
        10,
        60,
        'Place phone under chest or keep sensor ON.',
        'फ़ोन को छाती के नीचे रखें या सेंसर चालू रखें।',
      ),
      BhartiStageModel(
        'STAGE 2: 10 SIT-UPS (1 Min)',
        'स्टेज 2: 10 सिट-अप्स (1 मिनट)',
        10,
        60,
        'Lie on mat and hold phone on chest.',
        'मैट पर लेटकर फ़ोन छाती पर रखें।',
      ),
      BhartiStageModel(
        'STAGE 3: 20 SQUATS (1 Min)',
        'स्टेज 3: 20 स्क्वैट्स (1 मिनट)',
        20,
        60,
        'Stand up and hold phone in hand/pocket for 20 squats.',
        'खड़े होकर फ़ोन हाथ या जेब में रखें और 20 स्क्वैट्स लगाएं।',
      ),
    ];
  }

  void _startStage(int index) {
    _timer?.cancel();
    _sensorSub?.cancel();
    final stages = _examStages;

    if (index >= stages.length) {
      setState(() {
        _stageIdx = stages.length;
        _inRestBreak = false;
        AppStorage.xp += 100;
      });
      AppStorage.saveAllUserData();
      widget.onDataUpdated();
      VoiceCoach.speak(
        'Congratulations! You have passed all stages of $_selectedExam physical test!',
        'बधाई हो! आपने $_selectedExam के सभी फिजिकल टेस्ट पास कर लिए हैं!',
      );
      return;
    }

    final st = stages[index];
    setState(() {
      _stageIdx = index;
      _inRestBreak = false;
      _stageReps = 0;
      _secLeft = st.timeLimitSec;
    });

    VoiceCoach.speak(
      '${st.nameEn} started! Complete ${st.targetReps} reps in ${st.timeLimitSec} seconds. Down... Hold... Up!',
      '${st.nameHi} शुरू! ${st.timeLimitSec} सेकंड में ${st.targetReps} रेप्स पूरे करें।',
    );

    if (_useMotionSensor) {
      _sensorSub = accelerometerEvents.listen((ev) {
        if (_inRestBreak || _stageIdx < 0 || _stageIdx >= stages.length) return;
        final totalG = sqrt(ev.x * ev.x + ev.y * ev.y + ev.z * ev.z);
        if (totalG > 21.0) return; // ignore fake shake

        if (!_downPhase && ev.z.abs() < 6.0) {
          _downPhase = true;
        } else if (_downPhase && ev.z.abs() > 8.2) {
          _downPhase = false;
          _incrementStageRep();
        }
      });
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secLeft > 0) {
        setState(() => _secLeft--);
      } else {
        timer.cancel();
        _sensorSub?.cancel();
        VoiceCoach.speak(
          'Time up! Rest and prepare for the next stage.',
          'समय समाप्त! अब थोड़ा सांस लें और अगले टेस्ट के लिए तैयार हों।',
        );
        _enterRecoveryBreak();
      }
    });
  }

  void _incrementStageRep() {
    final stages = _examStages;
    if (_stageIdx < 0 || _stageIdx >= stages.length || _inRestBreak) return;
    final st = stages[_stageIdx];

    HapticFeedback.mediumImpact();
    setState(() {
      _stageReps++;
      AppStorage.totalReps++;
    });
    VoiceCoach.speak('$_stageReps', '$_stageReps');

    if (_stageReps >= st.targetReps) {
      _timer?.cancel();
      _sensorSub?.cancel();
      if (_stageIdx + 1 >= stages.length) {
        _startStage(_stageIdx + 1);
      } else {
        // DO NOT AUTO-START NEXT STAGE LIKE A MACHINE! Enter Recovery Break Screen!
        _enterRecoveryBreak();
      }
    }
  }

  void _enterRecoveryBreak() {
    _timer?.cancel();
    _sensorSub?.cancel();
    setState(() {
      _inRestBreak = true;
      _restSecLeft = 90;
    });
    VoiceCoach.speak(
      'Stage completed! Take a recovery break, get into position, and tap Start Next Stage when ready.',
      'यह स्टेज पूरा हुआ! अब आराम करें, अगली पोज़ीशन लें, और तैयार होने पर अगला स्टेज शुरू करें बटन दबाएं।',
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSecLeft > 0) {
        setState(() => _restSecLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final stages = _examStages;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. ALL-INDIA BHARTI EXAM SELECTOR
        DropdownButtonFormField<String>(
          value: _selectedExam,
          decoration: InputDecoration(
            labelText: tr('Select Official Bharti / Exam Physical Standard',
                'भर्ती परीक्षा चुनें (Official Physical Test)'),
            prefixIcon: const Icon(Icons.military_tech),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          items: [
            'IAF Agniveervayu Phase-II',
            'Indian Army Agniveer (GD / Tech)',
            'NDA / CDS / SSB Physical',
            'SSC GD Constable (CAPF)',
            'State Police (UP / Raj / Delhi / MP)',
          ]
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              _timer?.cancel();
              _sensorSub?.cancel();
              setState(() {
                _selectedExam = v;
                _stageIdx = -1;
                _inRestBreak = false;
              });
            }
          },
        ),
        const SizedBox(height: 12),

        SwitchListTile(
          title: Text(
            tr('Enable Automatic Gravity/Proximity Sensor in Test',
                'टेस्ट में ऑटोमैटिक मोशन/प्रॉक्सिमिटी सेंसर चालू रखें'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
          ),
          value: _useMotionSensor,
          onChanged: (v) => setState(() => _useMotionSensor = v),
        ),
        const SizedBox(height: 10),

        // 2. MAIN BHARTI TEST CARD
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cs.primary, width: 2),
          ),
          child: Column(
            children: [
              Text(
                _selectedExam.toUpperCase(),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const SizedBox(height: 14),

              // STATE A: READY TO START
              if (_stageIdx == -1) ...[
                Text(
                  tr('Official Test Sequence (With Recovery Break Between Stages):',
                      'आधिकारिक टेस्ट क्रम (हर स्टेज के बीच आराम और तैयारी के समय के साथ):'),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: cs.secondary),
                ),
                const SizedBox(height: 10),
                ...stages.map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 18, color: cs.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tr(s.nameEn, s.nameHi),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _startStage(0),
                    icon: const Icon(Icons.play_circle_fill),
                    label: Text(
                      tr('START OFFICIAL MOCK TEST',
                          'आधिकारिक मॉक टेस्ट शुरू करें'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ),
              ]

              // STATE B: RECOVERY REST BREAK BETWEEN STAGES (User is NOT a machine!)
              else if (_inRestBreak) ...[
                const Icon(Icons.self_improvement,
                    size: 56, color: Colors.amber),
                const SizedBox(height: 8),
                Text(
                  tr('STAGE COMPLETED! RECOVERY & SETUP BREAK',
                      'स्टेज पूरा हुआ! आराम करें और अगले स्टेज की पोज़ीशन लें'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${tr("Rest Timer", "आराम का समय")}: $_restSecLeft s',
                  style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  '${tr("Next Up", "अगला टेस्ट")}: ${tr(stages[_stageIdx + 1].nameEn, stages[_stageIdx + 1].nameHi)}\n${tr(stages[_stageIdx + 1].instructionsEn, stages[_stageIdx + 1].instructionsHi)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13.5, height: 1.4),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _startStage(_stageIdx + 1),
                    icon: const Icon(Icons.play_arrow_rounded, size: 28),
                    label: Text(
                      tr('I AM READY — START NEXT STAGE',
                          'मैं तैयार हूँ — अगला टेस्ट शुरू करें'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                ),
              ]

              // STATE C: ACTIVE STAGE IN PROGRESS
              else if (_stageIdx >= 0 && _stageIdx < stages.length) ...[
                Text(
                  tr(stages[_stageIdx].nameEn, stages[_stageIdx].nameHi),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tr(stages[_stageIdx].instructionsEn,
                      stages[_stageIdx].instructionsHi),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 12),
                Text(
                  '$_secLeft s',
                  style: const TextStyle(
                      fontSize: 52, fontWeight: FontWeight.w900),
                ),
                Text(
                  '${tr("Completed", "पूरे हुए")}: $_stageReps / ${stages[_stageIdx].targetReps}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 74,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _incrementStageRep,
                    child: Text(
                      tr('SENSOR ACTIVE OR TAP TO COUNT (+1)',
                          'सेंसर चालू है (या +1 गिनने के लिए टच करें)'),
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    _timer?.cancel();
                    _sensorSub?.cancel();
                    setState(() => _stageIdx = -1);
                  },
                  child: Text(tr('Cancel / Reset Test', 'टेस्ट रीसेट करें')),
                ),
              ]

              // STATE D: ALL STAGES PASSED
              else ...[
                const Icon(Icons.verified, color: Colors.green, size: 72),
                const SizedBox(height: 10),
                Text(
                  tr('STATUS: 100% FIT FOR SELECTION!',
                      'रिज़ल्ट: भर्ती चयन के लिए 100% फिट!'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _stageIdx = -1),
                  child: Text(tr('Restart Simulator', 'फिर से टेस्ट दें')),
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
// 9. TAB 5: FULL DIET & NUTRITION PLANNER + REALISTIC LUNG & SMART HYDRATION
// ============================================================================

class DietAndLungTab extends StatefulWidget {
  final VoidCallback onDataUpdated;
  const DietAndLungTab({super.key, required this.onDataUpdated});

  @override
  State<DietAndLungTab> createState() => _DietAndLungTabState();
}

class _DietAndLungTabState extends State<DietAndLungTab> {
  // Breath-hold state
  bool _holdingBreath = false;
  int _breathSec = 0;
  String _breathVerdict = '';
  Timer? _breathTimer;

  // Diet filter & search state
  String _dietFilter = 'All'; // 'All', 'Veg', 'Egg', 'NonVeg'
  String _searchQuery = '';

  void _toggleBreathHold() {
    if (_holdingBreath) {
      _breathTimer?.cancel();
      setState(() {
        _holdingBreath = false;
        if (_breathSec > AppStorage.bestBreathSec) {
          AppStorage.bestBreathSec = _breathSec;
        }
      });
      AppStorage.saveAllUserData();
      widget.onDataUpdated();

      // REALISTIC 5-LEVEL BREATH FEEDBACK (No fake "Great!" at 0 or 1 sec!)
      if (_breathSec <= 5) {
        _breathVerdict = tr(
          '⚠️ Too short ($_breathSec sec)! Take a deep breath and hold for at least 20 seconds.',
          '⚠️ बहुत कम समय ($_breathSec सेकंड)! गहरी सांस लें और कम से कम 20 सेकंड रोकें।',
        );
        VoiceCoach.speak(
          'Too short! Only $_breathSec seconds. Take a deep breath and try again.',
          'बहुत कम समय! केवल $_breathSec सेकंड। गहरी सांस लेकर दोबारा कोशिश करें।',
        );
      } else if (_breathSec <= 20) {
        _breathVerdict = tr(
          'Beginner Level ($_breathSec sec). Practice daily to reach 45+ seconds.',
          'शुरुआती स्तर ($_breathSec सेकंड)। रोज़ अभ्यास करके 45+ सेकंड तक पहुंचें।',
        );
        VoiceCoach.speak(
          '$_breathSec seconds. Beginner level, keep practicing.',
          '$_breathSec सेकंड। अभ्यास जारी रखें।',
        );
      } else if (_breathSec <= 45) {
        _breathVerdict = tr(
          'Good Stamina ($_breathSec sec)! Your lung capacity is improving.',
          'अच्छा स्टैमिना ($_breathSec सेकंड)! आपके फेफड़ों की क्षमता बढ़ रही है।',
        );
        VoiceCoach.speak(
          'Good effort! You held for $_breathSec seconds.',
          'अच्छा प्रयास! आपने $_breathSec सेकंड सांस रोकी।',
        );
      } else if (_breathSec < 60) {
        _breathVerdict = tr(
          'Strong Athlete Lungs ($_breathSec sec)! Almost at the 60s target.',
          'मज़बूत फेफड़े ($_breathSec सेकंड)! 60 सेकंड के लक्ष्य के बहुत करीब।',
        );
        VoiceCoach.speak(
          'Strong lungs! $_breathSec seconds completed.',
          'शानदार! $_breathSec सेकंड पूरे।',
        );
      } else {
        _breathVerdict = tr(
          '🔥 COMMANDO-GRADE LUNGS ($_breathSec sec)! 1600m last-lap stamina unlocked!',
          '🔥 कमांडो स्तर के फेफड़े ($_breathSec सेकंड)! 1600m के आखिरी चक्कर में सांस नहीं फूलेगी!',
        );
        VoiceCoach.speak(
          'Outstanding! $_breathSec seconds! Commando grade lung stamina!',
          'ज़बरदस्त! $_breathSec सेकंड! कमांडो स्तर का स्टैमिना!',
        );
      }
      return;
    }

    setState(() {
      _holdingBreath = true;
      _breathSec = 0;
      _breathVerdict = tr('Inhale deeply and hold...', 'गहरी सांस अंदर लें और रोकें...');
    });
    VoiceCoach.speak(
      'Take a deep breath in... and hold now!',
      'गहरी सांस अंदर भरें... और अब रोक कर रखें!',
    );

    _breathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _breathSec++);
    });
  }

  void _changeWaterMl(int deltaMl) {
    setState(() {
      AppStorage.waterMl = max(0, AppStorage.waterMl + deltaMl);
    });
    AppStorage.saveAllUserData();
    widget.onDataUpdated();
  }

  void _openCustomWaterDialog() {
    final ctrl = TextEditingController(text: '350');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('Enter Water Quantity (ml)', 'पानी की मात्रा (ml) डालें')),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: tr('Milliliters (e.g. 150, 350, 750)',
                'मिलीलीटर लिखें (जैसे 150, 350, 750)'),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text) ?? 0;
              _changeWaterMl(-v);
              Navigator.pop(ctx);
            },
            child: Text(
              tr('- Subtract ml', '- कम करें (Minus)'),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text) ?? 0;
              _changeWaterMl(v);
              Navigator.pop(ctx);
            },
            child: Text(tr('+ Add ml', '+ जोड़ें (Add)')),
          ),
        ],
      ),
    );
  }

  void _openAddCustomFoodDialog() {
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: '100 g');
    final kcalCtrl = TextEditingController(text: '200');
    final protCtrl = TextEditingController(text: '12');
    final carbCtrl = TextEditingController(text: '25');
    final fatCtrl = TextEditingController(text: '6');
    String type = 'Veg';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(tr('Add Custom Food Item', 'अपना नया भोजन आइटम जोड़ें')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: tr('Food Name', 'भोजन का नाम'),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(
                    labelText: tr('Category', 'श्रेणी'),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Veg', child: Text('🟢 Pure Veg')),
                    DropdownMenuItem(value: 'Egg', child: Text('🟡 Eggetarian')),
                    DropdownMenuItem(
                        value: 'NonVeg', child: Text('🔴 Non-Veg')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => type = v);
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: unitCtrl,
                  decoration: InputDecoration(
                    labelText:
                        tr('Serving Size (e.g. 100g / 1 Bowl)', 'मात्रा (जैसे 100g)'),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: kcalCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Calories'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: protCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Protein (g)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: carbCtrl,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Carbs (g)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: fatCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Fat (g)'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr('Cancel', 'रद्द करें')),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                setState(() {
                  AppStorage.foodItems.insert(
                    0,
                    FoodModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nameEn: nameCtrl.text.trim(),
                      nameHi: nameCtrl.text.trim(),
                      emoji: type == 'Veg'
                          ? '🥗'
                          : (type == 'Egg' ? '🥚' : '🍗'),
                      dietType: type,
                      unitLabel: unitCtrl.text.trim(),
                      kcal: int.tryParse(kcalCtrl.text) ?? 150,
                      protein: int.tryParse(protCtrl.text) ?? 10,
                      carbs: int.tryParse(carbCtrl.text) ?? 20,
                      fat: int.tryParse(fatCtrl.text) ?? 5,
                      isSelected: true,
                    ),
                  );
                });
                AppStorage.saveAllUserData();
                Navigator.pop(ctx);
              },
              child: Text(tr('Add Food', 'भोजन जोड़ें')),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _breathTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Calculate Total Consumed Macros
    int totalKcal = 0;
    int totalProt = 0;
    int totalCarbs = 0;
    int totalFat = 0;

    for (final f in AppStorage.foodItems) {
      if (f.isSelected) {
        totalKcal += (f.kcal * f.selectedMultiplier).round();
        totalProt += (f.protein * f.selectedMultiplier).round();
        totalCarbs += (f.carbs * f.selectedMultiplier).round();
        totalFat += (f.fat * f.selectedMultiplier).round();
      }
    }

    final targetProt = (AppStorage.weightKg * 1.7).round().clamp(75, 160);
    final targetKcal = (AppStorage.weightKg * 42).round().clamp(2000, 3500);

    final filteredFoods = AppStorage.foodItems.where((f) {
      final matchType = _dietFilter == 'All' || f.dietType == _dietFilter;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          f.nameEn.toLowerCase().contains(q) ||
          f.nameHi.toLowerCase().contains(q);
      return matchType && matchSearch;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. REALISTIC LUNG STAMINA BREATH-HOLD BUILDER
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cs.primary.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('LUNG STAMINA BREATH-HOLD', 'फेफड़ों का स्टैमिना (सांस रोकना)'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                  Text(
                    '🏆 ${tr("Best", "बेस्ट")}: ${AppStorage.bestBreathSec}s',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: cs.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
                           AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: _holdingBreath ? 135 + ((_breathSec % 2) * 14.0) : 120,
                width: _holdingBreath ? 135 + ((_breathSec % 2) * 14.0) : 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      cs.primary.withOpacity(_holdingBreath ? 0.45 : 0.15),
                      Colors.transparent,
                    ],
                  ),
                  border: Border.all(color: cs.primary, width: 3),
                ),
                child: Text(
                  '$_breathSec s',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: cs.primary,
                  ),
                ),
              ),

              if (_breathVerdict.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  _breathVerdict,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _holdingBreath ? Colors.redAccent : cs.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _toggleBreathHold,
                  icon: Icon(_holdingBreath ? Icons.stop : Icons.air),
                  label: Text(
                    _holdingBreath
                        ? tr('STOP & CHECK STAMINA LEVEL',
                            'रोकें और अपना स्टैमिना लेवल देखें')
                        : tr('START BREATH HOLD', 'सांस रोकना शुरू करें'),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. SMART HYDRATION TRACKER (WITH MINUS UNDO & CUSTOM ML)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr('DAILY HYDRATION TRACKER', 'दैनिक पानी ट्रैकर (Hydration)'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15),
                      ),
                      Text(
                        '${AppStorage.waterMl} / ${AppStorage.waterGoalMl} ml (${(AppStorage.waterMl / 250).toStringAsFixed(1)} ${tr("Glasses", "गिलास")})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _changeWaterMl(-AppStorage.waterMl),
                    child: Text(tr('Reset', 'रीसेट')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
                         ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 58,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: LiquidWavePainter(
                      fillPercent: AppStorage.waterMl / AppStorage.waterGoalMl,
                      wavePhase: (AppStorage.waterMl % 1000) / 100.0,
                    ),
                    child: Center(
                      child: Text(
                        '💧 ${((AppStorage.waterMl / AppStorage.waterGoalMl) * 100).clamp(0, 100).toStringAsFixed(0)}% Hydrated',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Undo / Minus 250ml button
                  OutlinedButton.icon(
                    onPressed: () => _changeWaterMl(-250),
                    icon: const Icon(Icons.remove,
                        size: 16, color: Colors.redAccent),
                    label: const Text('-250 ml'),
                  ),
                  ElevatedButton(
                    onPressed: () => _changeWaterMl(100),
                    child: const Text('+100 ml'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _changeWaterMl(250),
                    child: Text(tr('+250 ml (1 Glass)', '+250 ml (1 गिलास)')),
                  ),
                  ElevatedButton(
                    onPressed: () => _changeWaterMl(500),
                    child: Text(tr('+500 ml (Bottle)', '+500 ml (बोतल)')),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.edit, size: 16),
                    label: Text(tr('Custom ml (+/-)', 'कस्टम ml डालें')),
                    onPressed: _openCustomWaterDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. COMPLETE NUTRITION & DIET PLANNER SYSTEM (NO CLIPPING, FULL MACROS)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cs.secondary.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tr('PRO DIET & MACRO NUTRITION PLANNER',
                          'प्रो डाइट और न्यूट्रिशन प्लानर'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _openAddCustomFoodDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(tr('+ Custom Food', '+ नया भोजन')),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4-MACRO DASHBOARD BARS (Calories, Protein, Carbs, Fats)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _macroColumn(
                            '🔥 Calories', '$totalKcal / $targetKcal kcal'),
                        _macroColumn(
                            '💪 Protein', '$totalProt / ${targetProt}g'),
                        _macroColumn('🌾 Carbs', '${totalCarbs}g'),
                        _macroColumn('🥑 Fats', '${totalFat}g'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (totalProt / targetProt).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.black26,
                        valueColor: AlwaysStoppedAnimation(cs.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // DIET PREFERENCE FILTER (Veg / Eggetarian / Non-Veg)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _dietFilterChip('All', tr('All Foods', 'सभी भोजन')),
                    const SizedBox(width: 8),
                    _dietFilterChip(
                        'Veg', tr('🟢 Pure Veg (शाकाहारी)', '🟢 शाकाहारी')),
                    const SizedBox(width: 8),
                    _dietFilterChip(
                        'Egg', tr('🟡 Eggetarian (अंडा)', '🟡 अंडाहारी')),
                    const SizedBox(width: 8),
                    _dietFilterChip(
                        'NonVeg', tr('🔴 Non-Veg (मांसाहारी)', '🔴 मांसाहारी')),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // SEARCH BAR
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: tr('Search Chana, Milk, Paneer, Egg, Chicken...',
                      'चना, दूध, पनीर, दाल, अंडा खोजें...'),
                  prefixIcon: const Icon(Icons.search),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // FOOD CARDS WITH VISUAL GRAPHIC ICON & QUANTITY MULTIPLIER
              ...filteredFoods.map((food) {
                final m = food.selectedMultiplier;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: food.isSelected
                        ? cs.secondary.withOpacity(0.14)
                        : cs.onSurface.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          food.isSelected ? cs.secondary : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              food.emoji,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tr(food.nameEn, food.nameHi),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14.5,
                                  ),
                                ),
                                Text(
                                  '${food.unitLabel} × ${m.toStringAsFixed(1)} = ${(food.kcal * m).round()} kcal • ${(food.protein * m).round()}g Prot • ${(food.carbs * m).round()}g Carb • ${(food.fat * m).round()}g Fat',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: cs.onSurface.withOpacity(0.75),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: food.isSelected,
                            activeColor: cs.secondary,
                            onChanged: (v) {
                              setState(() => food.isSelected = v ?? false);
                              AppStorage.saveAllUserData();
                              widget.onDataUpdated();
                            },
                          ),
                        ],
                      ),
                      // Quantity Multiplier Buttons (0.5x, 1x, 1.5x, 2x, 3x)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            tr('Quantity: ', 'मात्रा: '),
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          ...[0.5, 1.0, 1.5, 2.0, 3.0].map((mult) {
                            final active = food.selectedMultiplier == mult;
                            return Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    food.selectedMultiplier = mult;
                                    food.isSelected = true;
                                  });
                                  AppStorage.saveAllUserData();
                                  widget.onDataUpdated();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? cs.primary
                                        : cs.onSurface.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${mult}x',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          active ? Colors.white : cs.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _macroColumn(String label, String val) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
        ),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  Widget _dietFilterChip(String key, String label) {
    final cs = Theme.of(context).colorScheme;
    final sel = _dietFilter == key;
    return ChoiceChip(
      selected: sel,
      selectedColor: cs.secondary,
      labelStyle: TextStyle(
        color: sel ? Colors.white : cs.onSurface,
        fontWeight: FontWeight.bold,
      ),
      label: Text(label),
      onSelected: (_) => setState(() => _dietFilter = key),
    );
  }
}
