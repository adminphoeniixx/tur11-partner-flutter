class BookingItem {
  final String id;
  final String customerName;
  final String phone;
  final String turfName;
  final String dateTime;
  final String players;
  final String amount;
  final String status;
  final Map<String, dynamic> data;

  const BookingItem({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.turfName,
    required this.dateTime,
    required this.players,
    required this.amount,
    required this.status,
    this.data = const {},
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    final customer = _asMap(json['customer'] ?? json['user']);
    final turf = _asMap(json['turf']);

    return BookingItem(
      id: _stringValue(
        json['booking_id'] ?? json['bookingId'] ?? json['code'] ?? json['id'],
        fallback: '-',
      ),
      customerName: _stringValue(
        json['customer_name'] ?? json['customerName'] ?? customer['name'],
        fallback: 'Customer',
      ),
      phone: _stringValue(json['phone'] ?? customer['phone']),
      turfName: _stringValue(
        json['turf_name'] ?? json['turfName'] ?? turf['name'],
        fallback: 'Turf',
      ),
      dateTime: _dateTime(json),
      players: _stringValue(
        json['players'] ?? json['player_count'] ?? json['playerCount'],
        fallback: '0',
      ),
      amount: _money(json['amount'] ?? json['total'] ?? json['price']),
      status: _stringValue(json['status'], fallback: 'confirmed'),
      data: json,
    );
  }
}

class BookingStats {
  final String total;
  final String confirmed;
  final String cancelled;
  final String pendingPay;

  const BookingStats({
    this.total = '0',
    this.confirmed = '0',
    this.cancelled = '0',
    this.pendingPay = '0',
  });

  factory BookingStats.fromBookings(
    List<BookingItem> bookings, [
    Map<String, dynamic> raw = const {},
  ]) {
    final stats = _firstMap(raw, const ['stats', 'summary', 'counts']);
    if (stats.isNotEmpty) {
      return BookingStats(
        total: _stringValue(
          stats['total'] ?? stats['total_bookings'],
          fallback: bookings.length.toString(),
        ),
        confirmed: _stringValue(stats['confirmed'], fallback: '0'),
        cancelled: _stringValue(stats['cancelled'] ?? stats['canceled'],
            fallback: '0'),
        pendingPay: _stringValue(
          stats['pending_pay'] ?? stats['pendingPay'] ?? stats['pending'],
          fallback: '0',
        ),
      );
    }

    return BookingStats(
      total: bookings.length.toString(),
      confirmed: _count(bookings, 'confirm').toString(),
      cancelled: _count(bookings, 'cancel').toString(),
      pendingPay: _count(bookings, 'pending').toString(),
    );
  }
}

class BookingsResponse {
  final List<BookingItem> bookings;
  final BookingStats stats;

  const BookingsResponse({
    required this.bookings,
    required this.stats,
  });

  factory BookingsResponse.fromJson(Object? value) {
    final root = _asMap(value);
    final data = root['data'];
    final list = data is List
        ? data
        : root['bookings'] ?? _asMap(data)['bookings'] ?? _asMap(data)['items'];
    final bookings = _asList(list)
        .map((item) => BookingItem.fromJson(_asMap(item)))
        .toList();

    return BookingsResponse(
      bookings: bookings,
      stats: BookingStats.fromBookings(
        bookings,
        _asMap(data).isNotEmpty ? _asMap(data) : root,
      ),
    );
  }
}

class CancellationItem {
  final String id;
  final String customerName;
  final String turfName;
  final String time;
  final String cancelledBefore;
  final String refund;
  final String status;

  const CancellationItem({
    required this.id,
    required this.customerName,
    required this.turfName,
    required this.time,
    required this.cancelledBefore,
    required this.refund,
    required this.status,
  });

  factory CancellationItem.fromJson(Map<String, dynamic> json) {
    final booking = _asMap(json['booking']);
    final customer = _asMap(json['customer'] ?? booking['customer']);
    final turf = _asMap(json['turf'] ?? booking['turf']);

    return CancellationItem(
      id: _stringValue(
        json['booking_id'] ?? booking['booking_id'] ?? booking['id'] ?? json['id'],
        fallback: '-',
      ),
      customerName: _stringValue(
        json['customer_name'] ?? customer['name'] ?? booking['customer_name'],
        fallback: 'Customer',
      ),
      turfName: _stringValue(
        json['turf_name'] ?? turf['name'] ?? booking['turf_name'],
        fallback: 'Turf',
      ),
      time: _stringValue(
        json['cancelled_at'] ?? json['time'] ?? booking['date_time'],
      ),
      cancelledBefore: _stringValue(
        json['cancelled_before'] ??
            json['cancelledBefore'] ??
            json['hours_before'],
        fallback: 'Cancelled',
      ),
      refund: _money(
        json['refund'] ?? json['refund_amount'] ?? json['refundAmount'],
      ),
      status: _stringValue(json['status'], fallback: 'processed'),
    );
  }
}

class CancellationsResponse {
  final List<CancellationItem> cancellations;

  const CancellationsResponse({required this.cancellations});

  factory CancellationsResponse.fromJson(Object? value) {
    final root = _asMap(value);
    final data = root['data'];
    final list = data is List
        ? data
        : root['cancellations'] ??
            root['items'] ??
            _asMap(data)['cancellations'] ??
            _asMap(data)['items'];
    return CancellationsResponse(
      cancellations: _asList(list)
          .map((item) => CancellationItem.fromJson(_asMap(item)))
          .toList(),
    );
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

String _money(Object? value) {
  final text = _stringValue(value, fallback: '0');
  if (text.startsWith('Rs') || text.startsWith('₹')) return text;
  return 'Rs $text';
}

String _dateTime(Map<String, dynamic> json) {
  final direct = _stringValue(
    json['date_time'] ?? json['dateTime'] ?? json['slot'],
  );
  if (direct.isNotEmpty) return direct;
  return [
    _stringValue(json['date'] ?? json['booking_date']),
    _stringValue(json['time'] ?? json['slot_time'] ?? json['start_time']),
  ].where((part) => part.isNotEmpty).join(', ');
}

int _count(List<BookingItem> bookings, String needle) {
  return bookings
      .where((booking) => booking.status.toLowerCase().contains(needle))
      .length;
}
