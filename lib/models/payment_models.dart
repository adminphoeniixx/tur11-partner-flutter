class PayoutSummary {
  final String totalRevenue;
  final String totalRevenueChange;
  final String settled;
  final String settledChange;
  final String pending;
  final String pendingChange;
  final String platformFee;
  final String platformFeeChange;

  const PayoutSummary({
    this.totalRevenue = 'Rs 0',
    this.totalRevenueChange = 'Total',
    this.settled = 'Rs 0',
    this.settledChange = 'Settled',
    this.pending = 'Rs 0',
    this.pendingChange = 'Processing',
    this.platformFee = 'Rs 0',
    this.platformFeeChange = 'Deducted',
  });

  factory PayoutSummary.fromJson(Map<String, dynamic> json) {
    final data = _firstMap(json, const ['data', 'summary', 'stats']);
    final source = data.isEmpty ? json : {...json, ...data};

    return PayoutSummary(
      totalRevenue: _money(source['total_revenue'] ??
          source['totalRevenue'] ??
          source['revenue'] ??
          source['gross']),
      totalRevenueChange: _stringValue(
        source['total_revenue_change'] ?? source['totalRevenueChange'],
        fallback: 'Total',
      ),
      settled: _money(source['settled'] ??
          source['settled_amount'] ??
          source['settledAmount']),
      settledChange: _stringValue(
        source['settled_change'] ?? source['settledChange'],
        fallback: 'Settled',
      ),
      pending: _money(source['pending'] ??
          source['pending_amount'] ??
          source['pendingAmount']),
      pendingChange: _stringValue(
        source['pending_change'] ?? source['pendingChange'],
        fallback: 'Processing',
      ),
      platformFee: _money(source['platform_fee'] ??
          source['platformFee'] ??
          source['fee'] ??
          source['fees']),
      platformFeeChange: _stringValue(
        source['platform_fee_change'] ?? source['platformFeeChange'],
        fallback: 'Deducted',
      ),
    );
  }
}

class PayoutItem {
  final String id;
  final String type;
  final String name;
  final String amount;
  final String fee;
  final String net;
  final String date;
  final String status;

  const PayoutItem({
    required this.id,
    required this.type,
    required this.name,
    required this.amount,
    required this.fee,
    required this.net,
    required this.date,
    required this.status,
  });

  factory PayoutItem.fromJson(Map<String, dynamic> json) {
    final booking = _asMap(json['booking']);
    final customer = _asMap(json['customer'] ?? booking['customer']);

    return PayoutItem(
      id: _stringValue(
        json['transaction_id'] ??
            json['transactionId'] ??
            json['payout_id'] ??
            json['payoutId'] ??
            json['id'],
        fallback: '-',
      ),
      type: _stringValue(json['type'] ?? json['source'], fallback: 'Payout'),
      name: _stringValue(
        json['name'] ??
            json['customer_name'] ??
            customer['name'] ??
            booking['customer_name'],
        fallback: 'Customer',
      ),
      amount: _money(json['amount'] ?? json['gross_amount'] ?? json['gross']),
      fee: _fee(json['fee'] ?? json['platform_fee'] ?? json['platformFee']),
      net: _net(json),
      date: _stringValue(json['date'] ?? json['created_at'] ?? json['paid_at']),
      status: _stringValue(json['status'], fallback: 'pending'),
    );
  }
}

class PayoutListResponse {
  final List<PayoutItem> payouts;

  const PayoutListResponse({required this.payouts});

  factory PayoutListResponse.fromJson(Object? value) {
    final root = _asMap(value);
    final data = root['data'];
    final list = data is List
        ? data
        : root['payouts'] ??
            root['transactions'] ??
            root['items'] ??
            _asMap(data)['payouts'] ??
            _asMap(data)['transactions'] ??
            _asMap(data)['items'];

    return PayoutListResponse(
      payouts:
          _asList(list).map((item) => PayoutItem.fromJson(_asMap(item))).toList(),
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
  if (text == '-' || text.toLowerCase() == 'pending') return text;
  if (text.startsWith('Rs') || text.startsWith('₹') || text.startsWith('-Rs')) {
    return text;
  }
  return 'Rs $text';
}

String _fee(Object? value) {
  final text = _stringValue(value, fallback: '-');
  if (text == '-') return text;
  return _money(text);
}

String _net(Map<String, dynamic> json) {
  final value = json['net'] ??
      json['net_amount'] ??
      json['netAmount'] ??
      json['payout_amount'] ??
      json['payoutAmount'];
  final status = _stringValue(json['status']);
  if (value == null && status.toLowerCase().contains('pending')) {
    return 'Pending';
  }
  return _money(value);
}
