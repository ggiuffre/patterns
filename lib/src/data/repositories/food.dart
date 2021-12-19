class FoodInfo {
  final String label;
  final double calories;
  final double? fat;
  final double? carbs;
  final double? fiber;
  final double? protein;
  final double? iron;

  const FoodInfo({
    required this.label,
    required this.calories,
    this.fat,
    this.carbs,
    this.fiber,
    this.protein,
    this.iron,
  });

  FoodInfo copyWith({
    String? label,
    double? calories,
    double? fat,
    double? carbs,
    double? fiber,
    double? protein,
    double? iron,
  }) =>
      FoodInfo(
        label: label ?? this.label,
        calories: calories ?? this.calories,
        fat: fat ?? this.fat,
        carbs: carbs ?? this.carbs,
        fiber: fiber ?? this.fiber,
        protein: protein ?? this.protein,
        iron: iron ?? this.iron,
      );
}

enum FoodType {
  muesli,
  breadAndButter,
  chickPeaSoup,
  lentilCurry,
  apple,
  pasta,
  rice,
  omelette,
  scrambledEggs,
  sandwich,
  falafelWrap,
  pizza,
  panettone,
  other,
}

const foodInfo = {
  FoodType.muesli: FoodInfo(
    label: "müesli",
    calories: 355,
    fat: 5.4,
    carbs: 74.9,
    fiber: 7.7,
    protein: 8.6,
    iron: 8.19,
  ),
  FoodType.breadAndButter: FoodInfo(
    label: "bread + butter",
    calories: 278,
    fat: 17,
    carbs: 24,
    protein: 6.1,
  ),
  FoodType.chickPeaSoup: FoodInfo(
    label: "chickpeas",
    calories: 210,
    fat: 8.91,
    carbs: 25.5,
    fiber: 7.1,
    protein: 8.23,
    iron: 2.7,
  ),
  FoodType.lentilCurry: FoodInfo(
    label: "lentil curry",
    calories: 110,
    fat: 5.61,
    carbs: 12.3,
    fiber: 3.4,
    protein: 3.67,
    iron: 1.44,
  ),
  FoodType.apple: FoodInfo(
    label: "apple",
    calories: 59,
    fat: 0.14,
    carbs: 14,
    fiber: 2.5,
    protein: 0.27,
    iron: 0.07,
  ),
  FoodType.pasta: FoodInfo(
    label: "tomato sauce pasta",
    calories: 45,
    fat: 1.48,
    carbs: 8,
    fiber: 1.8,
    protein: 1.41,
    iron: 0.78,
  ),
  FoodType.rice: FoodInfo(
    label: "rice pilaf",
    calories: 136,
    fat: 3.03,
    carbs: 24.1,
    fiber: 0.4,
    protein: 3.29,
    iron: 0.74,
  ),
  FoodType.omelette: FoodInfo(
    label: "omelette",
    calories: 180,
    fat: 14.2,
    carbs: 0.68,
    protein: 11.8,
    iron: 1.63,
  ),
  FoodType.scrambledEggs: FoodInfo(
    label: "scrambled eggs",
    calories: 180,
    fat: 14.2,
    carbs: 0.68,
    protein: 11.8,
    iron: 1.63,
  ),
  FoodType.sandwich: FoodInfo(
    label: "salami sandwich",
    calories: 325,
    fat: 16.2,
    carbs: 31.4,
    fiber: 1.5,
    protein: 12.7,
    iron: 1.56,
  ),
  FoodType.falafelWrap: FoodInfo(
    label: "falafel wrap",
    calories: 509,
    fat: 41.2,
    carbs: 29,
    fiber: 4.8,
    protein: 8.24,
    iron: 2.26,
  ),
  FoodType.pizza: FoodInfo(
    label: "pizza margherita",
    calories: 250,
    fat: 8,
    carbs: 32,
    fiber: 2.1,
    protein: 10,
    iron: 0.5,
  ),
  FoodType.panettone: FoodInfo(
    label: "panettone",
    calories: 362.5,
    fat: 12.5,
    carbs: 55,
    fiber: 2.5,
    protein: 6.3,
    iron: 0.9,
  ),
  FoodType.other: FoodInfo(label: "other", calories: 200),
};
