import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _storageKey = 'birdle_users';

  Future<List<Map<String, Object?>>> _readUsers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return <Map<String, Object?>>[];
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, Object?>>();
  }

  Future<void> _writeUsers(List<Map<String, Object?>> users) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(users));
  }

  Future<int> _nextId(List<Map<String, Object?>> users) async {
    if (users.isEmpty) {
      return 1;
    }
    final List<int> ids = users.map((u) => u['id'] as int).toList();
    return ids.reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<bool> registerUser(
    String username,
    String password, {
    bool termsAccepted = false,
  }) async {
    final List<Map<String, Object?>> users = await _readUsers();

    final bool exists = users.any((u) => u['username'] == username);
    if (exists) {
      return false;
    }

    final String passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
    final String now = DateTime.now().toIso8601String();
    final int newId = await _nextId(users);

    users.add(<String, Object?>{
      'id': newId,
      'username': username,
      'password_hash': passwordHash,
      'terms_accepted': termsAccepted ? 1 : 0,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
      'last_login': null,
    });

    await _writeUsers(users);
    return true;
  }

  Future<bool> loginUser(String username, String password) async {
    final List<Map<String, Object?>> users = await _readUsers();
    final int index = users.indexWhere((u) => u['username'] == username);

    if (index == -1) {
      return false;
    }

    final String storedHash = users[index]['password_hash'] as String;
    final bool valid = BCrypt.checkpw(password, storedHash);

    if (valid) {
      final String now = DateTime.now().toIso8601String();
      users[index]['last_login'] = now;
      users[index]['updated_at'] = now;
      await _writeUsers(users);
    }

    return valid;
  }

  Future<List<Map<String, Object?>>> getUsers() async {
    final List<Map<String, Object?>> users = await _readUsers();
    users.sort((a, b) => (b['id'] as int).compareTo(a['id'] as int));
    return users;
  }

  Future<bool> deleteUser(String username) async {
    final List<Map<String, Object?>> users = await _readUsers();
    final int before = users.length;
    users.removeWhere((u) => u['username'] == username);

    if (users.length == before) {
      return false;
    }

    await _writeUsers(users);
    return true;
  }

  Future<bool> updatePassword(String username, String newPassword) async {
    final List<Map<String, Object?>> users = await _readUsers();
    final int index = users.indexWhere((u) => u['username'] == username);

    if (index == -1) {
      return false;
    }

    users[index]['password_hash'] = BCrypt.hashpw(newPassword, BCrypt.gensalt());
    users[index]['updated_at'] = DateTime.now().toIso8601String();

    await _writeUsers(users);
    return true;
  }
}