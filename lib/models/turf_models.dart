class TurfItem {
  final int? id;
  final String name;
  final String sportType;
  final String address;
  final String city;
  final String state;
  final String pricePerHour;
  final String priceWeekend;
  final String maxCapacity;
  final String rating;
  final String reviews;
  final String occupancy;
  final String status;
  final String description;
  final List<String> amenities;
  final List<String> photos;
  final List<String> videos;
  final Map<String, dynamic> data;

  const TurfItem({
    required this.id,
    required this.name,
    required this.sportType,
    required this.address,
    required this.city,
    required this.state,
    required this.pricePerHour,
    required this.priceWeekend,
    required this.maxCapacity,
    required this.rating,
    required this.reviews,
    required this.occupancy,
    required this.status,
    required this.description,
    required this.amenities,
    required this.photos,
    required this.videos,
    this.data = const {},
  });

  factory TurfItem.fromJson(Map<String, dynamic> json) {
    final location = _asMap(json['location']);
    final media = _asMap(json['media']);
    final stats = _asMap(json['stats'] ?? json['summary']);

    return TurfItem(
      id: _intValue(json['id'] ?? json['turf_id'] ?? json['turfId']),
      name: _stringValue(json['name'], fallback: 'Turf'),
      sportType: _stringValue(
        json['sport_type'] ?? json['sportType'] ?? json['sport'],
        fallback: 'cricket',
      ),
      address: _stringValue(json['address'] ?? location['address']),
      city: _stringValue(json['city'] ?? location['city']),
      state: _stringValue(json['state'] ?? location['state']),
      pricePerHour: _money(json['price_per_hour'] ?? json['pricePerHour']),
      priceWeekend: _money(json['price_weekend'] ?? json['priceWeekend']),
      maxCapacity: _stringValue(
        json['max_capacity'] ?? json['maxCapacity'] ?? json['capacity'],
        fallback: '0',
      ),
      rating: _stringValue(
        json['rating'] ?? json['avg_rating'] ?? stats['rating'],
        fallback: '-',
      ),
      reviews: _stringValue(
        json['reviews_count'] ?? json['reviews'] ?? stats['reviews'],
        fallback: '0',
      ),
      occupancy: _occupancy(json, stats),
      status: _stringValue(json['status'] ?? json['approval_status'],
          fallback: _boolValue(json['is_active'] ?? json['active'])
              ? 'active'
              : 'pending'),
      description: _stringValue(json['description']),
      amenities: _stringList(json['amenities']),
      photos: _stringList(json['photos'] ?? media['photos']),
      videos: _stringList(json['videos'] ?? media['videos']),
      data: json,
    );
  }

  String get location {
    final parts = [address, city, state].where((part) => part.isNotEmpty);
    final text = parts.join(', ');
    return text.isEmpty ? '-' : text;
  }

  bool get isActive {
    final normalized = status.toLowerCase();
    return normalized.contains('active') ||
        normalized == 'approved' ||
        normalized == '1';
  }

  bool get isPending {
    final normalized = status.toLowerCase();
    return normalized.contains('pending') ||
        normalized.contains('review') ||
        normalized.contains('draft');
  }
}

class TurfListResponse {
  final List<TurfItem> turfs;

  const TurfListResponse({required this.turfs});

  factory TurfListResponse.fromJson(Object? value) {
    final root = _asMap(value);
    final data = root['data'];
    final list = data is List
        ? data
        : root['turfs'] ??
            root['items'] ??
            _asMap(data)['turfs'] ??
            _asMap(data)['items'] ??
            _asMap(data)['data'];

    return TurfListResponse(
      turfs: _asList(list)
          .map((item) => TurfItem.fromJson(_asMap(item)))
          .toList(),
    );
  }
}

class CreateTurfRequest {
  final String name;
  final String sportType;
  final String address;
  final String city;
  final String state;
  final String latitude;
  final String longitude;
  final String maxCapacity;
  final String pricePerHour;
  final String priceWeekend;
  final String operatingHoursOpen;
  final String operatingHoursClose;
  final String description;
  final List<String> amenities;
  final List<String> photoPaths;
  final List<String> videoPaths;

  const CreateTurfRequest({
    required this.name,
    required this.sportType,
    required this.address,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.maxCapacity,
    required this.pricePerHour,
    required this.priceWeekend,
    required this.operatingHoursOpen,
    required this.operatingHoursClose,
    required this.description,
    required this.amenities,
    this.photoPaths = const [],
    this.videoPaths = const [],
  });

  Map<String, dynamic> toFields() {
    return {
      'name': name,
      'sport_type': sportType,
      'address': address,
      'city': city,
      'state': state,
      'latitude': latitude,
      'longitude': longitude,
      'max_capacity': maxCapacity,
      'price_per_hour': pricePerHour,
      'price_weekend': priceWeekend,
      'operating_hours_open': operatingHoursOpen,
      'operating_hours_close': operatingHoursClose,
      'description': description,
      for (var i = 0; i < amenities.length; i++) 'amenities[$i]': amenities[i],
    };
  }
}

class UpdateTurfRequest {
  final String? name;
  final String? pricePerHour;
  final String? priceWeekend;
  final List<String>? amenities;

  const UpdateTurfRequest({
    this.name,
    this.pricePerHour,
    this.priceWeekend,
    this.amenities,
  });

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (pricePerHour != null) 'price_per_hour': num.tryParse(pricePerHour!),
      if (priceWeekend != null) 'price_weekend': num.tryParse(priceWeekend!),
      if (amenities != null) 'amenities': amenities,
    };
  }
}

