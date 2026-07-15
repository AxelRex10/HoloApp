import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'hololive_page.dart';
import 'historial_page.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  double sliderValue = 0;
  double sliderTamano = 20;
  bool switchFuente = false;
  String radioSeleccionado = 'opcion1';
  List<String> imagenes = [
    'resources/emuw.png',
    'resources/nene.png',
    'resources/rui.png',
    'resources/tsukasa.png',
  ];

  @override
  Widget build(BuildContext context) {
    int indiceImagen = sliderValue.toInt();

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bienvenido',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40),
              Image.asset(imagenes[indiceImagen], width: 300, height: 300),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Slider(
                  value: sliderValue,
                  min: 0,
                  max: 3,
                  divisions: 3,
                  label: '${indiceImagen + 1}',
                  onChanged: (value) {
                    setState(() {
                      sliderValue = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Slider de tamaño',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Este texto cambia de tamaño',
                style: TextStyle(fontSize: sliderTamano),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Slider(
                  value: sliderTamano,
                  min: 10,
                  max: 40,
                  onChanged: (value) {
                    setState(() {
                      sliderTamano = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Switch de fuente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cambiar fuente',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: switchFuente
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                  SizedBox(width: 16),
                  Switch(
                    value: switchFuente,
                    onChanged: (value) {
                      setState(() {
                        switchFuente = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Tres tipos de botones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(onPressed: () {}, child: Text('Presionar 1')),
                  SizedBox(width: 16),
                  TextButton(onPressed: () {}, child: Text('Presionar 2')),
                  SizedBox(width: 16),
                  OutlinedButton(onPressed: () {}, child: Text('Presionar 3')),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Radio buttons',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Radio<String>(
                    value: 'opcion1',
                    groupValue: radioSeleccionado,
                    onChanged: (value) {
                      setState(() {
                        radioSeleccionado = value ?? 'opcion1';
                      });
                    },
                  ),
                  Text('Opción 1'),
                  SizedBox(width: 20),
                  Radio<String>(
                    value: 'opcion2',
                    groupValue: radioSeleccionado,
                    onChanged: (value) {
                      setState(() {
                        radioSeleccionado = value ?? 'opcion1';
                      });
                    },
                  ),
                  Text('Opción 2'),
                  SizedBox(width: 20),
                  Radio<String>(
                    value: 'opcion3',
                    groupValue: radioSeleccionado,
                    onChanged: (value) {
                      setState(() {
                        radioSeleccionado = value ?? 'opcion1';
                      });
                    },
                  ),
                  Text('Opción 3'),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Seleccionaste: $radioSeleccionado',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cerrar sesión'),
              ),
              SizedBox(height: 40),
              const HololiveButton(),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistorialPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Ver historial'),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class HololiveButton extends StatefulWidget {
  const HololiveButton({super.key});

  @override
  State<HololiveButton> createState() => _HololiveButtonState();
}

class _HololiveButtonState extends State<HololiveButton>
    with SingleTickerProviderStateMixin {
  static const Color _vividCyanBlue = Color(0xFF0693E3);

  late AnimationController _controller;
  late Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _sweep = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverEnter(PointerEnterEvent event) {
    _controller.forward();
  }

  void _onHoverExit(PointerExitEvent event) {
    _controller.reverse();
  }

  void _onTap() {
    _navegar();
  }

  void _navegar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HololivePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedBuilder(
          animation: _sweep,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Fondo base (celeste) con contenido blanco
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: const BoxDecoration(color: _vividCyanBlue),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_fill,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ver Hololive',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            shadows: const [
                              Shadow(
                                color: Color(0x55000000),
                                blurRadius: 6,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Overlay blanco que se desliza
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _sweep.value,
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ),
                  // Contenido que se revela (celeste sobre blanco)
                  Positioned.fill(
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: _sweep.value == 0 ? 0.001 : _sweep.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          color: Colors.transparent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_fill,
                                size: 20,
                                color: _vividCyanBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Ver Hololive',
                                style: TextStyle(
                                  color: _vividCyanBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0x330693E3),
                                      blurRadius: 8,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
