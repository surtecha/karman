import 'package:karman_app/core/services/database/database_service.dart';
import 'package:karman_app/core/services/database/focus_db.dart';

class FocusService {
  final FocusDatabase _focusDatabase = FocusDatabase();

  Future<void> addFocusSession(int duration) async {
    print(
        "FocusService: Adding focus session with duration: $duration seconds"); // Debug print
    final database = await DatabaseService().database;
    final date = DateTime.now().toIso8601String().split('T')[0];
    await _focusDatabase.addFocusSession(database, duration, date);
  }

  Future<List<Map<String, dynamic>>> getFocusSessionsForDate(
      String date) async {
    final database = await DatabaseService().database;
    return await _focusDatabase.getFocusSessionsForDate(database, date);
  }

  Future<List<Map<String, dynamic>>> getFocusSessionsForDateRange(
      String startDate, String endDate) async {
    final database = await DatabaseService().database;
    return await _focusDatabase.getFocusSessionsForDateRange(
        database, startDate, endDate);
  }
}
