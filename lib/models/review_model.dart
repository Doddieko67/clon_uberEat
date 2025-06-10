class Review {
  final String id;
  final String reviewerId; // ID of the user who left the review (customer)
  final String targetId; // ID of the entity being reviewed (store or deliverer)
  final double rating; // Rating out of 5, for example
  final String? comment;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.reviewerId,
    required this.targetId,
    required this.rating,
    this.comment,
    required this.timestamp,
  });

  Review copyWith({
    String? id,
    String? reviewerId,
    String? targetId,
    double? rating,
    String? comment,
    DateTime? timestamp,
  }) {
    return Review(
      id: id ?? this.id,
      reviewerId: reviewerId ?? this.reviewerId,
      targetId: targetId ?? this.targetId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'targetId': targetId,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] as String,
      reviewerId: map['reviewerId'] as String,
      targetId: map['targetId'] as String,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
