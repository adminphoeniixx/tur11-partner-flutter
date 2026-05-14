class DashboardData {
  final String revenueToday;
  final String revenueChange;
  final String bookingsToday;
  final String bookingsChange;
  final String activeSlots;
  final String activeSlotsChange;
  final String pendingPayouts;
  final String pendingPayoutsChange;
  final String activeTurfs;
  final List<DashboardBooking> recentBookings;
  final Map<String, dynamic> data;

  const DashboardData({
    this.revenueToday = 'Rs 0',
    this.revenueChange = 'Today',
    this.bookingsToday = '0',
    this.bookingsChange = 'Today',
    this.activeSlots = '0',
    this.activeSlotsChange = 'Available',
    this.pendingPayouts = 'Rs 0',
    this.pendingPayoutsChange = 'Processing',
    this.activeTurfs = '0',
    this.recentBookings = const [],
    this.data = const {},
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final stats = _firstMap(json, const ['stats', 'summary', 'counts', 'data']);
    final bookingsValue = json['recent_bookings'] ??
        json['recentBookings'] ??
        json['bookings'] ??
        stats['recent_bookings'];

    return DashboardData(
      revenueToday: _money(_firstValue(stats, json, const [
        'revenue_today',
        'today_revenue',
        'revenue',
        'total_revenue',
      ])),
      revenueChange: _stringValue(_firstValue(stats, json, const [
        'revenue_change',
        'revenueChange',
      ]), fallback: 'Today'),
      bookingsToday: _stringValue(_firstValue(stats, json, const [
        'bookings_today',
        'today_bookings',
        'bookings',
        'total_bookings',
      ]), fallback: '0'),
      bookingsChange: _stringValue(_firstValue(stats, json, const [
        'bookings_change',
        'bookingsChange',
      ]), fallback: 'Today'),
      activeSlots: _slots(stats, json),
      activeSlotsChange: _stringValue(_firstValue(stats, json, const [
        'occupancy_text',
        'active_slots_change',
        'activeSlotsChange',
      ]), fallback: 'Available'),
      pendingPayouts: _money(_firstValue(stats, json, const [
        'pending_payouts',
        'pendingPayouts',
        'payouts_pending',
      ])),
      pendingPayoutsChange: _stringValue(_firstValue(stats, json, const [
        'pending_payouts_change',
        'pendingPayoutsChange',
      ]), fallback: 'Processing'),
      activeTurfs: _stringValue(_firstValue(stats, json, const [
        'active_turfs',
        'activeTurfs',
        'turfs',
        'total_turfs',
      ]), fallback: '0'),
      recentBookings: _asList(bookingsValue)
          .map((item) => DashboardBooking.fromJson(_asMap(item)))
          .where((booking) => booking.customerName.isNotEmpty)
          .toList(),
      data: json,
    );
  }
}

class DashboardBooking {
  final String customerName;
  final String phone;
  final String turfName;
  final String date;
  final String time;
  final String amount;
  final String status;

  const DashboardBooking({
    required this.customerName,
    required this.phone,
    required this.turfName,
    required this.date,
    required this.time,
    required this.amount,
    required this.status,
  });

  String get initials {
    final parts = customerName
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'BK';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  factory DashboardBooking.fromJson(Map<String, dynamic> json) {
    final customer = _asMap(json['customer'] ?? json['user']);
    final turf = _asMap(json['turf']);

    return DashboardBooking(
      customerName: _stringValue(
        json['customer_name'] ?? json['customerName'] ?? customer['name'],
      ),
      phone: _stringValue(json['phone'] ?? customer['phone']),
      turfName: _stringValue(
        json['turf_name'] ?? json['turfName'] ?? turf['name'],
        fallback: 'Turf',
      ),
      date: _stringValue(json['date'] ?? json['booking_date']),
      time: _stringValue(
        json['time'] ??
            json['slot_time'] ??
            json['slotTime'] ??
            json['start_time'],
      ),
      amount: _money(json['amount'] ?? json['total'] ?? json['price']),
      status: _stringValue(json['status'], fallback: 'Confirmed'),
    );
  }
}

class OccupancyItem {
  final String name;
  final double value;
  final String percentLabel;

  const OccupancyItem({
    required this.name,
    required this.value,
    required this.percentLabel,
  });

  factory OccupancyItem.fromJson(Map<String, dynamic> json) {
    final bookedSlots = _asDouble(
      json['booked_slots'] ?? json['bookedSlots'] ?? json['occupied_slots'],
    );
    final totalSlots = _asDouble(
      json['total_slots'] ?? json['totalSlots'] ?? json['slots'],
    );
    final calculatedPercent =
        totalSlots > 0 ? (bookedSlots / totalSlots) * 100 : null;
    final percent = _asDouble(
      json['percentage'] ??
          json['percent'] ??
          json['occupancy'] ??
          json['occupancy_percentage'] ??
          json['value'] ??
          calculatedPercent,
    );
    final normalized = percent > 1 ? percent / 100 : percent;

    return OccupancyItem(
      name: _stringValue(
        json['name'] ?? json['turf_name'] ?? json['turfName'],
        fallback: 'Turf',
      ),
      value: normalized.clamp(0, 1).toDouble(),
      percentLabel: '${(normalized.clamp(0, 1) * 100).round()}%',
    );
  }
}

Map<String, dynamic> dashboardDataFromResponse(Object? value) {
  final root = _asMap(value);
  final data = _asMap(root['data']);
  if (data.isNotEmpty) return data;
  return root;
}

List<OccupancyItem> occupancyItemsFromResponse(Object? value) {
  final root = _asMap(value);
  final data = root['data'];
  final dataMap = _asMap(data);
  final list = data is List
      ? data
      : dataMap['occupancy'] ??
          dataMap['items'] ??
          dataMap['turfs'] ??
          root['occupancy'] ??
          root['items'] ??
          root['turfs'];
  return _asList(list)
      .map((item) => OccupancyItem.fromJson(_asMap(item)))
      .where((item) => item.name.isNotEmpty)
      .toList();
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

Object? _firstValue(
  Map<String, dynamic> primary,
  Map<String, dynamic> fallback,
  List<String> keys,
) {
  for (final key in keys) {
    if (primary[key] != null) return primary[key];
    if (fallback[key] != null) return fallback[key];
  }
  return null;
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

String _slots(Map<String, dynamic> stats, Map<String, dynamic> json) {
  final active = _firstValue(stats, json, const ['active_slots', 'activeSlots']);
  final total = _firstValue(stats, json, const ['total_slots', 'totalSlots']);
  if (active != null && total != null) return '${active.toString()}/${total.toString()}';
  return _stringValue(active, fallback: '0');
}

double _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
