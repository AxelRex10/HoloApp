import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/holodex_service.dart';
import 'services/local_storage_service.dart';

class ChannelDetailPage extends StatefulWidget {
  final Map<String, dynamic> channel;

  const ChannelDetailPage({super.key, required this.channel});

  @override
  State<ChannelDetailPage> createState() => _ChannelDetailPageState();
}

class _ChannelDetailPageState extends State<ChannelDetailPage> {
  List<Map<String, dynamic>> _videos = [];
  bool _cargando = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _cargarVideos();
  }

  Future<void> _cargarVideos() async {
    setState(() {
      _cargando = true;
      _error = '';
    });

    final String channelId = widget.channel['id'] as String? ?? '';
    final videos = await HolodexService.getChannelVideos(channelId, limit: 30);

    setState(() {
      _cargando = false;
      if (videos.isEmpty) {
        _error = 'No se encontraron videos';
      } else {
        _videos = videos;
      }
    });
  }

  Future<void> _abrirYoutube(
    String videoId, {
    required String titulo,
    required String canal,
  }) async {
    await LocalStorageService.registrarVisualizacion(
      titulo: titulo,
      canal: canal,
    );

    final Uri uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String nombre =
        widget.channel['english_name'] as String? ??
        widget.channel['name'] as String? ??
        '';
    final String? foto = widget.channel['photo'] as String?;
    final int subs = widget.channel['subscriber_count'] as int? ?? 0;
    final String org = widget.channel['org'] as String? ?? '';
    final String group = widget.channel['group'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(nombre),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                foto != null
                    ? CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(foto),
                      )
                    : const CircleAvatar(
                        radius: 36,
                        child: Icon(Icons.person, size: 36),
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.isNotEmpty ? '$org • $group' : org,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$subs suscriptores',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Videos recientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _cargarVideos,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _videos.length,
                        itemBuilder: (context, index) {
                          final video = _videos[index];
                          final String videoId =
                              video['id'] as String? ?? '';
                          final String titulo =
                              video['title'] as String? ?? 'Sin título';
                          final String fecha =
                              _formatDate(video['available_at'] as String?);
                          final String thumbnail =
                              'https://img.youtube.com/vi/$videoId/mqdefault.jpg';

                          return InkWell(
                            onTap: videoId.isNotEmpty
                                ? () => _abrirYoutube(
                                      videoId,
                                      titulo: titulo,
                                      canal: nombre,
                                    )
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          thumbnail,
                                          width: 120,
                                          height: 68,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            width: 120,
                                            height: 68,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.video_library,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned.fill(
                                        child: Center(
                                          child: Icon(
                                            Icons.play_circle_fill,
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            size: 32,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          titulo,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          fecha,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}