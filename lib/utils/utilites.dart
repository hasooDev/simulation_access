import '../model/employe_request.dart';
import '../model/room_rules_model.dart';

String _formatRequest(EmployeeRequest r) =>
    '${r.id} • ${r.room} • ${r.requestTime} • lvl ${r.accessLevel}';

/// Helper to parse a "HH:mm" into a DateTime using today's date
 DateTime timeOfDayToDateTime(String hhmm) {
  final now = DateTime.now();
  final parts = hhmm.split(':');
  final int hour = int.parse(parts[0]);
  final int minute = int.parse(parts[1]);
  return DateTime(now.year, now.month, now.day, hour, minute);
}

// Inline employee JSON as requested in the spec
final String employeeJson = '''
[
  { "id": "EMP001", "access_level": 2, "request_time": "09:15", "room": "ServerRoom" },
  { "id": "EMP002", "access_level": 1, "request_time": "09:30", "room": "Vault" },
  { "id": "EMP003", "access_level": 3, "request_time": "10:05", "room": "ServerRoom" },
  { "id": "EMP004", "access_level": 3, "request_time": "09:45", "room": "Vault" },
  { "id": "EMP005", "access_level": 2, "request_time": "08:50", "room": "R&D Lab" },
  { "id": "EMP006", "access_level": 1, "request_time": "10:10", "room": "R&D Lab" },
  { "id": "EMP007", "access_level": 2, "request_time": "10:18", "room": "ServerRoom" },
  { "id": "EMP008", "access_level": 3, "request_time": "09:55", "room": "Vault" },
  { "id": "EMP001", "access_level": 2, "request_time": "09:28", "room": "ServerRoom" },
  { "id": "EMP006", "access_level": 1, "request_time": "10:15", "room": "R&D Lab" }
]
''';


// Room rules as specified
final Map<String, RoomRule> roomRules = {
  'ServerRoom': RoomRule(
    name: 'ServerRoom',
    minAccessLevel: 2,
    openTime: '09:00',
    closeTime: '11:00',
    cooldownMinutes: 15,
  ),
  'Vault': RoomRule(
    name: 'Vault',
    minAccessLevel: 3,
    openTime: '09:00',
    closeTime: '10:00',
    cooldownMinutes: 30,
  ),
  'R&D Lab': RoomRule(
    name: 'R&D Lab',
    minAccessLevel: 1,
    openTime: '08:00',
    closeTime: '12:00',
    cooldownMinutes: 10,
  ),
};
