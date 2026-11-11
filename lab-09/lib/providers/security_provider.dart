import 'package:flutter/foundation.dart';

import '../services/hive_service.dart';

class SecurityProvider extends ChangeNotifier {
  SecurityProvider(this._hive);

  final HiveService _hive;

  bool _busy = false;
  String _log = '';

  bool get busy => _busy;
  String get log => _log;

  Future<void> demoWrongKey() => _run(_hive.demoWrongKey);
  Future<void> compactAll() => _run(_hive.compactAll);

  Future<void> _run(Future<String> Function() f) async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    try {
      _log = await f();
    } catch (e) {
      _log = 'Ошибка: $e';
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
