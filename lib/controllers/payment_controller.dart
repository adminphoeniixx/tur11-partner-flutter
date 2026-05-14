import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/payment_models.dart';
import '../services/payment_service.dart';

class PaymentController extends ChangeNotifier {
  final PaymentService _paymentService;

  PaymentController({PaymentService? paymentService})
      : _paymentService = paymentService ?? PaymentService();

  bool _isLoading = false;
  String? _errorMessage;
  PayoutSummary _summary = const PayoutSummary();
  List<PayoutItem> _payouts = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PayoutSummary get summary => _summary;
  List<PayoutItem> get payouts => _payouts;

  Future<bool> load({String? status}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _paymentService.getPayoutSummary(),
        _paymentService.getPayouts(status: status),
      ]);
      _summary = results[0] as PayoutSummary;
      _payouts = (results[1] as PayoutListResponse).payouts;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load payments. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
