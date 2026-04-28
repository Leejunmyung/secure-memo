import 'package:flutter/material.dart';

/// SecureKeep 디자인 시스템 색상 팔레트
///
/// Toss 스타일 프리미엄 디자인 적용
/// Primary: #0a5c42 (딥 포레스트 그린)
class AppColors {
  // Primary Colors (Forest Green)
  static const Color primary = Color(0xFF0A5C42);           // #0a5c42
  static const Color primaryMid = Color(0xFF0E7A59);        // #0e7a59
  static const Color primaryLight = Color(0xFFE6F5F0);      // #e6f5f0
  static const Color primaryDim = Color(0xFFD0ECE4);        // #d0ece4
  static const Color onPrimary = Color(0xFFFFFFFF);         // white on primary
  static const Color primaryContainer = Color(0xFFE6F5F0);  // light green
  static const Color onPrimaryContainer = Color(0xFF0A5C42); // dark green

  // Surface Colors (Toss Style)
  /// Base Layer: 가장 넓은 배경 영역
  static const Color surface = Color(0xFFFFFFFF);           // #ffffff

  /// Secondary Background
  static const Color surfaceContainer = Color(0xFFF5F5F3);  // #f5f5f3

  /// Tertiary Background
  static const Color surfaceContainerHigh = Color(0xFFEEEEEB); // #eeeeeb

  /// Paper Feel: 실제 메모 작성 영역
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // #ffffff

  static const Color surfaceContainerLow = Color(0xFFF5F5F3);    // bg-2
  static const Color surfaceContainerHighest = Color(0xFFEEEEEB); // bg-3

  static const Color surfaceDim = Color(0xFFEEEEEB);        // #eeeeeb
  static const Color surfaceBright = Color(0xFFFFFFFF);     // #ffffff
  static const Color surfaceTint = Color(0xFF0A5C42);       // primary
  static const Color surfaceVariant = Color(0xFFF5F5F3);    // bg-2

  // Text Colors (High Contrast)
  /// Primary Text: 주요 텍스트
  static const Color onSurface = Color(0xFF111111);         // #111111 (t1)

  /// Secondary Text: 보조 텍스트, 메타데이터
  static const Color onSurfaceVariant = Color(0xFF555555);  // #555555 (t2)

  /// Tertiary Text: 비활성 텍스트
  static const Color onSurfaceTertiary = Color(0xFFAAAAAA); // #aaaaaa (t3)

  // Secondary Colors (Neutral Gray)
  static const Color secondary = Color(0xFF555555);         // t2
  static const Color secondaryDim = Color(0xFF333333);      // darker
  static const Color onSecondary = Color(0xFFFFFFFF);       // white
  static const Color secondaryContainer = Color(0xFFEEEEEB); // bg-3
  static const Color onSecondaryContainer = Color(0xFF111111); // t1

  // Tertiary Colors
  static const Color tertiary = Color(0xFF0E7A59);          // primary-mid
  static const Color tertiaryDim = Color(0xFF0A5C42);       // primary
  static const Color onTertiary = Color(0xFFFFFFFF);        // white
  static const Color tertiaryContainer = Color(0xFFD0ECE4); // primary-dim
  static const Color onTertiaryContainer = Color(0xFF0A5C42); // primary

  // Error Colors
  static const Color error = Color(0xFFB31B25);             // #b31b25
  static const Color errorDim = Color(0xFF8E1620);          // darker red
  static const Color onError = Color(0xFFFFFFFF);           // white
  static const Color errorContainer = Color(0xFFFCDAD9);    // light red
  static const Color onErrorContainer = Color(0xFF8E1620);  // dark red

  // Outline Colors
  /// 일반 아웃라인
  static const Color outline = Color(0xFF555555);           // #555555 (t2)

  /// 아웃라인 변형
  static const Color outlineVariant = Color(0xFFAAAAAA);    // #aaaaaa (t3)

  /// Ghost Border: 미묘한 경계선 (6% opacity)
  static Color get ghostBorder => const Color(0xFF000000).withValues(alpha: 0.06);

