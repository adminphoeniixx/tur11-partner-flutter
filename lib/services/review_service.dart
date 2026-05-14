import '../core/api_client.dart';
import '../core/api_constants.dart';
import '../models/review_models.dart';

class ReviewService {
  Future<ReviewsResponse> getReviews() async {
    final response = await ApiClient.get(ApiConstants.reviews);
    return ReviewsResponse.fromJson(response.data);
  }

  Future<void> replyToReview(int reviewId, ReviewReplyRequest request) async {
    await ApiClient.post(
      '${ApiConstants.reviews}/$reviewId/reply',
      data: request.toJson(),
    );
  }
}
