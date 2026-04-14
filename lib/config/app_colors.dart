import 'package:flutter/material.dart';

/// Renewal SecureKeep 디자인 시스템 색상 팔레트
///
/// Stitch "Digital Sanctuary" 리뉴얼 디자인 적용
/// Primary: #0059b8 (진한 파란색)
class AppColors {
  // Primary Colors (Renewal)
  static const Color primary = Color(0xFF0059B8);           // #0059b8
  static const Color primaryDim = Color(0xFF004A99);        // darker variant
  static const Color onPrimary = Color(0xFFEFF2FF);         // #eff2ff
  static const Color primaryContainer = Color(0xFFD6E3FF);  // light blue
  static const Color onPrimaryContainer = Color(0xFF003876); // dark blue

  // Surface Colors (Renewal)
  /// Base Layer: 가장 넓은 배경 영역
  static const Color surface = Color(0xFFF5F6F7);           // #f5f6f7

  /// Paper Feel: 실제 메모 작성 영역 (최대 대비)
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // #ffffff

  /// Structural: 네비게이션 레일, 유틸리티 패널
  static const Color surfaceContainer = Color(0xFFE6E8EA);  // #e6e8ea

  static const Color surfaceContainerLow = Color(0xFFF0F2F4); // lighter
  static const Color surfaceContainerHigh = Color(0xFFDCDFE1); // mid-tone

  /// Selection: 선택된 항목 배경
  static const Color surfaceContainerHighest = Color(0xFFDADDDF); // #dadddf

  static const Color surfaceDim = Color(0xFFD1D5D7);        // #d1d5d7
  static const Color surfaceBright = Color(0xFFF5F6F7);     // same as surface
  static const Color surfaceTint = Color(0xFF0059B8);       // primary
  static const Color surfaceVariant = Color(0xFFE6E8EA);    // container

  // Text Colors (Renewal)
  /// Primary Text: 주요 텍스트
  static const Color onSurface = Color(0xFF2C2F30);         // #2c2f30

  /// Secondary Text: 보조 텍스트, 메타데이터
  static const Color onSurfaceVariant = Color(0xFF626567);  // mid-gray

  // Secondary Colors
  static const Color secondary = Color(0xFF5D5F65);         // neutral gray
  static const Color secondaryDim = Color(0xFF515359);      // darker gray
  static const Color onSecondary = Color(0xFFF8F8FF);       // light
  static const Color secondaryContainer = Color(0xFFE2E2E9); // light gray
  static const Color onSecondaryContainer = Color(0xFF505257); // dark gray

  // Tertiary Colors
  static const Color tertiary = Color(0xFF5D5C78);          // purple-gray
  static const Color tertiaryDim = Color(0xFF51516C);       // darker
  static const Color onTertiary = Color(0xFFFBF7FF);        // light
  static const Color tertiaryContainer = Color(0xFFD9D7F8); // light purple
  static const Color onTertiaryContainer = Color(0xFF4B4A65); // dark purple

  // Error Colors (Renewal)
  static const Color error = Color(0xFFB31B25);             // #b31b25
  static const Color errorDim = Color(0xFF8E1620);          // darker red
  static const Color onError = Color(0xFFFFFFFF);           // white
  static const Color errorContainer = Color(0xFFFCDAD9);    // light red
  static const Color onErrorContainer = Color(0xFF8E1620);  // dark red

  // Outline Colors
  /// 일반 아웃라인
  static const Color outline = Color(0xFF757778);           // #757778

  /// 아웃라인 변형 (Ghost Border 15% opacity 적용)
  static const Color outlineVariant = Color(0xFFABADAE);    // #abadae

  /// Ghost Border: 미묘한 경계선 (15% opacity)
  static Color get ghostBorder => outlineVariant.withValues(alpha: 0.15);

  // Inverse Colors (다크 모드 대비용)
  static const Color inverseSurface = Color(0xFF2C2F30);    // dark
  static const Color onInverseSurface = Color(0xFFF5F6F7);  // light
  static const Color inversePrimary = Color(0xFF85B4FF);    // light blue

  // Background Colors
  static const Color background = Color(0xFFF5F6F7);        // #f5f6f7
  static const Color onBackground = Color(0xFF2C2F30);      // #2c2f30

  // Glassmorphism (Renewal 스타일)
  /// PIN 입력 등에 사용되는 유리 효과
  /// 배경: white at 60% opacity + 12px backdrop blur
  static Color get glassSurface => const Color(0xFFFFFFFF).withValues(alpha: 0.6);

  // Gradient (Renewal CTA)
  /// Primary 버튼용 그라디언트
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDim],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glow Effect (Face-unlock)
  /// Face-unlock용 파란색 글로우 효과
  static Color get glowBlue => const Color(0xFF007DFF).withValues(alpha: 0.4);
}
