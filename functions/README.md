# Cloud Functions 설정 가이드

## 설치 및 배포

### 1. Node.js 설치 확인
```bash
node --version  # v18 이상 필요
```

### 2. Functions 폴더로 이동
```bash
cd functions
```

### 3. 의존성 설치
```bash
npm install
```

### 4. 로컬 테스트 (선택사항)
```bash
npm run serve
```

### 5. Firebase에 배포
```bash
npm run deploy
```

또는 프로젝트 루트에서:
```bash
firebase deploy --only functions
```

## 함수 설명

### incrementViewCount
게시글 조회수를 안전하게 증가시키는 함수입니다.

**보안 특징:**
- 서버 측에서 처리하여 클라이언트 조작 방지
- 파라미터 검증
- 문서 존재 확인
- 원자적 증가 연산 (FieldValue.increment)

**사용법:**
Flutter 앱에서 `CloudFunctionsService.incrementViewCount(postId)` 호출

## 보안 규칙

현재는 인증 없이도 호출 가능하도록 설정되어 있습니다.
인증이 필요한 경우 `functions/index.js`의 주석을 해제하세요.

