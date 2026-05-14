import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/payment_models.dart';

class PaymentService {
  Future<PayoutSummary> getPayoutSummary() async {
    final response = await ApiClient.get(ApiConstants.payoutSummary);
    final data = response.data;
    if (data is Map<String, dynamic>) return PayoutSummary.fromJson(data);
    if (data is Map) return PayoutSummary.fromJson(Map<String, dynamic>.from(data));
    return const PayoutSummary();
  }

  Future<PayoutListResponse> getPayouts({String? status}) async {
    final response = await ApiClient.get(
      ApiConstants.payouts,
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return PayoutListResponse.fromJson(response.data);
  }
}
