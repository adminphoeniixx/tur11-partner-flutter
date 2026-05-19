import 'review_models.dart';

class TournamentItem {
  final int? id;
  final String name;
  final String sport;
  final String format;
  final String tournamentFormat;
  final int? turfId;
  final String turfName;
  final String city;
  final String startDate;
  final String endDate;
  final int maxTeams;
  final int registeredTeams;
  final String entryFee;
  final String prizeTotal;
  final String revenue;
  final String status;
  final String description;
  final Map<String, dynamic> data;

  const TournamentItem({
    required this.id,
    required this.name,
    required this.sport,
    required this.format,
    required this.tournamentFormat,
    required this.turfId,
    required this.turfName,
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.maxTeams,
    required this.registeredTeams,
    required this.entryFee,
    required this.prizeTotal,
    required this.revenue,
    required this.status,
    required this.description,
    this.data = const {},
  });

  factory TournamentItem.fromJson(Map<String, dynamic> json) {
    final turf = _asMap(json['turf']);
    final stats = _asMap(json['stats'] ?? json['summary']);
    return TournamentItem(
      id: _intValue(json['id'] ?? json['tournament_id']),
      name: _stringValue(json['name'] ?? json['title'],
          fallback: 'Tournament'),
      sport: _stringValue(json['sport'], fallback: 'cricket'),
      format: _stringValue(json['format'], fallback: '-'),
      tournamentFormat:
          _stringValue(json['tournament_format'] ?? json['tournamentFormat']),
      turfId: _intValue(json['turf_id'] ?? turf['id']),
      turfName: _stringValue(
        json['turf_name'] ?? json['venue'] ?? turf['name'],
        fallback: 'Venue',
      ),
      city: _stringValue(json['city'] ?? turf['city']),
      startDate: _stringValue(json['start_date'] ?? json['startDate']),
      endDate: _stringValue(json['end_date'] ?? json['endDate']),
      maxTeams:
          _intValue(json['max_teams'] ?? json['maxTeams']) ?? 0,
      registeredTeams: _intValue(
            json['registered_teams'] ??
                json['teams_count'] ??
                json['team_count'] ??
                stats['registered_teams'] ??
                stats['teams'],
          ) ??
          0,
      entryFee: _money(json['entry_fee'] ?? json['entryFee']),
      prizeTotal: _money(
        json['prize_total'] ?? json['prizeTotal'] ?? json['prize'],
      ),
      revenue: _money(json['revenue'] ?? stats['revenue']),
      status: _stringValue(json['status'], fallback: 'upcoming'),
      description: _stringValue(json['description']),
      data: json,
    );
  }

  String get datesLabel {
    if (startDate.isEmpty && endDate.isEmpty) return '-';
    final start = _formatDate(startDate);
    final end = _formatDate(endDate);
    if (endDate.isEmpty || startDate == endDate) return start;
    return '$start - $end';
  }

  String get startDateLabel => _formatDate(startDate);

  String get teamsLabel => '$registeredTeams/$maxTeams';

  double get registrationProgress {
    if (maxTeams <= 0) return 0;
    return (registeredTeams / maxTeams).clamp(0, 1).toDouble();
  }
}

class TournamentTeamItem {
  final int? id;
  final String teamName;
  final String captainName;
  final String phone;
  final String players;
  final String fee;
  final String status;
  final Map<String, dynamic> data;

  const TournamentTeamItem({
    required this.id,
    required this.teamName,
    required this.captainName,
    required this.phone,
    required this.players,
    required this.fee,
    required this.status,
    this.data = const {},
  });

  factory TournamentTeamItem.fromJson(Map<String, dynamic> json) {
    final captain = _asMap(json['captain'] ?? json['user']);
    return TournamentTeamItem(
      id: _intValue(json['id'] ?? json['team_id']),
      teamName: _stringValue(
        json['team_name'] ?? json['teamName'] ?? json['name'],
        fallback: 'Team',
      ),
      captainName: _stringValue(
        json['captain_name'] ?? json['captainName'] ?? captain['name'],
        fallback: 'Captain',
      ),
      phone: _stringValue(json['phone'] ?? captain['phone']),
      players: _stringValue(
        json['players'] ?? json['players_count'] ?? json['player_count'],
        fallback: '0',
      ),
      fee: _money(json['fee'] ?? json['entry_fee'] ?? json['amount']),
      status: _stringValue(json['status'] ?? json['payment_status'],
          fallback: 'registered'),
      data: json,
    );
  }
}

