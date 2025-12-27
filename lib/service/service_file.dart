import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileCtlService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 파일을 Firebase Storage에 업로드합니다.
  ///
  /// 경로 형식: users/{uid}/{folder}/{fileName}
  /// - uid: 사용자 고유 ID
  /// - folder: 페이지별 폴더명 (예: "posts", "images")
  /// - fileName: 파일명
  ///
  /// 웹과 모바일 플랫폼을 모두 지원합니다.
  /// - 웹: Uint8List 바이트 데이터 사용
  /// - 모바일: File 객체 사용
  Future<({bool success, String url})> fileUpload({
    required String uid,
    required String folder,
    File? file,
    Uint8List? bytes,
    String? fileName,
  }) async {
    try {
      final String fName = fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
      // 경로 형식: users/{uid}/{folder}/{fileName}
      final Reference ref = _storage.ref().child('users/$uid/$folder/$fName');

      UploadTask uploadTask;

      if (kIsWeb) {
        // 웹 플랫폼: 바이트 데이터 사용
        if (bytes == null) {
          return (success: false, url: '웹 플랫폼에서는 바이트 데이터가 필요합니다.');
        }
        uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        // 모바일 플랫폼: File 객체 사용
        if (file == null) {
          return (success: false, url: '모바일 플랫폼에서는 File 객체가 필요합니다.');
        }
        uploadTask = ref.putFile(file);
      }

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return (success: true, url: downloadUrl);
    } catch (e) {
      return (success: false, url: e.toString());
    }
  }

  Future<({bool success, String message, String? filePath})> fileDownload({
    required String downloadURL,
    String? fileName,
  }) async {
    try {
      // HTTP 요청으로 파일 다운로드
      final response = await http.get(Uri.parse(downloadURL));

      if (response.statusCode != 200) {
        return (
          success: false,
          message: '파일 다운로드 실패: HTTP ${response.statusCode}',
          filePath: null,
        );
      }

      // 파일명 결정
      String fName = fileName ?? path.basename(Uri.parse(downloadURL).path);

      // 파일명이 비어있으면 기본 파일명 사용
      if (fName.isEmpty) {
        fName = 'download_${DateTime.now().millisecondsSinceEpoch}';
      }

      // 저장 경로 가져오기
      final Directory directory = await getApplicationDocumentsDirectory();
      final String filePath = path.join(directory.path, fName);

      // 파일 저장
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      return (success: true, message: '파일 다운로드 완료', filePath: filePath);
    } catch (e) {
      return (success: false, message: '파일 다운로드 오류: ${e.toString()}', filePath: null);
    }
  }

  Future<({bool success, String message})> fileDelete({required String downloadURL}) async {
    try {
      // downloadURL에서 Reference 가져오기
      final Reference ref = _storage.refFromURL(downloadURL);
      await ref.delete();
      return (success: true, message: '파일이 삭제되었습니다.');
    } catch (e) {
      return (success: false, message: '파일 삭제 오류: ${e.toString()}');
    }
  }
}
