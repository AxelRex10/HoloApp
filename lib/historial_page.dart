import 'package:flutter/material.dart';
import 'services/local_storage_service.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  late Future<List<Map<String, String>>> _historialFuture;

  @override
  void initState() {
    super.initState();
    _historialFuture = LocalStorageService.leerHistorial();
  }

  void _recargar() {
    setState(() {
      _historialFuture = LocalStorageService.leerHistorial();
    });
  }

  String _formatFecha(String iso) {
    try {
      final DateTime date = DateTime.parse(iso).toLocal();
      final String h = date.hour.toString().padLeft(2, '0');
      final String m = date.minute.toString().padLeft(2, '0');
      return '${date.day}/${date.month}/${date.year} $h:$m';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpiar historial',
            onPressed: () async {
              await LocalStorageService.limpiarHistorial();
              _recargar();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _historialFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final List<Map<String, String>> historial = snapshot.data ?? [];

          if (historial.isEmpty) {
            return const Center(
              child: Text('Aún no has visto ningún video'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _recargar(),
            child: ListView.builder(
              itemCount: historial.length,
              itemBuilder: (context, index) {
                final entry = historial[index];
                return ListTile(
                  leading: const Icon(Icons.play_circle_outline),
                  title: Text(
                    entry['titulo'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${entry['canal'] ?? ''} • ${_formatFecha(entry['fecha'] ?? '')}',
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}