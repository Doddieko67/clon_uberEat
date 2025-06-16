class TimeRange {
  final String open;
  final String close;

  TimeRange({
    required this.open,
    required this.close,
  });

  Map<String, dynamic> toMap() {
    return {
      'open': open,
      'close': close,
    };
  }

  factory TimeRange.fromMap(Map<String, dynamic> map) {
    return TimeRange(
      open: map['open'] as String,
      close: map['close'] as String,
    );
  }
}

// Extended class for more detailed day operations
class DayHours {
  final bool isOpen;
  final String? openTime;
  final String? closeTime;

  DayHours({
    required this.isOpen,
    this.openTime,
    this.closeTime,
  });

  // Convert to TimeRange for compatibility
  TimeRange toTimeRange() {
    return TimeRange(
      open: openTime ?? '00:00',
      close: closeTime ?? '00:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isOpen': isOpen,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  factory DayHours.fromMap(Map<String, dynamic> map) {
    return DayHours(
      isOpen: map['isOpen'] as bool? ?? false,
      openTime: map['openTime'] as String?,
      closeTime: map['closeTime'] as String?,
    );
  }
}

class OperatingHours {
  final TimeRange monday;
  final TimeRange tuesday;
  final TimeRange wednesday;
  final TimeRange thursday;
  final TimeRange friday;
  final TimeRange saturday;
  final TimeRange sunday;

  OperatingHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  // Constructor de conveniencia para horarios iguales todos los días
  factory OperatingHours.standard(String openTime, String closeTime) {
    final timeRange = TimeRange(open: openTime, close: closeTime);
    return OperatingHours(
      monday: timeRange,
      tuesday: timeRange,
      wednesday: timeRange,
      thursday: timeRange,
      friday: timeRange,
      saturday: timeRange,
      sunday: timeRange,
    );
  }

  // Constructor using DayHours for more control
  factory OperatingHours.fromDayHours({
    required DayHours monday,
    required DayHours tuesday,
    required DayHours wednesday,
    required DayHours thursday,
    required DayHours friday,
    required DayHours saturday,
    required DayHours sunday,
  }) {
    return OperatingHours(
      monday: monday.toTimeRange(),
      tuesday: tuesday.toTimeRange(),
      wednesday: wednesday.toTimeRange(),
      thursday: thursday.toTimeRange(),
      friday: friday.toTimeRange(),
      saturday: saturday.toTimeRange(),
      sunday: sunday.toTimeRange(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monday': monday.toMap(),
      'tuesday': tuesday.toMap(),
      'wednesday': wednesday.toMap(),
      'thursday': thursday.toMap(),
      'friday': friday.toMap(),
      'saturday': saturday.toMap(),
      'sunday': sunday.toMap(),
    };
  }

  factory OperatingHours.fromMap(Map<String, dynamic> map) {
    return OperatingHours(
      monday: TimeRange.fromMap(map['monday'] as Map<String, dynamic>),
      tuesday: TimeRange.fromMap(map['tuesday'] as Map<String, dynamic>),
      wednesday: TimeRange.fromMap(map['wednesday'] as Map<String, dynamic>),
      thursday: TimeRange.fromMap(map['thursday'] as Map<String, dynamic>),
      friday: TimeRange.fromMap(map['friday'] as Map<String, dynamic>),
      saturday: TimeRange.fromMap(map['saturday'] as Map<String, dynamic>),
      sunday: TimeRange.fromMap(map['sunday'] as Map<String, dynamic>),
    );
  }

  // Para compatibilidad con la implementación anterior
  String get openTime => monday.open; // Fallback al lunes
  String get closeTime => monday.close; // Fallback al lunes
}