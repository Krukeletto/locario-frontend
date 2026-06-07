class ReviewRequest {
  const ReviewRequest({required this.rating, this.comment});

  final int rating;
  final String? comment;

  Map<String, Object?> toJson() {
    return {
      'rating': rating,
      if (comment != null && comment!.trim().isNotEmpty) 'comment': comment,
    };
  }

  factory ReviewRequest.fromJson(Map<String, dynamic> json) {
    return ReviewRequest(
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
    );
  }
}

class AverageRating {
  const AverageRating({
    required this.averageRating,
    required this.totalReviews,
  });

  final double averageRating;
  final int totalReviews;

  bool get hasReviews => totalReviews > 0;

  factory AverageRating.fromJson(Map<String, dynamic> json) {
    return AverageRating(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['totalReviews'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'averageRating': averageRating, 'totalReviews': totalReviews};
  }
}

class ReviewResponse {
  const ReviewResponse({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.username,
    required this.rating,
    required this.createdAt,
    this.comment,
  });

  final String id;
  final String eventId;
  final String userId;
  final String username;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['id'] as String,
      eventId: json['eventId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      username: json['username'] as String? ?? '',
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'username': username,
      'rating': rating,
      if (comment != null) 'comment': comment,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

class OrganizerReviewEntry {
  const OrganizerReviewEntry({
    required this.eventId,
    required this.eventTitle,
    required this.review,
  });

  final String eventId;
  final String eventTitle;
  final ReviewResponse review;
}

class OrganizerReviewsOverview {
  const OrganizerReviewsOverview({
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  final AverageRating averageRating;
  final int totalReviews;
  final List<OrganizerReviewEntry> reviews;

  bool get hasReviews => totalReviews > 0;
}
