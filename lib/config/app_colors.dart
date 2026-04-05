import 'package:flutter/material.dart';

/// Stitch "The Sovereign Vault" 디자인 시스템 색상 팔레트
///
/// 이 색상들은 Notion의 Stitch 프로젝트에서 정의된 디자인 시스템을 기반으로 합니다.
/// Deep Navy (#0A192F)를 primary 색상으로 사용하여 신뢰감과 전문성을 표현합니다.
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF515F78);           // #515f78
  static const Color primaryDim = Color(0xFF45536C);        // #45536c
  static const Color onPrimary = Color(0xFFF6F7FF);         // #f6f7ff
  static const Color primaryContainer = Color(0xFFD6E3FF);  // #d6e3ff
  static const Color onPrimaryContainer = Color(0xFF44526B); // #44526b

  // Surface Colors (No-Line 규칙 적용)
  /// Base Layer: 가장 넓은 배경 영역
  static const Color surface = Color(0xFFF7F9FC);           // #f7f9fc

  /// Paper Feel: 실제 메모 작성 영역 (최대 대비)
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // #ffffff

  /// Structural: 네비게이션 레일, 유틸리티 패널
  static const Color surfaceContainer = Color(0xFFE8EFF4);  // #e8eff4

  static const Color surfaceContainerLow = Color(0xFFF0F4F8); // #f0f4f8
  static const Color surfaceContainerHigh = Color(0xFFE1E9F0); // #e1e9f0

  /// Selection: 선택된 항목 배경
  static const Color surfaceContainerHighest = Color(0xFFD9E4EC); // #d9e4ec

  static const Color surfaceDim = Color(0xFFCFDCE5);        // #cfdce5
  static const Color surfaceBright = Color(0xFFF7F9FC);     // #f7f9fc
  static const Color surfaceTint = Color(0xFF515F78);       // #515f78
  static const Color surfaceVariant = Color(0xFFD9E4EC);    // #d9e4ec

  // Text Colors (No pure black)
  /// Primary Text: 주요 텍스트 (#000000 대신 사용)
  static const Color onSurface = Color(0xFF29343A);         // #29343a

  /// Secondary Text: 보조 텍스트, 메타데이터
  static const Color onSurfaceVariant = Color(0xFF566168);  // #566168

  // Secondary Colors
  static const Color secondary = Color(0xFF5D5F65);         // #5d5f65
  static const Color secondaryDim = Color(0xFF515359);      // #515359
  static const Color onSecondary = Color(0xFFF8F8FF);       // #f8f8ff
  static const Color secondaryContainer = Color(0xFFE2E2E9); // #e2e2e9
  static const Color onSecondaryContainer = Color(0xFF505257); // #505257

  // Tertiary Colors
  static const Color tertiary = Color(0xFF5D5C78);          // #5d5c78
  static const Color tertiaryDim = Color(0xFF51516C);       // #51516c
  static const Color onTertiary = Color(0xFFFBF7FF);        // #fbf7ff
  static const Color tertiaryContainer = Color(0xFFD9D7F8); // #d9d7f8
  static const Color onTertiaryContainer = Color(0xFF4B4A65); // #4b4a65

  // Error Colors
  static const Color error = Color(0xFF9F403D);             // #9f403d
  static const Color errorDim = Color(0xFF4E0309);          // #4e0309
  static const Color onError = Color(0xFFFFF7F6);           // #fff7f6
  static const Color errorContainer = Color(0xFFFE8983);    // #fe8983
  static const Color onErrorContainer = Color(0xFF752121);  // #752121

  // Outline Colors
  /// 일반 아웃라인
  static const Color outline = Color(0xFF717C84);           // #717c84

  /// 아웃라인 변형 (Ghost Border 15% opacity 적용)
  static const Color outlineVariant = Color(0xFFA8B3BB);    // #a8b3bb

  /// Ghost Border: 미묘한 경계선 (15% opacity)
  static Color get ghostBorder => outlineVariant.withValues(alpha: 0.15);

  // Inverse Colors (다크 모드 대비용)
  static const Color inverseSurface = Color(0xFF0B0F11);    // #0b0f11
  static const Color onInverseSurface = Color(0xFF9A9DA0);  // #9a9da0
  static const Color inversePrimary = Color(0xFFC7D5F3);    // #c7d5f3

  // Background Colors
  static const Color background = Color(0xFFF7F9FC);        // #f7f9fc
  static const Color onBackground = Color(0xFF29343A);      // #29343a

  // Glassmorphism
  /// 플로팅 요소 (명령 팔레트, 컨텍스트 메뉴)에 사용
  /// 배경: surfaceContainerLow at 80% opacity + 20px backdrop blur
  static Color get glassSurface => surfaceContainerLow.withValues(alpha: 0.8);

  // Gradient (Signature CTA)
  /// Primary 버튼용 그라디언트 (metallic sheen 효과)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDim],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
