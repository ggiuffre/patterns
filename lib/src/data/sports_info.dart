class SportsInfo {
  final String sport;
  final double energyPerKilogramPerHour;
  final double? hours;

  const SportsInfo({required this.sport, required this.energyPerKilogramPerHour, this.hours});

  SportsInfo copyWith({
    String? sport,
    double? energyPerKilogramPerHour,
    double? hours,
  }) =>
      SportsInfo(
        sport: sport ?? this.sport,
        energyPerKilogramPerHour: energyPerKilogramPerHour ?? this.energyPerKilogramPerHour,
        hours: hours ?? this.hours,
      );

  static double energyConsumption({required SportsInfo sport, required double bodyWeight}) =>
      sport.energyPerKilogramPerHour * bodyWeight * (sport.hours ?? 1);
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

// see https://www.nutristrategy.com/caloriesburned.htm
const sportsInfo = {
  Sport.running: SportsInfo(sport: "running", energyPerKilogramPerHour: 12.5),
  Sport.cycling: SportsInfo(sport: "cycling", energyPerKilogramPerHour: 8.0),
  Sport.muscleWorkout: SportsInfo(sport: "muscle workout", energyPerKilogramPerHour: 3.0),
  Sport.alpineSki: SportsInfo(sport: "alpine skiing", energyPerKilogramPerHour: 6.0),
  Sport.crossCountrySki: SportsInfo(sport: "cross-country skiing", energyPerKilogramPerHour: 8.0),
  Sport.swimming: SportsInfo(sport: "swimming", energyPerKilogramPerHour: 6.5),
  Sport.tableTennis: SportsInfo(sport: "ping pong", energyPerKilogramPerHour: 4.0),
  Sport.other: SportsInfo(sport: "other", energyPerKilogramPerHour: 7.0),
};
