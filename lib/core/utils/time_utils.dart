/// Utility functions for time formatting
class TimeUtils {
  /// Formats a DateTime to 12-hour time format (e.g., "2:30 PM")
  /// Returns time string in format: "H:MM AM/PM"
  static String format12Hour(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    
    // Convert to 12-hour format
    final hour12 = hour > 12 
        ? hour - 12 
        : (hour == 0 ? 12 : hour);
    
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final minuteStr = minute.toString().padLeft(2, '0');
    
    return '$hour12:$minuteStr $amPm';
  }

  /// Formats a DateTime to 12-hour time format with zero-padded hour (e.g., "02:30 PM")
  /// Returns time string in format: "HH:MM AM/PM"
  static String format12HourPadded(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    
    // Convert to 12-hour format
    final hour12 = hour > 12 
        ? hour - 12 
        : (hour == 0 ? 12 : hour);
    
    final amPm = hour >= 12 ? 'PM' : 'AM';
    final hourStr = hour12.toString().padLeft(2, '0');
    final minuteStr = minute.toString().padLeft(2, '0');
    
    return '$hourStr:$minuteStr $amPm';
  }
}

