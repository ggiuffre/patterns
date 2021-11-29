import 'dart:convert' show json;
import 'dart:math';

import 'package:http/http.dart' as http;

import '../event.dart';
import '../weather_data.dart';
import 'events.dart';

class TemperatureEventRepository implements EventRepository {
  const TemperatureEventRepository();

  static const weatherApi = _MeteostatApi();

  @override
  Future<String> add(Event event) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Event> get(String id) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Stream<Iterable<Event>> get list => weatherApi
      .history(start: DateTime(2021), end: DateTime(2021, 1, 15))
      .then((weatherEvents) => weatherEvents.map((e) => Event("rain", value: e.rainVolume, start: e.time)))
      .asStream();

  @override
  Stream<Iterable<Event>> sorted({bool descending = false}) =>
      descending ? list.map((events) => events.toList()..sort((a, b) => b.compareTo(a))) : list;
}

class _MeteostatApi {
  const _MeteostatApi();

  static const cityId = "06660";
  static const apiKey = String.fromEnvironment("METEOSTAT_API_KEY");

  Future<Iterable<WeatherData>> history({required DateTime start, DateTime? end}) async {
    end ??= start.add(const Duration(days: 1));
    final startDay = start.toIso8601String().substring(0, 10);
    final endDay = end.toIso8601String().substring(0, 10);
    final url = Uri(
      scheme: "https",
      host: "api.meteostat.net",
      path: "/v2/stations/daily",
      queryParameters: {"station": cityId, "start": startDay, "end": endDay},
    );

    final httpResponse = await http.get(url, headers: {"x-api-key": apiKey});
    print(httpResponse.statusCode);

    if (httpResponse.statusCode != 200) {
      throw "Could not retrieve data from the Meteostat historical weather API: HTTP ${httpResponse.statusCode}.";
    }

    final jsonResponse = json.decode(httpResponse.body);
    final weatherData = jsonResponse["data"] as List<dynamic>;

    List<WeatherData> result = [];
    for (final data in weatherData) {
      final time = parsed(() => DateTime.parse(data["date"] as String)) ??
          (result.isEmpty ? start : result.last.time.add(const Duration(days: 1)));
      final averageTemperature = parsed(() => double.parse(data["tavg"].toString())) ??
          (result.isEmpty
              ? nextDayTemperature(start, 16.0)
              : nextDayTemperature(result.last.time, result.last.averageTemperature ?? 16.0));
      final minTemperature = parsed(() => double.parse(data["tmin"].toString()));
      final maxTemperature = parsed(() => double.parse(data["tmax"].toString()));
      final rainVolume = parsed(() => double.parse(data["prcp"].toString())) ?? 0.0;
      final snowVolume = parsed(() => double.parse(data["snow"].toString())) ?? 0.0;
      result.add(WeatherData(
        time: time,
        averageTemperature: averageTemperature,
        minTemperature: minTemperature,
        maxTemperature: maxTemperature,
        rainVolume: rainVolume,
        snowVolume: snowVolume,
      ));
    }

    return result;
  }
}

class OpenWeatherApi {
  const OpenWeatherApi();

  static const cityId = 2657896;
  static const apiKey = String.fromEnvironment("OPENWEATHER_API_KEY");
  static final url = Uri(
    scheme: "https",
    host: "api.openweathermap.org/data/2.5/weather",
    queryParameters: {"id": cityId, "appId": apiKey, "units": "metric"},
  );

  Future<WeatherData> get current => http.get(url).then((httpResponse) {
        final jsonData = json.decode(httpResponse.body, reviver: (key, value) => value is List ? value[0] : value)
            as Map<String, Object?>;

        if (jsonData.containsKey("cod") && jsonData["cod"] == "200") {
          final measurements = mapOrNull(data: jsonData, key: "main");
          final windData = mapOrNull(data: jsonData, key: "wind");
          final clouds = mapOrNull(data: jsonData, key: "clouds");
          final rain = mapOrNull(data: jsonData, key: "rain");
          final snow = mapOrNull(data: jsonData, key: "snow");

          final time = parsed(() => DateTime.fromMillisecondsSinceEpoch(jsonData["dt"] as int));
          final temperature = parsed(() => measurements?["temp"] as double?);
          final minTemperature = parsed(() => measurements?["temp_min"] as double?);
          final maxTemperature = parsed(() => measurements?["temp_max"] as double?);
          final pressure = parsed(() => measurements?["pressure"] as int?);
          final humidity = parsed(() => measurements?["humidity"] as int?);
          final windSpeed = parsed(() => windData?["speed"] as double?);
          final windDirection = parsed(() => windData?["deg"] as int?);
          final cloudiness = parsed(() => clouds?["all"] as int?);
          final rainVolume = parsed(() => rain?["3h"] as double?);
          final snowVolume = parsed(() => snow?["3h"] as double?);

          return WeatherData(
            time: time ?? DateTime.now(),
            averageTemperature: temperature,
            minTemperature: minTemperature,
            maxTemperature: maxTemperature,
            pressure: pressure,
            humidity: humidity,
            windSpeed: windSpeed ?? 0.0,
            windDirection: windDirection,
            cloudiness: cloudiness ?? 0,
            rainVolume: rainVolume ?? 0.0,
            snowVolume: snowVolume ?? 0.0,
          );
        } else {
          throw "Couldn't load current weather data";
        }
      });
}

Map<String, Object?>? mapOrNull({required Map<String, Object?> data, required String key}) {
  if (data.containsKey(key)) {
    try {
      return data[key] as Map<String, Object?>;
    } catch (error) {
      print("mapOrNull: $error");
      return null;
    }
  } else {
    return null;
  }
}

T? parsed<T>(T Function() callback) {
  try {
    return callback();
  } catch (error) {
    print("parsed: $error");
    return null;
  }
}

double nextDayTemperature(DateTime time, double currentTemperature) =>
    currentTemperature + cos(time.difference(DateTime(time.year, 3, 15)).inDays / 365.0 * 2.0 * pi);
