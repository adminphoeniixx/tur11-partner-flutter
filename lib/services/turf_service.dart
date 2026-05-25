import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/turf_models.dart';

class TurfService {
  Future<TurfListResponse> getTurfs() async {
    final response = await ApiClient.get(ApiConstants.turfs);
    return TurfListResponse.fromJson(response.data);
  }

  Future<void> createTurf(CreateTurfRequest request) async {
    await ApiClient.postForm(
      ApiConstants.turfs,
      await _multipart(
        request.toFields(),
        photos: request.photoPaths,
        videos: request.videoPaths,
      ),
    );
  }

  Future<void> updateTurf(int turfId, UpdateTurfRequest request) async {
    await ApiClient.put(ApiConstants.turf(turfId), data: request.toJson());
  }

  Future<TurfPricing> getPricing(int turfId) async {
    final response = await ApiClient.get(ApiConstants.turfPricing(turfId));
    return TurfPricing.fromJson(response.data);
  }

  Future<void> updatePricing(
    int turfId,
    UpdateTurfPricingRequest request,
  ) async {
    await ApiClient.put(
      ApiConstants.turfPricing(turfId),
      data: request.toJson(),
    );
  }

  Future<void> uploadMedia({
    required int turfId,
    List<String> photoPaths = const [],
    List<String> videoPaths = const [],
  }) async {
    await ApiClient.postForm(
      ApiConstants.turfUploadMedia(turfId),
      await _multipart(const {}, photos: photoPaths, videos: videoPaths),
    );
  }

  Future<void> removeMedia({
    required int turfId,
    required String url,
    required String type,
  }) async {
    await ApiClient.post(
      ApiConstants.turfRemoveMedia(turfId),
      data: {
        'url': url,
        'type': type,
      },
    );
  }

  Future<void> toggleStatus(int turfId) async {
    await ApiClient.post(ApiConstants.turfToggleStatus(turfId));
  }

  Future<FormData> _multipart(
    Map<String, dynamic> fields, {
    List<String> photos = const [],
    List<String> videos = const [],
  }) async {
    final form = FormData.fromMap(fields);
    for (var i = 0; i < photos.length; i++) {
      form.files.add(MapEntry(
        'photos[$i]',
        await MultipartFile.fromFile(photos[i]),
      ));
    }
    for (var i = 0; i < videos.length; i++) {
      form.files.add(MapEntry(
        'videos[$i]',
        await MultipartFile.fromFile(videos[i]),
      ));
    }
    return form;
  }
}
