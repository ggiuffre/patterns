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
  muscleWorkout,
  alpineSki,
  crossCountrySki,
  swimming,
  other,
}

const sportsInfo = {
  Sport.running: SportsInfo(sport: "running", calories: 900),
  Sport.muscleWorkout: SportsInfo(sport: "muscle workout", calories: 250),
  Sport.alpineSki: SportsInfo(sport: "alpine skiing", calories: 490),
  Sport.crossCountrySki: SportsInfo(sport: "cross-country skiing", calories: 655),
  Sport.swimming: SportsInfo(sport: "swimming", calories: 570),
  Sport.other: SportsInfo(sport: "other"),
};
