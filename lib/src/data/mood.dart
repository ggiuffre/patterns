class Mood {
  final double happiness;
  final double stress;
  final double energy;

  const Mood({this.happiness = 0, this.stress = 0, this.energy = 0});

  Mood copyWith({double? happiness, double? stress, double? energy}) => Mood(
        happiness: happiness ?? this.happiness,
        stress: stress ?? this.stress,
        energy: energy ?? this.energy,
      );
}
