class EmployeeRequest {
  final String id;
  final int accessLevel;
  final String requestTime;
  final String room;

  EmployeeRequest({
    required this.id,
    required this.accessLevel,
    required this.requestTime,
    required this.room,
  });

  factory EmployeeRequest.fromJson(Map<String, dynamic> json) {
    return EmployeeRequest(
      id: json['id'],
      accessLevel: json['access_level'],
      requestTime: json['request_time'],
      room: json['room'],
    );
  }
}
