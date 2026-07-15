import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'channel_detail_page.dart';
import 'services/holodex_service.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'utils/talent_utils.dart';

class HololivePage extends StatefulWidget {
  const HololivePage({super.key});

  @override
  State<HololivePage> createState() => _HololivePageState();
}

class _HololivePageState extends State<HololivePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _talentos = [];
  List<Map<String, dynamic>> _talentosFiltrado = [];
  List<Map<String, dynamic>> _live = [];
  List<Map<String, dynamic>> _upcoming = [];

  bool _cargando = true;
  String _error = '';
  final TextEditingController _buscador = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _cargarTodo();
    _buscador.addListener(_filtrar);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _cargarTodo() async {
    setState(() {
      _cargando = true;
      _error = '';
    });

    try {
      final results = await Future.wait([
        HolodexService.getHololiveChannels(),
        HolodexService.getLiveStreams(),
        HolodexService.getUpcomingStreams(),
      ]);

      final List<Map<String, dynamic>> talentos = results[0];
      final List<Map<String, dynamic>> liveStreams = results[1];
      final List<Map<String, dynamic>> upcomingStreams = results[2];

      try {
        for (int i = 0; i < liveStreams.length && i < 2; i++) {
          final video = liveStreams[i];
          final String videoId = video['id'] as String? ?? '';
          final String talentName =
              video['channel']?['english_name'] as String? ??
              video['channel']?['name'] as String? ??
              'Hololive';

          if (videoId.isNotEmpty) {
            await NotificationService.showLiveNotification(
              id: i,
              talentName: talentName,
              videoId: videoId,
            );
          }
        }
      } catch (e) {
        debugPrint('No se pudieron mostrar notificaciones: $e');
      }

      if (!mounted) return;

      setState(() {
        _talentos = talentos;
        _live = liveStreams;
        _upcoming = upcomingStreams;
        _talentosFiltrado = _talentos;

        if (_talentos.isEmpty) {
          _error = 'No se pudieron cargar los talentos';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar los talentos: $e';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _cargando = false;
      });
    }
  }

  void _filtrar() {
    final query = _buscador.text.toLowerCase();
    setState(() {
      _talentosFiltrado = _talentos.where((c) {
        final nombre = (c['english_name'] ?? c['name'] ?? '').toLowerCase();
        return nombre.contains(query);
      }).toList();
    });
  }

  // Usa compute() para calcular el Top 10 en un isolate aparte,
  // sin bloquear la UI mientras se ordena la lista.
  Future<void> _mostrarTop10() async {
    if (_talentos.isEmpty) return;

    final List<Map<String, dynamic>> top10 =
        await compute(calcularTopTalentos, _talentos);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          builder: (context, scrollController) {
            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Top 10 por suscriptores',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: top10.length,
                    itemBuilder: (context, index) {
                      final c = top10[index];
                      final String nombre =
                          c['english_name'] as String? ??
                          c['name'] as String? ??
                          '';
                      final int subs = c['subscriber_count'] as int? ?? 0;
                      final String? foto = c['photo'] as String?;

                      return ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(nombre),
                        subtitle: Text('$subs suscriptores'),
                        trailing: foto != null
                            ? CircleAvatar(backgroundImage: NetworkImage(foto))
                            : null,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _abrirYoutube(
    String videoId, {
    String titulo = '',
    String canal = '',
  }) async {
    if (titulo.isNotEmpty) {
      await LocalStorageService.registrarVisualizacion(
        titulo: titulo,
        canal: canal,
      );
    }

    final Uri uri = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildTalentosList() {
    if (_talentosFiltrado.isEmpty) {
      return const Center(child: Text('No se encontraron talentos'));
    }

    return ListView.builder(
      itemCount: _talentosFiltrado.length,
      itemBuilder: (context, index) {
        final channel = _talentosFiltrado[index];
        final String nombre =
            channel['english_name'] as String? ??
            channel['name'] as String? ??
            '';
        final String? foto = channel['photo'] as String?;
        final int subs = channel['subscriber_count'] as int? ?? 0;
        final String group = channel['group'] as String? ?? '';

        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChannelDetailPage(channel: channel),
              ),
            );
          },
          leading: foto != null
              ? CircleAvatar(backgroundImage: NetworkImage(foto))
              : const CircleAvatar(child: Icon(Icons.person)),
          title: Text(nombre),
          subtitle: Text(
            group.isNotEmpty ? '$group • $subs subs' : '$subs subs',
          ),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }

  Widget _buildLiveList() {
    if (_live.isEmpty) {
      return const Center(child: Text('No hay streams en vivo ahora mismo'));
    }

    return ListView.builder(
      itemCount: _live.length,
      itemBuilder: (context, index) {
        final video = _live[index];
        final String videoId = video['id'] as String? ?? '';
        final String titulo = video['title'] as String? ?? 'Sin título';
        final String? channelName =
            video['channel']?['english_name'] as String? ??
            video['channel']?['name'] as String?;
        final String thumbnail =
            'https://img.youtube.com/vi/$videoId/mqdefault.jpg';

        return InkWell(
          onTap: videoId.isNotEmpty
              ? () => _abrirYoutube(
                    videoId,
                    titulo: titulo,
                    canal: channelName ?? '',
                  )
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                        errorBuilder: (_, __, ___) => Container(
                          width: 120,
                          height: 68,
                          color: Colors.grey[300],
                          child: const Icon(Icons.live_tv, color: Colors.red),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.white.withOpacity(0.8),
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        channelName ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingList() {
    if (_upcoming.isEmpty) {
      return const Center(child: Text('No hay directos programados'));
    }

    return ListView.builder(
      itemCount: _upcoming.length,
      itemBuilder: (context, index) {
        return _UpcomingStreamTile(video: _upcoming[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hololive'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Top 10',
            onPressed: _mostrarTop10,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Talentos (${_talentosFiltrado.length})'),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('En vivo'),
                  if (_live.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_live.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: 'Próximos (${_upcoming.length})'),
          ],
        ),
      ),
      body: _cargando
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Cargando talentos...'),
                ],
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _cargarTodo,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: TextField(
                        controller: _buscador,
                        decoration: InputDecoration(
                          hintText: 'Buscar talent...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: _buscador.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _buscador.clear,
                                )
                              : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTalentosList(),
                          _buildLiveList(),
                          _buildUpcomingList(),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargarTodo,
        tooltip: 'Actualizar',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// Widget con Timer propio para mostrar cuenta regresiva de un stream
// que todavía no empieza (waiting room).
class _UpcomingStreamTile extends StatefulWidget {
  final Map<String, dynamic> video;

  const _UpcomingStreamTile({required this.video});

  @override
  State<_UpcomingStreamTile> createState() => _UpcomingStreamTileState();
}

class _UpcomingStreamTileState extends State<_UpcomingStreamTile> {
  Timer? _timer;
  Duration _restante = Duration.zero;

  @override
  void initState() {
    super.initState();
    _actualizarRestante();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _actualizarRestante();
    });
  }

  void _actualizarRestante() {
    final String? scheduled = widget.video['start_scheduled'] as String?;
    if (scheduled == null) return;

    try {
      final DateTime inicio = DateTime.parse(scheduled).toLocal();
      final Duration diff = inicio.difference(DateTime.now());
      if (mounted) {
        setState(() {
          _restante = diff.isNegative ? Duration.zero : diff;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    final int s = d.inSeconds.remainder(60);

    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final String titulo = video['title'] as String? ?? 'Sin título';
    final String? channelName =
        video['channel']?['english_name'] as String? ??
        video['channel']?['name'] as String?;
    final String videoId = video['id'] as String? ?? '';
    final String thumbnail =
        'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
    final bool yaEmpezo = _restante == Duration.zero;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              thumbnail,
              width: 120,
              height: 68,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 120,
                height: 68,
                color: Colors.grey[300],
                child: const Icon(Icons.schedule),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  channelName ?? '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: yaEmpezo ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    yaEmpezo
                        ? 'Debería estar en vivo'
                        : 'Directo empieza en ${_formatDuration(_restante)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}