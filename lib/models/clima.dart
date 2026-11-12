
class Clima {
  final String ciudad;
  final double temperatura;
  final double sensacionTermica;
  final int humedad;
  final double viento;
  final int codigoClima;
  final double temperaturaMaxima;
  final double temperaturaMinima;
  final List<Pronostico> pronosticos;

  Clima({
    required this.ciudad,
    required this.temperatura,
    required this.sensacionTermica,
    required this.humedad,
    required this.viento,
    required this.codigoClima,
    required this.temperaturaMaxima,
    required this.temperaturaMinima,
    required this.pronosticos,
  });

  factory Clima.fromJson(
    Map<String, dynamic> json,
    String nombreCiudad,
  ) {
    final actual = json['current'];
    final diario = json['daily'];

    List<Pronostico> lista = [];

    for (int i = 0; i < diario['time'].length; i++) {
      lista.add(
        Pronostico(
          fecha: diario['time'][i],
          codigo: diario['weather_code'][i],
          maxima: (diario['temperature_2m_max'][i] as num).toDouble(),
          minima: (diario['temperature_2m_min'][i] as num).toDouble(),
        ),
      );
    }

    return Clima(
      ciudad: nombreCiudad,
      temperatura: (actual['temperature_2m'] as num).toDouble(),
      sensacionTermica:
          (actual['apparent_temperature'] as num).toDouble(),
      humedad: actual['relative_humidity_2m'],
      viento: (actual['wind_speed_10m'] as num).toDouble(),
      codigoClima: actual['weather_code'],
      temperaturaMaxima:
          (diario['temperature_2m_max'][0] as num).toDouble(),
      temperaturaMinima:
          (diario['temperature_2m_min'][0] as num).toDouble(),
      pronosticos: lista,
    );
  }
}

class Pronostico {
  final String fecha;
  final int codigo;
  final double maxima;
  final double minima;

  Pronostico({
    required this.fecha,
    required this.codigo,
    required this.maxima,
    required this.minima,
  });
}
