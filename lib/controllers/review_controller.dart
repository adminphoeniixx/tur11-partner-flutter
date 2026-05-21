import '../core/api_client.dart';
import '../models/review_models.dart';
import '../services/review_service.dart';
import 'safe_change_notifier.dart';

class ReviewController extends SafeChangeNotifier {
  final ReviewService _reviewService;

  ReviewController({ReviewService? reviewService})
      : _reviewService = reviewService ?? ReviewService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<ReviewItem> _reviews = const [];
  ReviewSummary _summary = const ReviewSummary();

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<ReviewItem> get reviews => _reviews;
  ReviewSummary get summary => _summary;
  List<ReviewItem> get turfReviews =>
      _reviews.where((review) => !review.type.toLowerCase().contains('tournament')).toList();
  List<ReviewItem> get tournamentReviews =>
      _reviews.where((review) => review.type.toLowerCase().contains('tournament')).toList();

  Future<bool> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _reviewService.getReviews();
      if (isDisposed) return false;
      _reviews = response.reviews;
      _summary = response.summary;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to load reviews. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> replyToReview(int reviewId, String reply) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _reviewService.replyToReview(
        reviewId,
        ReviewReplyRequest(reply: reply),
      );
      if (isDisposed) return false;
      await load();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to reply to review. Please try again.';
      return false;
    } finally {
      if (!isDisposed) {
        _isSaving = false;
        notifyListeners();
      }
    }
  }
}
