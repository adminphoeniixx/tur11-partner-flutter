import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/slot_models.dart';

class SlotService {
  Future<SlotsResponse> getSlots({
    required int turfId,
    required String date,
  }) async {
    final response = await ApiClient.get(
      ApiConstants.slots,
      queryParameters: {
        'turf_id': turfId,
        'date': date,
      },
    );
    return SlotsResponse.fromJson(response.data);
  }

  Future<void> generateSlots(GenerateSlotsRequest request) async {
    await ApiClient.post(ApiConstants.generateSlots, data: request.toJson());
  }

  Future<void> blockSlots({
    required List<int> slotIds,
    required String reason,
  }) async {
    await ApiClient.post(
      ApiConstants.blockSlots,
      data: {
        'slot_ids': slotIds,
        'reason': reason,
      },
    );
  }

  Future<void> unblockSlots(List<int> slotIds) async {
    await ApiClient.post(
      ApiConstants.unblockSlots,
      data: {'slot_ids': slotIds},
    );
  }

  Future<void> updateSlotPrice({
    required List<int> slotIds,
    required num price,
  }) async {
    await ApiClient.post(
      ApiConstants.updateSlotPrice,
      data: {
        'slot_ids': slotIds,
        'price': price,
      },
    );
  }
}
