class SlotItem {
  final int? id;
  final String turfName;
  final String date;
  final String startTime;
  final String endTime;
  final String status;
  final String price;
  final String customerName;
  final String blockReason;
  final Map<String, dynamic> data;

  const SlotItem({
    required this.id,
    required this.turfName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.price,
    required this.customerName,
    required this.blockReason,
    this.data = const {},
  });

  factory SlotItem.fromJson(Map<String, dynamic> json) {
    final turf = _asMap(json['turf']);
    final booking = _asMap(json['booking']);
    final customer = _asMap(
      json['customer'] ?? json['user'] ?? booking['customer'] ?? booking['user'],
    );

    return SlotItem(
      id: _intValue(json['id'] ?? json['slot_id'] ?? json['slotId']),
      turfName: _stringValue(
        json['turf_name'] ?? json['turfName'] ?? turf['name'],
        fallback: 'Turf',
      ),
      date: _stringValue(json['date'] ?? json['slot_date']),
      startTime: _timeValue(
        json['start_time'] ??
            json['startTime'] ??
            json['time_start'] ??
            json['from'] ??
            json['time'],
      ),
      endTime: _timeValue(
        json['end_time'] ?? json['endTime'] ?? json['time_end'] ?? json['to'],
      ),
      status: _stringValue(json['status'], fallback: 'available'),
      price: _money(
        json['price'] ??
            json['amount'] ??
            json['slot_price'] ??
            booking['amount'],
      ),
      customerName: _stringValue(
        json['customer_name'] ??
            json['booked_by'] ??
            customer['name'] ??
            booking['customer_name'],
      ),
      blockReason: _stringValue(
        json['block_reason'] ?? json['reason'] ?? json['blocked_reason'],
      ),
      data: json,
    );
  }

  bool get isBooked {
    final normalized = status.toLowerCase();
    return normalized.contains('book') || normalized.contains('confirm');
  }

  bool get isBlocked => status.toLowerCase().contains('block');

  bool get isAvailable => !isBooked && !isBlocked;

  String get timeLabel {
    if (endTime.isEmpty) return startTime.isEmpty ? '-' : _formatTime(startTime);
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String get infoLabel {
    if (isBooked) {
      final name = customerName.isEmpty ? 'Booked' : customerName;
      return '$name - $price';
    }
    if (isBlocked) {
      return blockReason.isEmpty ? 'Blocked' : blockReason;
    }
    return price == 'Rs 0' ? 'Available' : 'Available - $price';
  }
}

class SlotsResponse {
  final List<SlotItem> slots;

  const SlotsResponse({required this.slots});

  factory SlotsResponse.fromJson(Object? value) {
    final root = _asMap(value);
    final data = root['data'];
    final dataMap = _asMap(data);
    final list = data is List
        ? data
        : root['slots'] ??
            root['items'] ??
            dataMap['slots'] ??
            dataMap['items'] ??
            dataMap['data'];

    return SlotsResponse(
      slots: _asList(list)
          .map((item) => SlotItem.fromJson(_asMap(item)))
          .toList(),
    );
  }
}

class GenerateSlotsRequest {
  final int turfId;
  final String dateFrom;
  final String dateTo;
  final int slotDuration;

  const GenerateSlotsRequest({
    required this.turfId,
    required this.dateFrom,
    required this.dateTo,
    required this.slotDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'turf_id': turfId,
      'date_from': dateFrom,
      'date_to': dateTo,
      'slot_duration': slotDuration,
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

String _stringValue(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') return fallback;
  return text;
}

String _timeValue(Object? value) {
  final text = _stringValue(value);
  if (text.length >= 5 && RegExp(r'^\d{2}:\d{2}').hasMatch(text)) {
    return text.substring(0, 5);
  }
  return text;
}

String _money(Object? value) {
  final text = _stringValue(value, fallback: '0');
  if (text.startsWith('Rs') || text.startsWith('₹')) return text;
  return 'Rs $text';
}

int? _intValue(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String _formatTime(String value) {
  final text = value.trim();
  final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(text);
  if (match == null) return text;
  final hour = int.tryParse(match.group(1)!) ?? 0;
  final minute = match.group(2)!;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$displayHour:$minute $period';
}
