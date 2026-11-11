import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/app_user.dart';

class SessionProvider extends ChangeNotifier {
  SessionProvider(this._users) : _current = _users.values.first;

  final Box<AppUser> _users;
  AppUser _current;

  AppUser get user => _current;
  List<AppUser> get users => _users.values.toList();

  void switchUser(AppUser u) {
    if (u.id == _current.id) return;
    _current = u;
    notifyListeners();
  }
}
