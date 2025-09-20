import 'employe_request.dart';

class SimulationResult {
  final EmployeeRequest request;
  final bool granted;
  final String reason;
  SimulationResult({
    required this.request,
    required this.granted,
    required this.reason,
  });
}