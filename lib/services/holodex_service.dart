import 'dart:convert';
import 'package:http/http.dart' as http;

class HolodexService {
  static const String _apiKey = '71ce9712-2b79-4cb6-8c13-b7ece1c9051c';
  static const String _baseUrl = 'https://holodex.net/api/v2';

  static Map<String, String> get _headers => {
    'X-APIKEY': _apiKey,
    'Content-Type': 'application/json',
  };

  // Obtiene TODOS los canales de Hololive usando paginación
  static Future<List<Map<String, dynamic>>> getHololiveChannels() async {
    final List<Map<String, dynamic>> todos = [];
    int offset = 0;
    const int limite = 50;

    while (true) {
      try {
        final Uri url = Uri.parse(
          '$_baseUrl/channels?org=Hololive&limit=$limite&offset=$offset&type=vtuber',
        );
        final http.Response response = await http.get(url, headers: _headers);

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
          final pagina = data.cast<Map<String, dynamic>>();
          todos.addAll(pagina);

          if (pagina.length < limite) {
            break;
          }
          offset += limite;
        } else {
          print('Error HTTP canales: ${response.statusCode}');
          break;
        }
      } catch (e) {
        print('Error paginación: $e');
        break;
      }
    }

    return todos;
  }

  // Videos pasados de un canal
  static Future<List<Map<String, dynamic>>> getChannelVideos(
    String channelId, {
    int limit = 20,
  }) async {
    try {
      final Uri url = Uri.parse(
        '$_baseUrl/videos?channel_id=$channelId&type=stream&status=past&limit=$limit&sort=available_at&order=desc',
      );
      final http.Response response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      }
      print('Error videos: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  // Streams en vivo de Hololive
  static Future<List<Map<String, dynamic>>> getLiveStreams() async {
    try {
      final Uri url = Uri.parse(
        '$_baseUrl/live?org=Hololive&status=live&limit=100',
      );
      final http.Response response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final List<Map<String, dynamic>> streams = data
            .cast<Map<String, dynamic>>();

        // Filtro extra por seguridad, por si la API devuelve algo mixto
        return streams.where((v) => v['status'] == 'live').toList();
      }
      print('Error live: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  // Streams programados que aún no empiezan (waiting room)
  static Future<List<Map<String, dynamic>>> getUpcomingStreams() async {
    try {
      final Uri url = Uri.parse(
        '$_baseUrl/live?org=Hololive&status=upcoming&limit=50',
      );
      final http.Response response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.cast<Map<String, dynamic>>();
      }
      print('Error upcoming: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
