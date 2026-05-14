import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/dashboard_models.dart';

class DashboardService {
  Future<DashboardData> getDashboard() async {
    final response = await ApiClient.get(ApiConstants.dashboard);
    return DashboardData.fromJson(dashboardDataFromResponse(response.data));
  }

  Future<List<OccupancyItem>> getOccupancy() async {
    final response = await ApiClient.get(ApiConstants.occupancy);
    return occupancyItemsFromResponse(response.data);
  }
}
