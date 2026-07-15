import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    // En Windows/Linux/macOS usamos sqflite_common_ffi
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final String databasesPath = await getDatabasesPath();
    final String dbPath = path.join(databasesPath, 'birdle.db');

    return openDatabase(
      dbPath,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE users('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'username TEXT UNIQUE NOT NULL, '
          'password_hash TEXT NOT NULL, '
          'terms_accepted INTEGER NOT NULL DEFAULT 0, '
          'is_active INTEGER NOT NULL DEFAULT 1, '
          'created_at TEXT NOT NULL, '
          'updated_at TEXT NOT NULL, '
          'last_login TEXT)',
        );
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN terms_accepted INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE users ADD COLUMN is_active INTEGER NOT NULL DEFAULT 1',
          );
          await db.execute(
            'ALTER TABLE users ADD COLUMN created_at TEXT NOT NULL DEFAULT ""',
          );
          await db.execute(
            'ALTER TABLE users ADD COLUMN updated_at TEXT NOT NULL DEFAULT ""',
          );
          await db.execute('ALTER TABLE users ADD COLUMN last_login TEXT');
        }
      },
    );
  }

  Future<bool> registerUser(
    String username,
    String password, {
    bool termsAccepted = false,
  }) async {
    final Database db = await database;
    final List<Map<String, Object?>> existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return false;
    }

    final String passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());
    final String now = DateTime.now().toIso8601String();

    await db.insert(
      'users',
      <String, Object?>{
        'username': username,
        'password_hash': passwordHash,
        'terms_accepted': termsAccepted ? 1 : 0,
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
        'last_login': null,
      },
    );

    return true;
  }

  Future<bool> loginUser(String username, String password) async {
    final Database db = await database;
    final List<Map<String, Object?>> result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (result.isEmpty) {
      return false;
    }

    final String storedHash = result.first['password_hash'] as String;
    final bool valid = BCrypt.checkpw(password, storedHash);

    if (valid) {
      await db.update(
        'users',
        <String, Object?>{
          'last_login': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'username = ?',
        whereArgs: [username],
      );
    }

    return valid;
  }

  Future<List<Map<String, Object?>>> getUsers() async {
    final Database db = await database;
    return db.query('users', orderBy: 'id DESC');
  }

  Future<bool> deleteUser(String username) async {
    final Database db = await database;
    final int deleted = await db.delete(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return deleted > 0;
  }

  Future<bool> updatePassword(String username, String newPassword) async {
    final Database db = await database;
    final int updated = await db.update(
      'users',
      <String, Object?>{
        'password_hash': BCrypt.hashpw(newPassword, BCrypt.gensalt()),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'username = ?',
      whereArgs: [username],
    );
    return updated > 0;
  }
}