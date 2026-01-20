import '../models/habit.dart';
import 'database_helper.dart';

class HabitRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertHabit(Habit habit) async {
    final db = await _databaseHelper.database;
    return await db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      orderBy: 'sort_order ASC',
    );
    return List.generate(maps.length, (i) => Habit.fromMap(maps[i]));
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await _databaseHelper.database;
    
    final List<Map<String, dynamic>> existing = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [habit.id],
    );
    
    if (existing.isNotEmpty) {
      final oldHabit = Habit.fromMap(existing[0]);
      
      final timeChanged = oldHabit.reminder.hour != habit.reminder.hour ||
          oldHabit.reminder.minute != habit.reminder.minute;
      final scheduleChanged = oldHabit.customReminder != habit.customReminder ||
          oldHabit.reminderDays != habit.reminderDays;
      
      if ((timeChanged || scheduleChanged) && oldHabit.isCompletedToday) {
        final updatedHabit = habit.copyWith(
          currentStreak: oldHabit.currentStreak,
          maxStreak: oldHabit.maxStreak,
          lastCompletionDate: oldHabit.lastCompletionDate,
        );
        
        return await db.update(
          'habits',
          updatedHabit.toMap(),
          where: 'id = ?',
          whereArgs: [habit.id],
        );
      }
    }
    
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> resetStreakIfNeeded(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return;
    
    final habit = Habit.fromMap(maps[0]);
    if (habit.shouldResetStreak()) {
      await db.update(
        'habits',
        {'current_streak': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> completeHabit(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return;
    
    final habit = Habit.fromMap(maps[0]);
    if (habit.isCompletedToday) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int newStreak = 1;
    
    if (habit.lastCompletionDate != null && !habit.shouldResetStreak()) {
      final lastCompletion = DateTime(
        habit.lastCompletionDate!.year,
        habit.lastCompletionDate!.month,
        habit.lastCompletionDate!.day,
      );
      
      if (habit.customReminder && habit.reminderDays.isNotEmpty) {
        DateTime checkDate = lastCompletion.add(const Duration(days: 1));
        bool foundScheduledDay = false;
        
        while (checkDate.isBefore(today)) {
          if (habit.reminderDays.contains(checkDate.weekday)) {
            foundScheduledDay = true;
            break;
          }
          checkDate = checkDate.add(const Duration(days: 1));
        }
        
        if (!foundScheduledDay) {
          newStreak = habit.currentStreak + 1;
        }
      } else {
        final daysDiff = today.difference(lastCompletion).inDays;
        if (daysDiff == 1) {
          newStreak = habit.currentStreak + 1;
        }
      }
    }
    
    final newMaxStreak = newStreak > habit.maxStreak ? newStreak : habit.maxStreak;
    
    await db.update(
      'habits',
      {
        'current_streak': newStreak,
        'max_streak': newMaxStreak,
        'last_completion_date': now.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateHabitsOrder(List<Habit> habits) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    for (int i = 0; i < habits.length; i++) {
      batch.update(
        'habits',
        {'sort_order': i},
        where: 'id = ?',
        whereArgs: [habits[i].id],
      );
    }

    await batch.commit();
  }
}
