
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/inicio_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ClimaApp());
}

class ClimaApp extends StatefulWidget {
  const ClimaApp({super.key});

  @override
  State<ClimaApp> createState() => _ClimaAppState();
}

class _ClimaAppState extends State<ClimaApp> {
  bool modoOscuro = true;
  bool fahrenheit = false;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarPreferencias();
  }

  Future<void> cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      modoOscuro = prefs.getBool('modoOscuro') ?? true;
      fahrenheit = prefs.getBool('fahrenheit') ?? false;
      cargando = false;
    });
  }

  Future<void> cambiarTema(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modoOscuro', valor);

    setState(() {
      modoOscuro = valor;
    });
  }

  Future<void> cambiarTemperatura(bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fahrenheit', valor);

    setState(() {
      fahrenheit = valor;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClimaApp',
      themeMode: modoOscuro ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101827),
        useMaterial3: true,
      ),
      home: InicioScreen(
        modoOscuro: modoOscuro,
        fahrenheit: fahrenheit,
        onCambiarTema: cambiarTema,
        onCambiarTemperatura: cambiarTemperatura,
      ),
    );
  }
}
