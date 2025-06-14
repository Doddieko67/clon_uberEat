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
