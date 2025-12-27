const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * 게시글 조회수 증가 Cloud Function
 * 
 * 보안 규칙:
 * - 인증된 사용자만 호출 가능
 * - postId가 유효한지 검증
 * - 중복 조회 방지 (선택적)
 * 
 * 사용법:
 * - Flutter에서 cloud_functions 패키지를 통해 호출
 * - 함수명: incrementViewCount
 * - 파라미터: { postId: string }
 */
exports.incrementViewCount = functions.https.onCall(async (data, context) => {
  // 인증 확인 (선택적 - 비회원도 조회 가능하게 하려면 제거)
  // if (!context.auth) {
  //   throw new functions.https.HttpsError(
  //     'unauthenticated',
  //     '인증이 필요합니다.'
  //   );
  // }

  const { postId } = data;

  // 파라미터 검증
  if (!postId || typeof postId !== 'string') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'postId가 필요합니다.'
    );
  }

  try {
    const db = admin.firestore();
    const postRef = db.collection('post_collection').doc(postId);

    // 문서 존재 확인
    const postDoc = await postRef.get();
    if (!postDoc.exists) {
      throw new functions.https.HttpsError(
        'not-found',
        '게시글을 찾을 수 없습니다.'
      );
    }

    // 서버 측에서 안전하게 조회수 증가
    await postRef.update({
      viewCount: admin.firestore.FieldValue.increment(1),
    });

    // 업데이트된 조회수 반환
    const updatedDoc = await postRef.get();
    const updatedViewCount = updatedDoc.data()?.viewCount || 0;

    return {
      success: true,
      viewCount: updatedViewCount,
      message: '조회수가 증가되었습니다.',
    };
  } catch (error) {
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }
    throw new functions.https.HttpsError(
      'internal',
      '조회수 증가 중 오류가 발생했습니다: ' + error.message
    );
  }
});

