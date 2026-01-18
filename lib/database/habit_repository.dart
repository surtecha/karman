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

  Future<List<Habit>> getTodayHabits() async {
    final habits = await getAllHabits();
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    
    return habits.where((habit) {
      if (habit.isCompletedToday) return false;
      
      if (!habit.customReminder) return true;
      
      return habit.reminderDays.contains(currentWeekday);
    }).toList();
  }

  Future<List<Habit>> getScheduledHabits() async {
    final habits = await getAllHabits();
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    
    return habits.where((habit) {
      if (habit.isCompletedToday) return true;
      
      if (!habit.customReminder) return false;
      
      return !habit.reminderDays.contains(currentWeekday);
    }).toList();
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await _databaseHelper.database;
    
    // Get the existing habit to check if reminder time changed
    final List<Map<String, dynamic>> existing = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [habit.id],
    );
    
    if (existing.isNotEmpty) {
      final oldHabit = Habit.fromMap(existing[0]);
      
      // Check if reminder time changed and habit was completed today
      final timeChanged = oldHabit.reminder.hour != habit.reminder.hour ||
          oldHabit.reminder.minute != habit.reminder.minute;
      final customReminderChanged = oldHabit.customReminder != habit.customReminder ||
          oldHabit.reminderDays != habit.reminderDays;
      
      if ((timeChanged || customReminderChanged) && oldHabit.isCompletedToday) {
        // Preserve completion status and streak when time/schedule changes
        // This prevents exploitation while maintaining flexibility
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

  Future<void> completeHabit(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return;
    
    final habit = Habit.fromMap(maps[0]);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (habit.isCompletedToday) return;
    
    int newStreak = 1;
    int newMaxStreak = habit.maxStreak;
    
    if (habit.lastCompletionDate != null) {
      final lastCompletion = DateTime(
        habit.lastCompletionDate!.year,
        habit.lastCompletionDate!.month,
        habit.lastCompletionDate!.day,
      );
      
      if (habit.customReminder && habit.reminderDays.isNotEmpty) {
        DateTime checkDate = lastCompletion.add(const Duration(days: 1));
        int missedDays = 0;
        
        while (checkDate.isBefore(today)) {
          if (habit.reminderDays.contains(checkDate.weekday)) {
            missedDays++;
          }
          checkDate = checkDate.add(const Duration(days: 1));
        }
        
        if (missedDays == 0) {
          newStreak = habit.currentStreak + 1;
        }
      } else {
        final daysDifference = today.difference(lastCompletion).inDays;
        
        if (daysDifference == 1) {
          newStreak = habit.currentStreak + 1;
        }
      }
    }
    
    if (newStreak > newMaxStreak) {
      newMaxStreak = newStreak;
    }
    
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