class TournamentsResponse {
  final List<TournamentItem> tournaments;

  const TournamentsResponse({required this.tournaments});

  factory TournamentsResponse.fromJson(Object? value) {
    final root = _asMap(value);
    final data = root['data'];
    final dataMap = _asMap(data);
    final list = _firstList([
      data,
      root['tournaments'],
      root['items'],
      dataMap['tournaments'],
      dataMap['items'],
      dataMap['data'],
    ]);
    return TournamentsResponse(
      tournaments: _asList(list)
          .map((item) => TournamentItem.fromJson(_asMap(item)))
          .toList(),
    );
  }
}

class TournamentTeamsResponse {
  final List<TournamentTeamItem> teams;

  const TournamentTeamsResponse({required this.teams});

  factory TournamentTeamsResponse.fromJson(Object? value) {
    final root = _asMap(value);
    final data = root['data'];
    final dataMap = _asMap(data);
    final list = _firstList([
      data,
      root['teams'],
      root['registrations'],
      root['items'],
      dataMap['teams'],
      dataMap['registrations'],
      dataMap['items'],
      dataMap['data'],
    ]);
    return TournamentTeamsResponse(
      teams: _asList(list)
          .map((item) => TournamentTeamItem.fromJson(_asMap(item)))
          .toList(),
    );
  }
}

class CreateTournamentRequest {
  final String name;
  final String sport;
  final String format;
  final String tournamentFormat;
  final int turfId;
  final String city;
  final String startDate;
  final String endDate;
  final int maxTeams;
  final num entryFee;
  final num prizeTotal;
  final String description;

  const CreateTournamentRequest({
    required this.name,
    required this.sport,
    required this.format,
    required this.tournamentFormat,
    required this.turfId,
    required this.city,
    required this.startDate,
    required this.endDate,
    required this.maxTeams,
    required this.entryFee,
    required this.prizeTotal,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sport': sport,
      'format': format,
      'tournament_format': tournamentFormat,
      'turf_id': turfId,
      'city': city,
      'start_date': startDate,
      'end_date': endDate,
      'max_teams': maxTeams,
      'entry_fee': entryFee,
      'prize_total': prizeTotal,
      'description': description,
    };
  }
}

class RecordTournamentResultRequest {
  final int matchNo;
  final String scoreA;
  final String oversA;
  final String scoreB;
  final String oversB;
  final int winnerId;
  final String winnerName;
  final String resultText;

  const RecordTournamentResultRequest({
    required this.matchNo,
    required this.scoreA,
    required this.oversA,
    required this.scoreB,
    required this.oversB,
    required this.winnerId,
    required this.winnerName,
    required this.resultText,
  });

  Map<String, dynamic> toJson() {
    return {
      'match_no': matchNo,
      'score_a': scoreA,
      'overs_a': oversA,
      'score_b': scoreB,
      'overs_b': oversB,
      'winner_id': winnerId,
      'winner_name': winnerName,
      'result_text': resultText,
    };
  }
}

class CompleteTournamentRequest {
  final int winnerTeamId;
  final String winnerName;
  final int runnerTeamId;
  final String runnerName;

  const CompleteTournamentRequest({
    required this.winnerTeamId,
    required this.winnerName,
    required this.runnerTeamId,
    required this.runnerName,
  });

  Map<String, dynamic> toJson() {
    return {
      'winner_team_id': winnerTeamId,
      'winner_name': winnerName,
      'runner_team_id': runnerTeamId,
      'runner_name': runnerName,
    };
  }
}

typedef TournamentReviewsResponse = ReviewsResponse;

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
    for (final key in const [
      'data',
      'items',
      'tournaments',
      'teams',
      'registrations',
      'results',
    ]) {
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

String _money(Object? value) {
  final text = _stringValue(value, fallback: '0');
  if (text.startsWith('Rs') || text.startsWith('₹')) return text;
  return 'Rs $text';
}

int? _intValue(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String _formatDate(String value) {
  final text = value.trim();
  if (text.isEmpty) return '-';
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
