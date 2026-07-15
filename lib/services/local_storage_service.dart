import 'dart:io';

import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  LocalStorageService._();

  static const String _historialFileName = 'historial.txt';

  static Future<File> _getHistorialFile() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String rutaCompleta = '${dir.path}/$_historialFileName';
    final File file = File(rutaCompleta);

    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  /// Agrega una línea al historial en formato: fecha|titulo|canal
  static Future<void> registrarVisualizacion({
    required String titulo,
    required String canal,
  }) async {
    try {
      final File file = await _getHistorialFile();
      final String fecha = DateTime.now().toIso8601String();
      final String linea = '$fecha|$titulo|$canal\n';
      await file.writeAsString(linea, mode: FileMode.append);
    } catch (e) {
      print('Error al escribir historial: $e');
    }
  }

  /// Lee todo el historial del archivo .txt
  static Future<List<Map<String, String>>> leerHistorial() async {
    try {
      final File file = await _getHistorialFile();
      final String contenido = await file.readAsString();

      if (contenido.trim().isEmpty) {
        return [];
      }

      final List<String> lineas = contenido
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .toList();

      final List<Map<String, String>> historial = lineas.map((linea) {
        final partes = linea.split('|');
        return {
          'fecha': partes.isNotEmpty ? partes[0] : '',
          'titulo': partes.length > 1 ? partes[1] : '',
          'canal': partes.length > 2 ? partes[2] : '',
        };
      }).toList();

      return historial.reversed.toList();
    } catch (e) {
      print('Error al leer historial: $e');
      return [];
    }
  }

  static Future<void> limpiarHistorial() async {
    try {
      final File file = await _getHistorialFile();
      await file.writeAsString('');
    } catch (e) {
      print('Error al limpiar historial: $e');
    }
  }
}