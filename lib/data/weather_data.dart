class WeatherData {
  /// Time of data calculation, in UTC.
  final DateTime time;

  /// Average air temperature, in Celsius.
  final double? averageTemperature;

  /// Minimum air temperature, in Celsius.
  final double? minTemperature;

  /// Maximum air temperature, in Celsius.
  final double? maxTemperature;

  /// Atmospheric pressure (on the sea level, if there is no `sea_level` or `grnd_level` data), hPa.
  final int? pressure;

  /// Humidity, in percentage.
  final int? humidity;

  /// Wind speed, in meters per second.
  final double windSpeed;

  /// Wind direction, in meteorological degrees.
  final int? windDirection;

  /// Percentage of clouds.
  final int cloudiness;

  /// Rain volume for the last 3 hours, in millimeters.
  final double rainVolume;

  /// Snow volume for the last 3 hours, in millimeters.
  final double snowVolume;

  const WeatherData({
    required this.time,
    this.averageTemperature,
    this.minTemperature,
    this.maxTemperature,
    this.pressure,
    this.humidity,
    this.windSpeed = 0.0,
    this.windDirection,
    this.cloudiness = 0,
    this.rainVolume = 0.0,
    this.snowVolume = 0.0,
  });
}