  // Inverse Colors (다크 모드 대비용)
  static const Color inverseSurface = Color(0xFF111111);    // t1
  static const Color onInverseSurface = Color(0xFFFFFFFF);  // white
  static const Color inversePrimary = Color(0xFFD0ECE4);    // primary-dim

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);        // #ffffff
  static const Color onBackground = Color(0xFF111111);      // #111111

  // Category Colors (카테고리별 색상 코딩)
  /// 금융 (Financial)
  static const Color categoryFinancialBg = Color(0xFFE8F0FF);    // #e8f0ff
  static const Color categoryFinancialText = Color(0xFF2952CC); // #2952cc

  /// 법률 (Legal)
  static const Color categoryLegalBg = Color(0xFFFFF3E0);       // #fff3e0
  static const Color categoryLegalText = Color(0xFFB05A00);    // #b05a00

  /// 개인 (Personal)
  static const Color categoryPersonalBg = Color(0xFFFCE8FF);    // #fce8ff
  static const Color categoryPersonalText = Color(0xFF7A1FA0); // #7a1fa0

  /// 의료 (Medical)
  static const Color categoryMedicalBg = Color(0xFFE8FFF2);     // #e8fff2
  static const Color categoryMedicalText = Color(0xFF0A6E3C);  // #0a6e3c

  /// 신분 (ID)
  static const Color categoryIdBg = Color(0xFFFFF0E8);          // #fff0e8
  static const Color categoryIdText = Color(0xFFC03A00);       // #c03a00

  /// 일반 (General) - 기본 카테고리
  static const Color categoryGeneralBg = Color(0xFFF5F5F3);     // bg-2
  static const Color categoryGeneralText = Color(0xFF555555);   // t2

  // Glassmorphism (PIN 입력 등)
  /// PIN 입력 등에 사용되는 유리 효과
  /// 배경: white at 92% opacity + 20px backdrop blur
  static Color get glassSurface => const Color(0xFFFFFFFF).withValues(alpha: 0.92);

  // Gradient (CTA 버튼용)
  /// Primary 버튼용 그라디언트
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow Effect
  /// Primary 글로우 효과
  static Color get glowPrimary => primary.withValues(alpha: 0.4);

  /// 카테고리별 색상 매핑 헬퍼 함수
  static Map<String, Color> getCategoryColors(String category) {
    final categoryLower = category.toLowerCase().trim();

    // 금융 관련 키워드
    if (categoryLower.contains('금융') ||
        categoryLower.contains('은행') ||
        categoryLower.contains('카드') ||
        categoryLower.contains('finance') ||
        categoryLower.contains('bank')) {
      return {'bg': categoryFinancialBg, 'text': categoryFinancialText};
    }

    // 법률 관련 키워드
    if (categoryLower.contains('법률') ||
        categoryLower.contains('계약') ||
        categoryLower.contains('legal') ||
        categoryLower.contains('contract')) {
      return {'bg': categoryLegalBg, 'text': categoryLegalText};
    }

    // 개인 관련 키워드
    if (categoryLower.contains('개인') ||
        categoryLower.contains('일기') ||
        categoryLower.contains('personal') ||
        categoryLower.contains('diary')) {
      return {'bg': categoryPersonalBg, 'text': categoryPersonalText};
    }

    // 의료 관련 키워드
    if (categoryLower.contains('의료') ||
        categoryLower.contains('건강') ||
        categoryLower.contains('병원') ||
        categoryLower.contains('medical') ||
        categoryLower.contains('health')) {
      return {'bg': categoryMedicalBg, 'text': categoryMedicalText};
    }

    // 신분 관련 키워드
    if (categoryLower.contains('신분') ||
        categoryLower.contains('주민') ||
        categoryLower.contains('여권') ||
        categoryLower.contains('id') ||
        categoryLower.contains('passport')) {
      return {'bg': categoryIdBg, 'text': categoryIdText};
    }

    // 기본 (일반)
    return {'bg': categoryGeneralBg, 'text': categoryGeneralText};
  }
}
