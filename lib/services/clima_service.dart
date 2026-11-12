
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/clima.dart';

class ClimaService {
  Future<Clima> obtenerClima(String ciudad) async {
    final nombre = ciudad.trim();

    if (nombre.isEmpty) {
      throw Exception('Escribe el nombre de una ciudad.');
    }

    final urlGeocoding = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': nombre,
        'count': '1',
        'language': 'es',
        'format': 'json',
      },
    );

    final respuestaCiudad = await http.get(urlGeocoding);

    if (respuestaCiudad.statusCode != 200) {
      throw Exception('No se pudo buscar la ciudad.');
    }

    final datosCiudad = jsonDecode(respuestaCiudad.body);
    final resultados = datosCiudad['results'];

    if (resultados == null || resultados.isEmpty) {
      throw Exception('No se encontró la ciudad.');
    }

    final resultado = resultados[0];

    final double latitud = (resultado['latitude'] as num).toDouble();
    final double longitud = (resultado['longitude'] as num).toDouble();

    final String nombreEncontrado = resultado['name'];

    final urlClima = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': latitud.toString(),
        'longitude': longitud.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min',
        'forecast_days': '5',
        'timezone': 'auto',
        'wind_speed_unit': 'kmh',
      },
    );

    final respuestaClima = await http.get(urlClima);

    if (respuestaClima.statusCode != 200) {
      throw Exception('No se pudo obtener el clima.');
    }

    final datosClima = jsonDecode(respuestaClima.body);

    return Clima.fromJson(datosClima, nombreEncontrado);
  }
}
