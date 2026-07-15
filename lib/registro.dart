import 'package:flutter/material.dart';

import 'database/app_database.dart';

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String mensaje = '';

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> registrarUsuario() async {
    final String usuario = usuarioController.text.trim();
    final String password = passwordController.text;

    if (usuario.isEmpty || password.isEmpty) {
      setState(() {
        mensaje = 'Nombre y contraseña son requeridos';
      });
      return;
    }

    final bool registrado = await AppDatabase.instance.registerUser(usuario, password);

    if (!mounted) {
      return;
    }

    if (registrado) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        mensaje = 'El usuario ya existe';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              'Registro',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 40),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: usuarioController,
                decoration: InputDecoration(
                  hintText: 'Nombre de usuario',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            SizedBox(height: 16),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            SizedBox(height: 24),

            ElevatedButton(
              onPressed: registrarUsuario,
              child: Text('Registrar'),
            ),

            SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Ya tengo cuenta'),
            ),

            SizedBox(height: 10),

            Text(mensaje),
          ],
        ),
      ),
    );
  }
}