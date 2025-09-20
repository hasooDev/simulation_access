
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_based_employe_access_simulator/model/employe_request.dart';
import 'package:time_based_employe_access_simulator/model/simulation_result_model.dart';
import 'package:time_based_employe_access_simulator/utils/utilites.dart';

class AccessSimulatorScreen extends StatefulWidget {
  const AccessSimulatorScreen({super.key});

  @override
  State<AccessSimulatorScreen> createState() => _AccessSimulatorScreenState();
}

class _AccessSimulatorScreenState extends State<AccessSimulatorScreen> {


  // Parsed requests
  late List<EmployeeRequest> _requests;

  // Simulation results
  List<SimulationResult> _results = [];

  // For simple UI: toggle sorting (original vs chronological)
  bool _sortChronological = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    final List<dynamic> list = jsonDecode(employeeJson);
    _requests = list.map((e) => EmployeeRequest.fromJson(e)).toList();
  }


  /// Main simulation function
  void _simulateAccess() {
    // We will run the events in chronological order to emulate time sequence.
    final List<EmployeeRequest> timeline = List.from(_requests);
    timeline.sort((a, b) {
      final ta = timeOfDayToDateTime(a.requestTime);
      final tb = timeOfDayToDateTime(b.requestTime);
      return ta.compareTo(tb);
    });

    // Track last successful access per employee per room
    final Map<String, DateTime> lastAccess = {
      // key = "${employeeId}::${room}"
    };

    final List<SimulationResult> results = [];

    for (final req in timeline) {
      final rule = roomRules[req.room];
      if (rule == null) {
        results.add(SimulationResult(
          request: req,
          granted: false,
          reason: 'Denied: Unknown room "${req.room}"',
        ));
        continue;
      }

      final DateTime reqTime = timeOfDayToDateTime(req.requestTime);
      final DateTime openAt = timeOfDayToDateTime(rule.openTime);
      final DateTime closeAt = timeOfDayToDateTime(rule.closeTime);

      // Check access level
      if (req.accessLevel < rule.minAccessLevel) {
        results.add(SimulationResult(
          request: req,
          granted: false,
          reason:
          'Denied: Below required level (requires ${rule.minAccessLevel})',
        ));
        continue;
      }

      // Check open hours (inclusive of open time, exclusive of close time)
      if (!(reqTime.isAtSameMomentAs(openAt) ||
          (reqTime.isAfter(openAt) && reqTime.isBefore(closeAt)))) {
        results.add(SimulationResult(
          request: req,
          granted: false,
          reason:
          'Denied: Outside open hours (${rule.openTime} - ${rule.closeTime})',
        ));
        continue;
      }

      // Check cooldown
      final String key = '${req.id}::${req.room}';
      final DateTime? last = lastAccess[key];
      if (last != null) {
        final int diffMinutes = reqTime
            .difference(last)
            .inMinutes;
        if (diffMinutes < rule.cooldownMinutes) {
          final int wait = rule.cooldownMinutes - diffMinutes;
          results.add(SimulationResult(
            request: req,
            granted: false,
            reason:
            'Denied: Cooldown active for $wait more minute(s) (cooldown ${rule
                .cooldownMinutes}m)',
          ));
          continue;
        }
      }

      // Grant access: record last access time for cooldown tracking
      lastAccess[key] = reqTime;
      results.add(SimulationResult(
        request: req,
        granted: true,
        reason: 'Access granted to ${req.room} at ${req.requestTime}',
      ));
    }

    // Optionally reorder results to original input order for display.
    // We'll store chronological results, but we also provide a mapping to the original order.
    setState(() {
      _results = results;
    });
  }


  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm');

    // For display, optionally show original list or chronological timeline
    final displayList = _sortChronological
        ? List<EmployeeRequest>.from(_requests
      ..sort((a, b) =>
          timeOfDayToDateTime(a.requestTime)
              .compareTo(timeOfDayToDateTime(b.requestTime)))
    ) : _requests;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shadowColor: Colors.white,
        surfaceTintColor: Colors.white,

        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Access Simulator'),

      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Top instruction card
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(

                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Load the sample employee data below and press "Simulate Access" to see which requests are granted or denied. Each decision includes a short reason.',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Sort: '),
                        Switch(
                          value: _sortChronological,
                          onChanged: (v) {
                            setState(() => _sortChronological = v);
                          },
                        ),
                        const Text('Chronological'),


                      ],
                    ),
                    ElevatedButton.icon(

                      onPressed: _simulateAccess,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Simulate Access'),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Employee list
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Employee Requests:',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 1,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, i) {
                          final r = displayList[i];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              child: Text(r.id.replaceAll('EMP', '')),
                            ),
                            title: Text(r.id),
                            subtitle:
                            Text('${r.room} • ${r.requestTime} • lvl ${r
                                .accessLevel}'),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(height: 8),
                        itemCount: displayList.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Results
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Simulation Results:',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      elevation: 2,
                      child: _results.isEmpty
                          ? const Center(
                        child: Text(
                          'No results yet. Press "Simulate Access".',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                          : ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, i) {
                          final r = _results[i];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              backgroundColor:
                              r.granted ? Colors.green : Colors.red,
                              child: Icon(
                                r.granted ? Icons.check : Icons.close,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                                '${r.request.id} • ${r.request.room} • ${r
                                    .request.requestTime}'),
                            subtitle: Text(r.reason),
                          );
                        },
                        separatorBuilder: (_, __) =>
                        const Divider(height: 8),
                        itemCount: _results.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
