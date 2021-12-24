class SportsInfo {
  final String sport;
  final double? calories;
  final double? duration;

  const SportsInfo({required this.sport, this.calories, this.duration});

  SportsInfo copyWith({String? sport, double? calories, double? duration}) => SportsInfo(
        sport: sport ?? this.sport,
        calories: calories ?? this.calories,
        duration: duration ?? this.duration,
      );
}

enum Sport {
  running,
  cycling,
  muscleWorkout,
  alpineSki,
  crossCountrySki,
  swimming,
  tableTennis,
  other,
}

const sportsInfo = {
  Sport.running: SportsInfo(sport: "running", calories: 900),
  Sport.cycling: SportsInfo(sport: "cycling", calories: 640),
  Sport.muscleWorkout: SportsInfo(sport: "muscle workout", calories: 250),
  Sport.alpineSki: SportsInfo(sport: "alpine skiing", calories: 490),
  Sport.crossCountrySki: SportsInfo(sport: "cross-country skiing", calories: 655),
  Sport.swimming: SportsInfo(sport: "swimming", calories: 570),
  Sport.tableTennis: SportsInfo(sport: "ping pong", calories: 320),
  Sport.other: SportsInfo(sport: "other"),
};

const caloriesBurntPerKilogramPerHourBySport = {
  Sport.running: 12.5,
  Sport.cycling: 8.0,
  Sport.muscleWorkout: 3.0,
  Sport.alpineSki: 6.0,
  Sport.crossCountrySki: 8.0,
  Sport.swimming: 6.5,
  Sport.tableTennis: 4.0,
  Sport.other: 7.0,
};

double calorieConsumption({required Sport sport, required double bodyWeight, double hours = 1.0}) {
  final coefficient = caloriesBurntPerKilogramPerHourBySport[sport];
  if (coefficient != null) {
    return coefficient * bodyWeight * hours;
  } else {
    return 7.0 * bodyWeight * hours;
  }
}
