import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_based_employe_access_simulator/ui/simulation_access.dart';
import 'package:time_based_employe_access_simulator/utils/utilites.dart';

import 'model/employe_request.dart';
import 'model/room_rules_model.dart';
import 'model/simulation_result_model.dart';

void main() {
  runApp(const AccessSimulatorApp());
}

class AccessSimulatorApp extends StatelessWidget {
  const AccessSimulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Access Simulator',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const AccessSimulatorScreen(),
    );
  }
}





