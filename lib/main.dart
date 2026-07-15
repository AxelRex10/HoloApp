import 'package:flutter/material.dart';

import 'database/app_database.dart';
import 'inicio.dart';
import 'registro.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginPage());
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usuarioController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool aceptoTerminos = false;
  String mensaje = '';

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    final String usuario = usuarioController.text.trim();
    final String password = passwordController.text;

    if (usuario.isEmpty || password.isEmpty) {
      setState(() {
        mensaje = 'Nombre y contraseña son requeridos';
      });
      return;
    }

    if (!aceptoTerminos) {
      setState(() {
        mensaje = 'Debes leer los términos y condiciones';
      });
      return;
    }

    final bool valido = await AppDatabase.instance.loginUser(usuario, password);

    if (!mounted) {
      return;
    }

    if (valido) {
      setState(() {
        mensaje = '';
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Inicio()),
      );
    } else {
      setState(() {
        mensaje = 'Usuario o contraseña incorrectos';
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
              'Login',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: aceptoTerminos,
                  onChanged: (value) {
                    setState(() {
                      aceptoTerminos = value ?? false;
                    });
                  },
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TerminosPage()),
                    );
                  },
                  child: Text(
                    'Términos y condiciones',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: iniciarSesion,
              child: Text('Login'),
            ),
            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistroPage()),
                ).then((_) {
                  if (!mounted) {
                    return;
                  }

                  setState(() {
                    mensaje = '';
                  });
                });
              },
              child: Text('Registro'),
            ),

            SizedBox(height: 16),

            Text(mensaje),
          ],
        ),
      ),
    );
  }
}

class TerminosPage extends StatelessWidget {
  const TerminosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Términos y condiciones',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            Container(
              width: 800,
              height: 400,
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin semper sodales leo at lobortis. Donec a velit pharetra, semper velit sed, venenatis est. Curabitur egestas mauris iaculis justo elementum, id congue dolor laoreet. Donec id pellentesque augue. Nullam rutrum a orci quis pellentesque. Integer ut tempor purus, non tempor purus. Pellentesque elit purus, tristique et imperdiet quis, congue eget eros. Morbi et augue ultricies nulla cursus feugiat ut ac tortor. Nulla viverra nisl ex, quis vestibulum nunc ornare vitae. Quisque mauris diam, euismod congue lobortis a, placerat id erat. Donec et metus vitae ex lacinia cursus. Donec nisi nunc, luctus porttitor tristique a, malesuada quis turpis. Donec tristique non tortor at dictum.',
                    ),
                    Text(
                      'Morbi dictum venenatis mauris. Vivamus ac nibh in nisi accumsan commodo. Fusce accumsan eros at pulvinar lacinia. Maecenas at ante diam. Aliquam porta nibh ullamcorper, vulputate est et, tristique orci. Integer maximus tellus in orci venenatis, ut facilisis augue semper. Sed dictum nisi a erat viverra aliquet. Praesent a libero purus.',
                    ),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin semper sodales leo at lobortis. Donec a velit pharetra, semper velit sed, venenatis est. Curabitur egestas mauris iaculis justo elementum, id congue dolor laoreet. Donec id pellentesque augue. Nullam rutrum a orci quis pellentesque. Integer ut tempor purus, non tempor purus. Pellentesque elit purus, tristique et imperdiet quis, congue eget eros. Morbi et augue ultricies nulla cursus feugiat ut ac tortor. Nulla viverra nisl ex, quis vestibulum nunc ornare vitae. Quisque mauris diam, euismod congue lobortis a, placerat id erat. Donec et metus vitae ex lacinia cursus. Donec nisi nunc, luctus porttitor tristique a, malesuada quis turpis. Donec tristique non tortor at dictum.',
                    ),
                    Text(
                      'Morbi dictum venenatis mauris. Vivamus ac nibh in nisi accumsan commodo. Fusce accumsan eros at pulvinar lacinia. Maecenas at ante diam. Aliquam porta nibh ullamcorper, vulputate est et, tristique orci. Integer maximus tellus in orci venenatis, ut facilisis augue semper. Sed dictum nisi a erat viverra aliquet. Praesent a libero purus.',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }
}
