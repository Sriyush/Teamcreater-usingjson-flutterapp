import 'package:flutter/material.dart';

class TeamScreen extends StatelessWidget {
  final List<Map<String, dynamic>> teams;

  TeamScreen({required this.teams});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Teams"),
      ),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          final teamName = team['teamName'] ?? '';
          final members = team['members'] ?? [];

          return ListTile(
            title: Text(teamName),
            subtitle: Text("Members: ${members.length}"),
          );
        },
      ),
    );
  }
}
