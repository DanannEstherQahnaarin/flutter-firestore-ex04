/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {setGlobalOptions} = require("firebase-functions");
const {onRequest} = require("firebase-functions/https");
const logger = require("firebase-functions/logger");

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
// 상단 import 부분을 v2용으로 확인하세요
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

if (admin.apps.length === 0) {
  admin.initializeApp();
}

// 매개변수를 (request) 하나로 변경합니다.
exports.incrementViewCount = onCall(async (request) => {
  
  // 로그에서 확인한 구조: data는 request.data 안에 있습니다.
  const postId = request.data.postId;

  console.log("Extracted postId:", postId);

  if (!postId) {
    throw new HttpsError('invalid-argument', 'postId가 전달되지 않았습니다.');
  }

  try {
    const db = admin.firestore();
    const postRef = db.collection('post_collection').doc(postId);

    // 원자적 증가 (Atomic Increment)
    await postRef.update({
      viewCount: admin.firestore.FieldValue.increment(1)
    });

    // 최신값 읽기
    const updatedDoc = await postRef.get();
    
    return {
      success: true,
      viewCount: updatedDoc.data().viewCount || 0,
      message: '조회수 증가 완료'
    };
  } catch (error) {
    console.error("Firestore Error:", error);
    throw new HttpsError('internal', error.message);
  }
});