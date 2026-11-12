
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/clima.dart';
import '../services/clima_service.dart';

class InicioScreen extends StatefulWidget {
  final bool modoOscuro;
  final bool fahrenheit;
  final ValueChanged<bool> onCambiarTema;
  final ValueChanged<bool> onCambiarTemperatura;

  const InicioScreen({
    super.key,
    required this.modoOscuro,
    required this.fahrenheit,
    required this.onCambiarTema,
    required this.onCambiarTemperatura,
  });

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final ClimaService servicio = ClimaService();
  final TextEditingController controlador = TextEditingController();

  Clima? clima;
  bool cargando = false;
  String? error;
  int paginaActual = 0;
  List<String> favoritos = [];

  @override
  void initState() {
    super.initState();
    cargarFavoritos();
    buscarClima('Tecate');
  }

  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  Future<void> cargarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      favoritos = prefs.getStringList('favoritos') ?? [];
    });
  }

  Future<void> guardarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoritos', favoritos);
  }

  Future<void> cambiarFavorito(String ciudad) async {
    final existe = favoritos.any(
      (elemento) => elemento.toLowerCase() == ciudad.toLowerCase(),
    );

    setState(() {
      if (existe) {
        favoritos.removeWhere(
          (elemento) => elemento.toLowerCase() == ciudad.toLowerCase(),
        );
      } else {
        favoritos.add(ciudad);
      }
    });

    await guardarFavoritos();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existe
              ? '$ciudad se eliminó de favoritos'
              : '$ciudad se agregó a favoritos',
        ),
      ),
    );
  }

  Future<void> buscarClima(String ciudad) async {
    if (ciudad.trim().isEmpty) return;

    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final resultado = await servicio.obtenerClima(ciudad);

      if (!mounted) return;

      setState(() {
        clima = resultado;
        controlador.text = resultado.ciudad;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
        cargando = false;
      });
    }
  }

  double convertirTemperatura(double celsius) {
    if (widget.fahrenheit) {
      return (celsius * 9 / 5) + 32;
    }
    return celsius;
  }

  String mostrarTemperatura(double valor) {
    return '${convertirTemperatura(valor).round()}°${widget.fahrenheit ? 'F' : 'C'}';
  }

  String descripcionClima(int codigo) {
    if (codigo == 0) return 'Despejado';
    if (codigo <= 3) return 'Parcialmente nublado';
    if (codigo == 45 || codigo == 48) return 'Niebla';
    if (codigo >= 51 && codigo <= 57) return 'Llovizna';
    if (codigo >= 61 && codigo <= 67) return 'Lluvia';
    if (codigo >= 71 && codigo <= 77) return 'Nieve';
    if (codigo >= 80 && codigo <= 82) return 'Chubascos';
    if (codigo >= 85 && codigo <= 86) return 'Nevadas';
    if (codigo >= 95) return 'Tormenta';
    return 'Condiciones variables';
  }

  IconData iconoClima(int codigo) {
    if (codigo == 0) return Icons.wb_sunny_rounded;
    if (codigo <= 3) return Icons.cloud_rounded;
    if (codigo == 45 || codigo == 48) return Icons.foggy;
    if (codigo >= 51 && codigo <= 67) return Icons.grain_rounded;
    if (codigo >= 71 && codigo <= 86) return Icons.ac_unit_rounded;
    if (codigo >= 95) return Icons.thunderstorm_rounded;
    return Icons.cloud_queue_rounded;
  }

  String nombreDia(String fecha) {
    final date = DateTime.parse(fecha);
    const dias = [
      'Lunes', 'Martes', 'Miércoles', 'Jueves',
      'Viernes', 'Sábado', 'Domingo'
    ];
    return dias[date.weekday - 1];
  }

  bool esFavorito(String ciudad) {
    return favoritos.any(
      (elemento) => elemento.toLowerCase() == ciudad.toLowerCase(),
    );
  }

  Widget tarjetaDetalle(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Column(
            children: [
              Icon(icono, size: 27, color: Colors.lightBlueAccent),
              const SizedBox(height: 10),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pantallaInicio() {
    final datos = clima;

    return RefreshIndicator(
      onRefresh: () async {
        if (datos != null) {
          await buscarClima(datos.ciudad);
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Clima actual',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'Consulta las condiciones del tiempo',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),

          TextField(
            controller: controlador,
            textInputAction: TextInputAction.search,
            onSubmitted: buscarClima,
            decoration: InputDecoration(
              hintText: 'Escribe una ciudad...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => buscarClima(controlador.text),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          const SizedBox(height: 22),

          if (cargando)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),

          if (error != null && !cargando)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 10),
                    Text(error!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: () => buscarClima(controlador.text),
                      child: const Text('Intentar nuevamente'),
                    ),
                  ],
                ),
              ),
            ),

          if (datos != null && !cargando && error == null) ...[
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            datos.ciudad,
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => cambiarFavorito(datos.ciudad),
                          icon: Icon(
                            esFavorito(datos.ciudad)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: esFavorito(datos.ciudad)
                                ? Colors.red
                                : null,
                          ),
                          tooltip: 'Agregar o quitar favorito',
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Icon(
                      iconoClima(datos.codigoClima),
                      size: 75,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      mostrarTemperatura(datos.temperatura),
                      style: const TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      descripcionClima(datos.codigoClima),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Máx. ${mostrarTemperatura(datos.temperaturaMaxima)}'
                      '   Mín. ${mostrarTemperatura(datos.temperaturaMinima)}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Detalles del clima',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                tarjetaDetalle(
                  Icons.thermostat,
                  'Sensación',
                  mostrarTemperatura(datos.sensacionTermica),
                ),
                tarjetaDetalle(
                  Icons.water_drop_outlined,
                  'Humedad',
                  '${datos.humedad}%',
                ),
                tarjetaDetalle(
                  Icons.air,
                  'Viento',
                  '${datos.viento.round()} km/h',
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Pronóstico de 5 días',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...datos.pronosticos.map((dia) {
              return Card(
                elevation: 0,
                child: ListTile(
                  leading: Icon(
                    iconoClima(dia.codigo),
                    color: Colors.orange,
                    size: 30,
                  ),
                  title: Text(nombreDia(dia.fecha)),
                  subtitle: Text(descripcionClima(dia.codigo)),
                  trailing: Text(
                    '${mostrarTemperatura(dia.maxima)} / '
                    '${mostrarTemperatura(dia.minima)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget pantallaFavoritos() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Mis ciudades favoritas',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Guarda las ciudades que quieras consultar rápidamente.'),
        const SizedBox(height: 20),

        if (favoritos.isEmpty)
          const Padding(
            padding: EdgeInsets.all(35),
            child: Column(
              children: [
                Icon(Icons.favorite_border, size: 65),
                SizedBox(height: 15),
                Text(
                  'Todavía no tienes ciudades favoritas.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Busca una ciudad en Inicio y presiona el corazón para guardarla.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

        ...favoritos.map((ciudad) {
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.location_city),
              ),
              title: Text(
                ciudad,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Consultar clima'),
              onTap: () async {
                await buscarClima(ciudad);
                if (!mounted) return;

                if (error == null) {
                  setState(() {
                    paginaActual = 0;
                  });
                }
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Eliminar favorito',
                onPressed: () => cambiarFavorito(ciudad),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget pantallaConfiguracion() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Configuración',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text('Personaliza tu experiencia en ClimaApp.'),
        const SizedBox(height: 25),

        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Modo oscuro'),
            subtitle: Text(
              widget.modoOscuro ? 'Activado' : 'Desactivado',
            ),
            value: widget.modoOscuro,
            onChanged: widget.onCambiarTema,
          ),
        ),

        const SizedBox(height: 12),

        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.thermostat),
            title: const Text('Temperatura en Fahrenheit'),
            subtitle: Text(
              widget.fahrenheit
                  ? 'Unidad actual: Fahrenheit (°F)'
                  : 'Unidad actual: Celsius (°C)',
            ),
            value: widget.fahrenheit,
            onChanged: widget.onCambiarTemperatura,
          ),
        ),

        const SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Actualizar clima'),
            subtitle: const Text('Consultar nuevamente los datos'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (clima != null) {
                buscarClima(clima!.ciudad);
                setState(() {
                  paginaActual = 0;
                });
              } else {
                setState(() {
                  paginaActual = 0;
                });
              }
            },
          ),
        ),

        const SizedBox(height: 30),

        const Center(
          child: Column(
            children: [
              Icon(Icons.cloud, size: 45, color: Colors.lightBlue),
              SizedBox(height: 8),
              Text(
                'ClimaApp',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Consulta el clima de tus ciudades favoritas'),
              SizedBox(height: 5),
              Text('Datos meteorológicos de Open-Meteo'),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      pantallaInicio(),
      pantallaFavoritos(),
      pantallaConfiguracion(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ClimaApp',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Actualizar clima',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (clima != null) {
                buscarClima(clima!.ciudad);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: paginaActual,
          children: pantallas,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: paginaActual,
        onDestinationSelected: (indice) {
          setState(() {
            paginaActual = indice;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
