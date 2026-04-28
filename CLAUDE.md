# SecureKeep 개발 로그

**날짜**: 2026-04-28
**버전**: 1.1.0+2
**작업**: Toss 스타일 디자인 시스템 적용 + 사용자 정의 카테고리 기능 추가

---

## 📋 작업 개요

Claude Design에서 제작한 Toss 스타일 디자인을 Flutter 앱에 적용하고, 사용자 정의 카테고리 기능을 구현했습니다.

---

## 🎨 디자인 시스템 변경

### 색상
- **Primary**: `#0059B8` (Blue) → `#0A5C42` (Forest Green)
- **배경**: 화이트 기반 미니멀 (`#FFFFFF`, `#F5F5F3`, `#EEEEEB`)
- **텍스트**: `#111111`, `#555555`, `#AAAAAA` (더 진한 대비)

### 카테고리 색상 코딩
| 카테고리 | 키워드 예시 | 배경 | 텍스트 |
|---------|------------|------|--------|
| 금융 | 금융, 은행, 카드 | `#E8F0FF` | `#2952CC` |
| 법률 | 법률, 계약 | `#FFF3E0` | `#B05A00` |
| 개인 | 개인, 일기 | `#FCE8FF` | `#7A1FA0` |
| 의료 | 의료, 건강 | `#E8FFF2` | `#0A6E3C` |
| 신분 | 신분, 여권 | `#FFF0E8` | `#C03A00` |
| 일반 | (기본값) | `#F5F5F3` | `#555555` |

### 타이포그래피
- **제목**: Plus Jakarta Sans (굵게, 타이트한 자간)
- **본문**: Inter (가독성 최적화)

### Border Radius
`8px/16px/32px` → `12px/20px/28px/36px`

---

## ✨ 새로운 기능

### 사용자 정의 카테고리
```dart
// 메모 생성 시 카테고리 입력 (선택 사항)
await noteProvider.createNote(
  title: '회의록',
  payload: EncryptedPayload.general('내용...'),
  type: NoteType.general,
  category: '업무',  // 입력 안 하면 '일반'
);

// 자동 색상 매핑
final colors = AppColors.getCategoryColors('금융');
// → {bg: #E8F0FF, text: #2952CC}
```

**구현**:
- `Note` 모델에 `category` 필드 추가 (`@HiveField(9)`)
- 입력하지 않으면 자동으로 `'일반'` 할당
- 키워드 기반 자동 색상 매칭

---

## 🎯 UI 개선

### 메모 카드 (Toss 스타일)
```
┌───────────────────────────┐
│ [금융]          [아이콘]   │
│                           │
│ 국민은행 체크카드          │
│ 2026.04.28                │
└───────────────────────────┘
```

**변경사항**:
- 좌측 상단: 카테고리 badge (색상 코딩)
- 우측 상단: 타입 아이콘 (Primary Light 배경)
- 섬세한 이중 그림자로 깊이감 표현
- Border Radius: 28px

---

## 📂 변경된 파일

### 디자인 시스템
- `lib/config/app_colors.dart`: 색상 시스템 + 카테고리 색상 헬퍼
- `lib/config/app_typography.dart`: 타이포그래피 업데이트
- `lib/config/app_theme.dart`: Border Radius 조정

### 데이터 모델
- `lib/models/note.dart`: `category` 필드 추가
- `lib/models/note.g.dart`: Hive adapter (마이그레이션 호환성)

### 비즈니스 로직
- `lib/providers/note_provider.dart`: 카테고리 파라미터 추가

### UI
- `lib/widgets/note_card.dart`: Toss 스타일 재디자인
- `lib/screens/note/note_editor_screen.dart`: 카테고리 입력 필드

### 빌드
- `android/app/build.gradle.kts`: 패키지명 `com.example.secure_keep`으로 복원

---

## 🐛 해결한 오류

### 1. ClassNotFoundException: MainActivity
**원인**: 패키지명 불일치 (`kr.securekeep.app` vs `com.example.secure_keep`)
**해결**: `build.gradle.kts`를 원래 패키지명으로 복원

### 2. Hive 데이터 읽기 오류
**원인**: 기존 메모에 `category` 필드 없음
**해결**: `note.g.dart`에서 `fields[9] as String? ?? '일반'` 처리

### 3. 폰트 메서드 없음
**원인**: `GoogleFonts.notoSansKr()` 미지원
**해결**: Inter 폰트로 통일

### 4. 저장 공간 부족
**원인**: 에뮬레이터 저장 공간 부족
**해결**: 에뮬레이터 Wipe Data 또는 기존 앱 제거

---

## ✅ 빌드 결과

```bash
✓ Built build/app/outputs/flutter-apk/app-debug.apk
flutter analyze: 0 errors, 10 warnings (info only)
```

---

## 📱 사용자 가이드

### 카테고리 사용법
1. 메모 작성 시 카테고리 입력 (선택 사항)
2. 입력 안 하면 자동으로 '일반'
3. 키워드 감지로 자동 색상 매핑:
   - "금융" → 파란색
   - "법률" → 주황색
   - "개인" → 보라색
   - "의료" → 초록색
   - "신분" → 빨간색

---

## 🔮 향후 개선 사항

### 디자인
- [ ] 메모 편집 화면 Toss 스타일 적용
- [ ] 잠금 화면 Toss 스타일 적용
- [ ] 설정 화면 Toss 스타일 적용

### 기능
- [ ] 카테고리별 메모 필터링
- [ ] 카테고리 목록 보기
- [ ] 카테고리 이름 일괄 변경

### 스토어 배포
- [ ] 패키지명 변경 (`kr.securekeep.app`)
- [ ] 앱 아이콘 디자인
- [ ] 스크린샷 촬영
- [ ] 개인정보 처리방침

---

## 📚 참고

### 디자인 소스
- 핸드오프: `/tmp/secure-memo/project/SecureMemo Redesign.html`
- 대화 기록: `/tmp/secure-memo/chats/chat1.md`

### 주요 색상
```dart
primary: #0A5C42 (Forest Green)
primaryLight: #E6F5F0
onSurface: #111111
onSurfaceVariant: #555555
```

### 카테고리 색상 헬퍼
```dart
AppColors.getCategoryColors('금융')
// → {bg: Color(0xFFE8F0FF), text: Color(0xFF2952CC)}
```

---

## 🤝 기여

- **개발**: Claude Sonnet 4.5
- **디자인**: Claude Design (claude.ai/design)
- **기획**: @junmyung

---

**업데이트**: 2026-04-28 | **라이선스**: MIT
