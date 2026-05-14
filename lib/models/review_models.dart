class ReviewItem {
  final int? id;
  final String reviewerName;
  final String meta;
  final double rating;
  final String text;
  final List<String> tags;
  final String? reply;
  final String type;
  final Map<String, dynamic> data;

  const ReviewItem({
    this.id,
    required this.reviewerName,
    required this.meta,
    required this.rating,
    required this.text,
    this.tags = const [],
    this.reply,
    this.type = 'turf',
    this.data = const {},
  });

  String get initials {
    final parts = reviewerName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'RV';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['user'] ?? json['customer'] ?? json['reviewer']);
    final turf = _asMap(json['turf']);
    final tournament = _asMap(json['tournament']);
    final type = _stringValue(
      json['type'] ?? json['review_type'] ?? json['reviewType'],
      fallback: tournament.isNotEmpty ? 'tournament' : 'turf',
    );

    return ReviewItem(
      id: _asInt(json['id']),
      reviewerName: _stringValue(
        json['name'] ??
            json['reviewer_name'] ??
            json['reviewerName'] ??
            user['name'],
        fallback: 'Reviewer',
      ),
      meta: _meta(json, turf, tournament),
      rating: _asDouble(json['rating'] ?? json['stars']),
      text: _stringValue(
        json['review'] ?? json['comment'] ?? json['text'] ?? json['message'],
      ),
      tags: _tags(json['tags'] ?? json['badges']),
      reply: json['reply']?.toString(),
      type: type,
      data: json,
    );
  }
}

class ReviewSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingCounts;
  final Map<String, double> categories;

  const ReviewSummary({
    this.averageRating = 0,
    this.totalReviews = 0,
    this.ratingCounts = const {},
    this.categories = const {},
  });

  factory ReviewSummary.fromJson(
    Map<String, dynamic> json,
    List<ReviewItem> reviews,
  ) {
    final summary = _firstMap(json, const ['summary', 'stats', 'rating_summary']);
    final ratingCounts = <int, int>{};
    final counts = _asMap(summary['rating_counts'] ?? summary['ratingCounts']);
    for (var i = 1; i <= 5; i++) {
      ratingCounts[i] = _asInt(counts[i.toString()]) ??
          reviews.where((review) => review.rating.round() == i).length;
    }

    final categories = <String, double>{};
    final rawCategories = _asMap(summary['categories'] ?? json['categories']);
    rawCategories.forEach((key, value) {
      categories[_label(key)] = _asDouble(value);
    });

    final computedAverage = reviews.isEmpty
        ? 0.0
        : reviews.map((review) => review.rating).reduce((a, b) => a + b) /
            reviews.length;

    return ReviewSummary(
      averageRating: _asDouble(
        summary['average_rating'] ??
            summary['averageRating'] ??
            summary['rating'] ??
            json['average_rating'],
        fallback: computedAverage,
      ),
      totalReviews: _asInt(
            summary['total_reviews'] ??
                summary['totalReviews'] ??
                summary['total'] ??
                json['total'],
          ) ??
          reviews.length,
      ratingCounts: ratingCounts,
      categories: categories,
    );
  }
}

class ReviewsResponse {
  final List<ReviewItem> reviews;
  final ReviewSummary summary;

  const ReviewsResponse({
    required this.reviews,
    required this.summary,
  });

  factory ReviewsResponse.fromJson(Object? value) {
    final root = _asMap(value);
    final data = root['data'];
    final list = data is List
        ? data
        : root['reviews'] ?? _asMap(data)['reviews'] ?? _asMap(data)['items'];
    final reviews = _asList(list)
        .map((item) => ReviewItem.fromJson(_asMap(item)))
        .toList();
    final source = _asMap(data).isNotEmpty ? _asMap(data) : root;

    return ReviewsResponse(
      reviews: reviews,
      summary: ReviewSummary.fromJson(source, reviews),
    );
  }
}

class ReviewReplyRequest {
  final String reply;

  const ReviewReplyRequest({required this.reply});

  Map<String, dynamic> toJson() {
    return {'reply': reply.trim()};
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

List<dynamic> _asList(Object? value) {
  if (value is List) return value;
  return const [];
}

Map<String, dynamic> _firstMap(Map<String, dynamic> source, List<String> keys) {
  for (final key in keys) {
    final mapped = _asMap(source[key]);
    if (mapped.isNotEmpty) return mapped;
  }
  return {};
}

String _stringValue(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') return fallback;
  return text;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value == null) return null;
  return int.tryParse(value.toString());
}

double _asDouble(Object? value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

List<String> _tags(Object? value) {
  if (value is List) {
    return value
        .map((tag) => tag.toString().trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
  return const [];
}

String _meta(
  Map<String, dynamic> json,
  Map<String, dynamic> turf,
  Map<String, dynamic> tournament,
) {
  final date = _stringValue(json['date'] ?? json['created_at']);
  final venue = _stringValue(
    json['turf_name'] ??
        turf['name'] ??
        json['tournament_name'] ??
        tournament['name'],
  );
  final sport = _stringValue(json['sport'] ?? json['format']);
  return [date, venue, sport].where((part) => part.isNotEmpty).join(' - ');
}

String _label(String value) {
  return value
      .split(RegExp(r'[_\s-]+'))
      .where((part) => part.isNotEmpty)
      .map((part) =>
          '${part.substring(0, 1).toUpperCase()}${part.substring(1).toLowerCase()}')
      .join(' ');
}
