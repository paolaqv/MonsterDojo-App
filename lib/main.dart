import 'package:flutter/material.dart';
import 'dart:io'; // Importar dart:io para acceder a Platform
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Importar sqflite_common_ffi
import 'inicio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() {
  if (!kIsWeb) {
    // Solo inicializa `sqflite` para plataformas móviles y de escritorio
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Inicio(),
    );
  }
}
