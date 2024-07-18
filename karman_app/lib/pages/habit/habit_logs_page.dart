import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:karman_app/controllers/habit/habit_controller.dart';
import 'package:karman_app/models/habits/habit.dart';
import 'package:provider/provider.dart';

class HabitLogsPage extends StatelessWidget {
  final Habit habit;

  const HabitLogsPage({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        middle: Text(
          'Habit Logs',
          style: TextStyle(color: CupertinoColors.white),
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<void>(
          future: context.read<HabitController>().loadHabitLogs(habit.habitId!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CupertinoActivityIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: CupertinoColors.white)));
            }

            return Consumer<HabitController>(
              builder: (context, controller, child) {
                final logs = controller.habitLogs[habit.habitId] ?? [];
                final nonEmptyLogs = logs
                    .where((log) => log.log != null && log.log!.isNotEmpty)
                    .toList();

                if (nonEmptyLogs.isEmpty) {
                  return Center(
                      child: Text('No logs available',
                          style: TextStyle(color: CupertinoColors.white)));
                }

                return ListView.builder(
                  itemCount: nonEmptyLogs.length,
                  itemBuilder: (context, index) {
                    final log = nonEmptyLogs[index];
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: CupertinoColors.darkBackgroundGray,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMMM d, y').format(log.date),
                              style: TextStyle(
                                color: CupertinoColors.systemBlue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              log.log!,
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
