import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/dashboard_models.dart';
import '../services/dashboard_service.dart';

class DashboardController extends ChangeNotifier {
  final DashboardService _dashboardService;

  DashboardController({DashboardService? dashboardService})
      : _dashboardService = dashboardService ?? DashboardService();

  bool _isLoading = false;
  String? _errorMessage;
  DashboardData? _dashboard;
  List<OccupancyItem> _occupancy = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DashboardData? get dashboard => _dashboard;
  List<OccupancyItem> get occupancy => _occupancy;

  Future<bool> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _dashboardService.getDashboard(),
        _dashboardService.getOccupancy(),
      ]);
      _dashboard = results[0] as DashboardData;
      _occupancy = results[1] as List<OccupancyItem>;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load dashboard. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
