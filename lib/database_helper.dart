import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // Importar dart:io para acceder a Platform

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database!;
    if (kIsWeb) {
      // No usar sqflite en la web, retornar null
      return null;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_database.db');
    print('Database path: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE rating(
        id_rate INTEGER PRIMARY KEY AUTOINCREMENT,
        rating INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        descrip TEXT,
        id_user INTEGER,
        FOREIGN KEY(id_user) REFERENCES users(id)
      )
    ''');
  }

  Future<void> insertUser(String email) async {
    if (kIsWeb) {
      // Usa shared_preferences para la web
      final prefs = await SharedPreferences.getInstance();
      List<String> users = prefs.getStringList('users') ?? [];
      users.add(email);
      await prefs.setStringList('users', users);
      print('User inserted: $email');
    } else {
      final db = await database;
      await db!.insert(
        'users',
        {'email': email},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('User inserted: $email');
    }
  }

  Future<int?> getUserIdByEmail(String email) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      List<String> users = prefs.getStringList('users') ?? [];
      int index = users.indexOf(email);
      if (index != -1) {
        print('User found: $index');
        return index;
      } else {
        print('User not found');
        throw Exception('Usuario no encontrado');
      }
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db!.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      if (maps.isNotEmpty) {
        print('User found: ${maps.first['id']}');
        return maps.first['id'];
      } else {
        print('User not found');
        throw Exception('Usuario no encontrado');
      }
    }
  }

  Future<void> insertRating(
      int rating, String fecha, String descrip, int idUser) async {
    if (kIsWeb) {
      // Manejar almacenamiento de ratings en la web
      // Puedes usar shared_preferences o cualquier otro almacenamiento web adecuado
    } else {
      final db = await database;
      await db!.insert(
        'rating',
        {
          'rating': rating,
          'fecha': fecha,
          'descrip': descrip,
          'id_user': idUser
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Rating inserted: $rating');
    }
  }
}
