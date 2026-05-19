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
      date: _formatDate(_stringValue(json['date'])),
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

class UpdateStreamRequest {
  final String streamUrl;
  final String streamType;

  const UpdateStreamRequest({
    required this.streamUrl,
    required this.streamType,
  });

  Map<String, dynamic> toJson() {
    return {
      'stream_url': streamUrl.trim(),
      'stream_type': streamType.trim(),
    };
  }
}

class UpdateScoreboardRequest {
  final String teamAName;
  final String teamAScore;
  final String teamAOvers;
  final int? teamAWickets;
  final int? teamAGoals;
  final String teamBName;
  final String teamBScore;
  final String teamBOvers;
  final int? teamBWickets;
  final int? teamBGoals;
  final String? batting;
  final String? currentOver;
  final int? target;
  final double? currentRunRate;
  final double? requiredRunRate;
  final String? period;
  final String matchStatus;
  final String? result;

  const UpdateScoreboardRequest({
    required this.teamAName,
    this.teamAScore = '',
    this.teamAOvers = '',
    this.teamAWickets,
    this.teamAGoals,
    required this.teamBName,
    this.teamBScore = '',
    this.teamBOvers = '',
    this.teamBWickets,
    this.teamBGoals,
    this.batting,
    this.currentOver,
    this.target,
    this.currentRunRate,
    this.requiredRunRate,
    this.period,
    required this.matchStatus,
    this.result,
  });

  Map<String, dynamic> toJson() {
    final teamA = <String, dynamic>{'name': teamAName.trim()};
    final teamB = <String, dynamic>{'name': teamBName.trim()};

    void addIfPresent(Map<String, dynamic> map, String key, Object? value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      map[key] = value is String ? value.trim() : value;
    }

    addIfPresent(teamA, 'score', teamAScore);
    addIfPresent(teamA, 'overs', teamAOvers);
    addIfPresent(teamA, 'wickets', teamAWickets);
    addIfPresent(teamA, 'goals', teamAGoals);
    addIfPresent(teamB, 'score', teamBScore);
    addIfPresent(teamB, 'overs', teamBOvers);
    addIfPresent(teamB, 'wickets', teamBWickets);
    addIfPresent(teamB, 'goals', teamBGoals);

    return {
      'team_a': teamA,
      'team_b': teamB,
      if (batting != null && batting!.trim().isNotEmpty)
        'batting': batting!.trim(),
      if (currentOver != null && currentOver!.trim().isNotEmpty)
        'current_over': currentOver!.trim(),
      if (target != null) 'target': target,
      if (currentRunRate != null) 'current_run_rate': currentRunRate,
      if (requiredRunRate != null) 'required_run_rate': requiredRunRate,
      if (period != null && period!.trim().isNotEmpty) 'period': period!.trim(),
      'match_status': matchStatus.trim(),
      if (result != null && result!.trim().isNotEmpty) 'result': result!.trim(),
    };
  }
}

class AddCommentaryRequest {
  final String text;
  final String? over;
  final String? minute;
  final String eventType;
  final String? playerName;

  const AddCommentaryRequest({
    required this.text,
    this.over,
    this.minute,
    required this.eventType,
    this.playerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text.trim(),
      if (over != null && over!.trim().isNotEmpty) 'over': over!.trim(),
      if (minute != null && minute!.trim().isNotEmpty) 'minute': minute!.trim(),
      'event_type': eventType.trim(),
      if (playerName != null && playerName!.trim().isNotEmpty)
        'player_name': playerName!.trim(),
    };
  }
}

class MatchesResponse {
  final List<MatchItem> matches;

  const MatchesResponse({required this.matches});

  factory MatchesResponse.fromJson(Object? value) {
    final root = _asMap(value);
    final data = root['data'];
    final dataMap = _asMap(data);
    final list = _firstList([
      data,
      root['matches'],
      root['items'],
      dataMap['matches'],
      dataMap['items'],
      dataMap['data'],
    ]);

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

List<dynamic> _firstList(List<Object?> values) {
  for (final value in values) {
    final direct = _asList(value);
    if (direct.isNotEmpty) return direct;

    final map = _asMap(value);
    for (final key in const ['data', 'items', 'matches', 'results']) {
      final nested = _asList(map[key]);
      if (nested.isNotEmpty) return nested;

      final nestedMap = _asMap(map[key]);
      final paginated = _asList(nestedMap['data']);
      if (paginated.isNotEmpty) return paginated;
    }
  }
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
  if (direct.isNotEmpty) return _formatTimeRange(direct);
  final start = _stringValue(json['time_start'] ?? json['timeStart']);
  final end = _stringValue(json['time_end'] ?? json['timeEnd']);
  return [start, end]
      .where((part) => part.isNotEmpty)
      .map(_formatTime)
      .join(' - ');
}

String _money(Object? value) {
  final text = _stringValue(value, fallback: '0');
  if (text.startsWith('Rs') || text.startsWith('₹')) return text;
  return 'Rs $text';
}

String _formatDate(String value) {
  final text = value.trim();
  if (text.isEmpty) return '';
  final normalized = text.length >= 10 ? text.substring(0, 10) : text;
  final date = DateTime.tryParse(normalized);
  if (date == null) return text;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String _formatTimeRange(String value) {
  final parts = value.split(RegExp(r'\s*-\s*|\s+to\s+', caseSensitive: false));
  if (parts.length >= 2) return '${_formatTime(parts[0])} - ${_formatTime(parts[1])}';
  return _formatTime(value);
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
