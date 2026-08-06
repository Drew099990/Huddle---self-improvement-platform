import 'package:hive_flutter/hive_flutter.dart';

class ActivityLog {
  static bool _initialized = false;

  static Future<void> _ensureInit() async {
    if (!_initialized) {
      await Hive.initFlutter();
      _initialized = true;
    }
  }

  static Future<Box> _openBox() async {
    await _ensureInit();
    if (Hive.isBoxOpen('activityLog')) {
      return Hive.box('activityLog');
    }
    return await Hive.openBox('activityLog');
  }

  static Future<void> add(String message) async {
    final box = await _openBox();
    final raw = box.get('activities', defaultValue: <dynamic>[]);
    final activities = <Map<String, String>>[];

    if (raw is List) {
      activities.addAll(
        raw.whereType<Map>().map((map) => map.cast<String, String>()),
      );
    }

    activities.insert(0, {
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (activities.length > 20) {
      activities.removeRange(20, activities.length);
    }

    await box.put('activities', activities);
  }

  static Future<List<Map<String, String>>> latest(int limit) async {
    final box = await _openBox();
    final raw = box.get('activities', defaultValue: <dynamic>[]);
    final activities = <Map<String, String>>[];

    if (raw is List) {
      activities.addAll(
        raw.whereType<Map>().map((map) => map.cast<String, String>()),
      );
    }

    return activities.take(limit).toList();
  }

  static String formatAge(String iso) {
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
