import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileCtlService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<({bool success, String url})> fileUpload({
    required File file,
    String? fileName,
  }) async {
    try {
      final String fName = fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
      final Reference ref = _storage.ref().child('posts/$fName');
      final UploadTask uploadTask = ref.putFile(file);
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
}
