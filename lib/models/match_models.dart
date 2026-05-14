class MatchItem {
  final int? id;
  final String title;
  final String sport;
  final String turfName;
  final String date;
  final String time;
  final String players;
  final String feePerPlayer;
  final String status;

  const MatchItem({
    this.id,
    required this.title,
    required this.sport,
    required this.turfName,
    required this.date,
    required this.time,
    required this.players,
    required this.feePerPlayer,
    required this.status,
  });

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    final turf = _asMap(json['turf']);
    final joined = _stringValue(json['joined_players'] ?? json['joinedPlayers']);
    final max = _stringValue(json['max_players'] ?? json['maxPlayers']);

    return MatchItem(
      id: _asInt(json['id']),
      title: _stringValue(json['title'], fallback: 'Match'),
      sport: _stringValue(json['sport'], fallback: 'sport'),
      turfName: _stringValue(
        json['turf_name'] ?? json['turfName'] ?? turf['name'],
        fallback: 'Turf',
      ),
      date: _stringValue(json['date']),
      time: _timeRange(json),
      players: joined.isEmpty && max.isEmpty
          ? _stringValue(json['players'], fallback: '-')
          : '${joined.isEmpty ? '0' : joined}/${max.isEmpty ? '-' : max}',
      feePerPlayer: _money(json['fee_per_player'] ?? json['feePerPlayer']),
      status: _stringValue(json['status'], fallback: 'open'),
    );
  }
}

class CreateMatchRequest {
  final String title;
  final String sport;
  final int turfId;
  final String date;
  final String timeStart;
  final String timeEnd;
  final int maxPlayers;
  final num feePerPlayer;

  const CreateMatchRequest({
    required this.title,
    required this.sport,
    required this.turfId,
    required this.date,
    required this.timeStart,
    required this.timeEnd,
    required this.maxPlayers,
    required this.feePerPlayer,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'sport': sport.trim(),
      'turf_id': turfId,
      'date': date.trim(),
      'time_start': timeStart.trim(),
      'time_end': timeEnd.trim(),
      'max_players': maxPlayers,
      'fee_per_player': feePerPlayer,
    };
  }
}

class MatchesResponse {
  final List<MatchItem> matches;

  const MatchesResponse({required this.matches});

  factory MatchesResponse.fromJson(Object? value) {
    final root = _asMap(value);
    final data = root['data'];
    final list = data is List
        ? data
        : root['matches'] ?? root['items'] ?? _asMap(data)['matches'] ?? _asMap(data)['items'];

    return MatchesResponse(
      matches:
          _asList(list).map((item) => MatchItem.fromJson(_asMap(item))).toList(),
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

String _timeRange(Map<String, dynamic> json) {
  final direct = _stringValue(json['time']);
  if (direct.isNotEmpty) return direct;
  final start = _stringValue(json['time_start'] ?? json['timeStart']);
  final end = _stringValue(json['time_end'] ?? json['timeEnd']);
  return [start, end].where((part) => part.isNotEmpty).join(' - ');
}

String _money(Object? value) {
  final text = _stringValue(value, fallback: '0');
  if (text.startsWith('Rs') || text.startsWith('₹')) return text;
  return 'Rs $text';
}
