class Event {
  final String id;
  final String title;
  final DateTime time;

  Event(this.title, this.time) : id = "$title$time";
}
