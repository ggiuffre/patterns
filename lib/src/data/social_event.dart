class SocialEvent {
  final String type;
  final int? numberOfPeople;

  const SocialEvent({required this.type, this.numberOfPeople});

  SocialEvent copyWith({String? type, int? numberOfPeople}) => SocialEvent(
        type: type ?? this.type,
        numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      );
}
