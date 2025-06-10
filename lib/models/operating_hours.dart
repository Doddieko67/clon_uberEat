class OperatingHours {
  final String openTime;
  final String closeTime;

  OperatingHours({
    required this.openTime,
    required this.closeTime,
  });

  factory OperatingHours.fromMap(Map<String, dynamic> map) {
    return OperatingHours(
      openTime: map['openTime'] as String,
      closeTime: map['closeTime'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }
}
