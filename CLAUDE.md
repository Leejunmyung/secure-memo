# SecureKeep 개발 로그

**날짜**: 2026-04-28
**버전**: 1.2.0+3
**작업**: 자유 포맷 메모 시스템 + Toss 스타일 UI/UX 완전 적용

---

## 📋 작업 개요

Claude Design 프로토타입을 기반으로 앱 구조를 자유 포맷 메모 시스템으로 전환하고, Toss 스타일 UI/UX를 완전히 적용했습니다.

### 주요 변경사항
1. **메모 타입 시스템 제거**: 일반/계정/카드 → 단일 자유 포맷
2. **홈 화면 재디자인**: 검색바 + 카테고리 필터 칩 추가
3. **메모 편집 화면 재디자인**: Toss 스타일 섹션 레이블 + 카테고리 칩
4. **사용자 정의 카테고리**: 자유 입력 + 추천 카테고리 칩

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

### 1. 자유 포맷 메모 시스템
**이전**: 3가지 타입 (일반/계정/카드) 별도 관리
**현재**: 단일 자유 포맷으로 통합

```dart
// 모든 메모는 NoteType.general로 통일
await noteProvider.createNote(
  title: '비밀번호 메모',
  payload: EncryptedPayload.general('ID: admin\nPW: ****'),
  // type 생략 가능 (기본값 general)
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

## 🎯 UI/UX 완전 개편

### 홈 화면 (Toss 스타일)
```
┌─────────────────────────────────────┐
│ 안녕하세요 👋          [⚙️]         │
│ 보안 기록                            │
│ 5개의 암호화된 메모                   │
│                                     │
│ [🔍] 메모 검색...                   │
│                                     │
│ [전체] [금융] [법률] [개인] [의료]   │
│                                     │
│ ┌─────────────────────────────┐   │
│ │ [금융]          [💳]         │   │
│ │ 국민은행 체크카드              │   │
│ │ 주요 결제 수단...             │   │
│ │ 2026.04.28 업데이트           │   │
│ └─────────────────────────────┘   │
│                                     │
│                              [+]    │
└─────────────────────────────────────┘
```

**새로 추가된 요소**:
- 인라인 검색바 (실시간 필터링)
- 카테고리 필터 칩 (전체, 금융, 법률, 개인, 의료, 신분, 일반)
- Toss 스타일 헤더 (인사말 + 통계)
- 타입 선택 바텀시트 제거 → 단일 FAB로 직접 편집

### 메모 편집 화면 (Toss 스타일)
```
┌─────────────────────────────────────┐
│ [← 취소]    새 메모         [저장]   │
│                                     │
│ 제목                                │
│ 메모 제목을 입력하세요               │
│                                     │
│ 카테고리                            │
│ 입력하지 않으면 '일반'               │
│ [금융] [법률] [개인] [의료] [신분]  │
│                                     │
│ 내용                                │
│ 자유롭게 내용을 입력하세요...        │
│ 계정 정보, 카드 번호, 비밀번호 등    │
│ 어떤 내용이든 안전하게 암호화됩니다.  │
│                                     │
└─────────────────────────────────────┘
```

**변경사항**:
- 섹션 레이블 (제목/카테고리/내용)
- 추천 카테고리 칩 (빠른 선택)
- 단순화된 AppBar (Toss 스타일 버튼)
- 암호화 상태 헤더 제거 (더 깔끔한 UI)

---

## 📂 변경된 파일 (v1.2.0)

### 데이터 모델
- `lib/models/note.dart`: `type` 필드를 optional로 변경 (기본값: general)
- `lib/models/note.g.dart`: Hive adapter 재생성

### 비즈니스 로직
- `lib/providers/note_provider.dart`: `type` 파라미터 optional로 변경

### UI - 홈 화면
- `lib/screens/home/home_screen.dart`: **완전 재작성**
  - StatefulWidget으로 전환 (검색/필터 상태 관리)
  - 인라인 검색바 추가
  - 카테고리 필터 칩 추가
  - CustomScrollView로 스크롤 최적화
  - 타입 선택 바텀시트 제거
  - 타입별 화면 분기 로직 제거 (모두 NoteEditorScreen으로 통합)

### UI - 편집 화면
- `lib/screens/note/note_editor_screen.dart`: Toss 스타일 적용
  - AppBar 재디자인 (← 취소, 저장 버튼)
  - 섹션 레이블 추가 (제목/카테고리/내용)
  - 추천 카테고리 칩 추가
  - 암호화 상태 헤더 제거
  - 다중 줄 힌트 텍스트

### 기존 파일 (v1.1.0에서 변경)
- `lib/config/app_colors.dart`: Forest Green + 카테고리 색상
- `lib/config/app_typography.dart`: Plus Jakarta Sans + Inter
- `lib/widgets/note_card.dart`: Toss 스타일 카드

---

## 🔄 하위 호환성

### 기존 데이터 보존
- `NoteType` enum은 유지 (기존 데이터와 호환)
- 모든 기존 메모는 정상적으로 로드 가능
- 새 메모는 자동으로 `NoteType.general` 할당
- UI는 타입을 무시하고 모든 메모를 동일하게 처리

### 마이그레이션 불필요
- 데이터베이스 스키마 변경 없음
- 기존 사용자는 앱 업데이트만으로 사용 가능
- 타입별 화면 (AccountFormScreen, CardFormScreen)은 아직 남아있지만 접근 불가

## 🐛 해결한 오류 (v1.1.0)

### 1. ClassNotFoundException: MainActivity
**원인**: 패키지명 불일치
**해결**: `build.gradle.kts` 복원

### 2. Hive 카테고리 필드 읽기 오류
**원인**: 기존 메모에 `category` 필드 없음
**해결**: `fields[9] as String? ?? '일반'` 처리

### 3. 폰트 메서드 없음
**원인**: `GoogleFonts.notoSansKr()` 미지원
**해결**: Inter 폰트로 통일

---

## ✅ 빌드 결과 (v1.2.0)

```bash
✓ Built build/app/outputs/flutter-apk/app-debug.apk (19.5s)
flutter analyze: 0 errors, 10 info (deprecated warnings)
```

**분석 결과**:
- 컴파일 에러: 0
- 경고: 0
- Info: 10 (deprecated API 사용, print 문 등 - 프로덕션 영향 없음)

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
- [x] 메모 편집 화면 Toss 스타일 적용 ✅
- [x] 홈 화면 Toss 스타일 적용 (검색바 + 카테고리 칩) ✅
- [ ] 메모 상세 화면 Toss 스타일 적용
- [ ] 잠금 화면 Toss 스타일 적용
- [ ] 설정 화면 Toss 스타일 적용

### 기능
- [x] 카테고리별 메모 필터링 ✅
- [x] 검색 기능 (제목 + 카테고리) ✅
- [ ] 메모 미리보기 추가 (복호화 없이 일부 내용 표시)
- [ ] 카테고리 통계 화면
- [ ] 즐겨찾기 필터

### 코드 정리
- [ ] 타입별 화면 완전 제거 (AccountFormScreen, CardFormScreen)
- [ ] NoteType enum deprecation 고려
- [ ] 사용하지 않는 import 정리

### 스토어 배포
- [ ] 패키지명 변경 (`kr.securekeep.app`)
- [ ] 앱 아이콘 디자인
- [ ] 스크린샷 촬영 (새 UI)
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