class TurfPricing {
  final num weekday;
  final num weekend;
  final num peakHours;
  final bool surgePricingEnabled;
  final bool lastMinuteDiscountEnabled;
  final num surgeThreshold;
  final num surgeMultiplier;
  final num lastMinuteDiscountPercent;
  final num lastMinuteHoursBefore;
  final Map<String, dynamic> data;

  const TurfPricing({
    required this.weekday,
    required this.weekend,
    required this.peakHours,
    required this.surgePricingEnabled,
    required this.lastMinuteDiscountEnabled,
    required this.surgeThreshold,
    required this.surgeMultiplier,
    required this.lastMinuteDiscountPercent,
    required this.lastMinuteHoursBefore,
    this.data = const {},
  });

  factory TurfPricing.fromJson(Object? value) {
    final root = _asMap(value);
    final data = _asMap(root['data']);
    final pricing = _asMap(root['pricing']);
    final source = data.isNotEmpty
        ? data
        : pricing.isNotEmpty
            ? pricing
            : root;

    return TurfPricing(
      weekday: _numValue(source['weekday'], fallback: 0),
      weekend: _numValue(source['weekend'], fallback: 0),
      peakHours: _numValue(
        source['peak_hours'] ?? source['peakHours'],
        fallback: 0,
      ),
      surgePricingEnabled: _boolValue(
        source['surge_pricing_enabled'] ?? source['surgePricingEnabled'],
      ),
      lastMinuteDiscountEnabled: _boolValue(
        source['last_minute_discount_enabled'] ??
            source['lastMinuteDiscountEnabled'],
      ),
      surgeThreshold: _numValue(
        source['surge_threshold'] ?? source['surgeThreshold'],
        fallback: 80,
      ),
      surgeMultiplier: _numValue(
        source['surge_multiplier'] ?? source['surgeMultiplier'],
        fallback: 1.2,
      ),
      lastMinuteDiscountPercent: _numValue(
        source['last_minute_discount_percent'] ??
            source['lastMinuteDiscountPercent'],
        fallback: 20,
      ),
      lastMinuteHoursBefore: _numValue(
        source['last_minute_hours_before'] ?? source['lastMinuteHoursBefore'],
        fallback: 1,
      ),
      data: source,
    );
  }

  String get weekdayLabel => _money(weekday);
  String get weekendLabel => _money(weekend);
  String get peakHoursLabel => _money(peakHours);

  String get surgeSubtitle {
    final percent = ((surgeMultiplier - 1) * 100).round();
    return '+$percent% when more than ${_cleanNumber(surgeThreshold)}% booked';
  }

  String get lastMinuteSubtitle {
    return '${_cleanNumber(lastMinuteDiscountPercent)}% off unsold slots '
        '${_cleanNumber(lastMinuteHoursBefore)}h before start time';
  }
}

class UpdateTurfPricingRequest {
  final num? weekday;
  final num? weekend;
  final num? peakHours;
  final bool? surgePricingEnabled;
  final num? surgeThreshold;
  final num? surgeMultiplier;
  final bool? lastMinuteDiscountEnabled;
  final num? lastMinuteDiscountPercent;
  final num? lastMinuteHoursBefore;

  const UpdateTurfPricingRequest({
    this.weekday,
    this.weekend,
    this.peakHours,
    this.surgePricingEnabled,
    this.surgeThreshold,
    this.surgeMultiplier,
    this.lastMinuteDiscountEnabled,
    this.lastMinuteDiscountPercent,
    this.lastMinuteHoursBefore,
  });

  Map<String, dynamic> toJson() {
    return {
      if (weekday != null) 'weekday': weekday,
      if (weekend != null) 'weekend': weekend,
      if (peakHours != null) 'peak_hours': peakHours,
      if (surgePricingEnabled != null)
        'surge_pricing_enabled': surgePricingEnabled,
      if (surgeThreshold != null) 'surge_threshold': surgeThreshold,
      if (surgeMultiplier != null) 'surge_multiplier': surgeMultiplier,
      if (lastMinuteDiscountEnabled != null)
        'last_minute_discount_enabled': lastMinuteDiscountEnabled,
      if (lastMinuteDiscountPercent != null)
        'last_minute_discount_percent': lastMinuteDiscountPercent,
      if (lastMinuteHoursBefore != null)
        'last_minute_hours_before': lastMinuteHoursBefore,
    };
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

List<String> _stringList(Object? value) {
  if (value is List) {
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) return [value.trim()];
  return const [];
}

String _stringValue(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') return fallback;
  return text;
}

String _money(Object? value) {
  final text = _stringValue(value, fallback: '0');
  if (text.startsWith('Rs')) return text;
  return 'Rs $text';
}

int? _intValue(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

bool _boolValue(Object? value) {
  if (value is bool) return value;
  final text = value?.toString().toLowerCase();
  return text == '1' || text == 'true' || text == 'active';
}

num _numValue(Object? value, {required num fallback}) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? fallback;
}

String _cleanNumber(num value) {
  return value % 1 == 0 ? value.toInt().toString() : value.toString();
}

String _occupancy(Map<String, dynamic> json, Map<String, dynamic> stats) {
  final direct = _stringValue(
    json['occupancy'] ?? json['filled'] ?? stats['occupancy'],
  );
  if (direct.isNotEmpty) return direct.contains('%') ? direct : '$direct%';

  final booked = double.tryParse(
        _stringValue(json['booked_slots'] ?? stats['booked_slots']),
      ) ??
      0;
  final total = double.tryParse(
        _stringValue(json['total_slots'] ?? stats['total_slots']),
      ) ??
      0;
  if (total <= 0) return '-';
  return '${((booked / total) * 100).round()}%';
}
