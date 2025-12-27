import 'package:cloud_functions/cloud_functions.dart';

/// Cloud Functions를 호출하는 서비스 클래스
///
/// viewCount 증가와 같은 서버 측 작업을 안전하게 처리합니다.
class CloudFunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// 게시글 조회수를 안전하게 증가시킵니다.
  ///
  /// [postId] 증가시킬 게시글의 ID
  ///
  /// 반환값:
  /// - success: 성공 여부
  /// - viewCount: 업데이트된 조회수
  /// - message: 결과 메시지
  ///
  /// 예외:
  /// - FirebaseFunctionsException: Cloud Functions 호출 실패 시
  Future<({bool success, int viewCount, String message})> incrementViewCount(
    String postId,
  ) async {
    try {
      final callable = _functions.httpsCallable('incrementViewCount');
      final result = await callable.call({'postId': postId});

      final data = result.data as Map<String, dynamic>;

      return (
        success: data['success'] as bool? ?? false,
        viewCount: data['viewCount'] as int? ?? 0,
        message: data['message'] as String? ?? '조회수가 증가되었습니다.',
      );
    } on FirebaseFunctionsException catch (e) {
      return (success: false, viewCount: 0, message: '조회수 증가 실패: ${e.message ?? e.code}');
    } catch (e) {
      return (success: false, viewCount: 0, message: '조회수 증가 중 오류가 발생했습니다: $e');
    }
  }
}
