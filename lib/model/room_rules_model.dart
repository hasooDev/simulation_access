
/// ---- Room rules ----
class RoomRule {
  final String name;
  final int minAccessLevel;
  final String openTime; // "HH:mm"
  final String closeTime; // "HH:mm"
  final int cooldownMinutes;

  RoomRule({
    required this.name,
    required this.minAccessLevel,
    required this.openTime,
    required this.closeTime,
    required this.cooldownMinutes,
  });
}