import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Renewal SecureKeep 디자인 시스템 타이포그래피
///
/// Display & Headlines: Plus Jakarta Sans (Renewal)
/// Body & Labels: Inter (작은 크기에서도 뛰어난 가독성)
class AppTypography {
  // Display Styles (Plus Jakarta Sans)
  /// Display Large: 빈 상태(empty states)에 사용
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -1.14, // -2% tracking
        height: 1.12,
      );

  /// Display Medium: 주요 제목
  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.9,
        height: 1.16,
      );

  /// Display Small
  static TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.72,
        height: 1.22,
      );

  // Headline Styles (Plus Jakarta Sans)
  /// Headline Large
  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.64,
        height: 1.25,
      );

  /// Headline Medium
  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.56,
        height: 1.29,
      );

  /// Headline Small: 메모 제목에 사용
  static TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.48, // -2% tracking (locked in feel)
        height: 1.33,
      );

  // Title Styles (Plus Jakarta Sans)
  /// Title Large
  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
      );

  /// Title Medium
  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      );

  /// Title Small
  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      );

  // Body Styles (Inter)
  /// Body Large: 메모 본문
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      );

  /// Body Medium: 표준 본문 텍스트
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      );

  /// Body Small
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      );

  // Label Styles (Inter)
  /// Label Large
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      );

  /// Label Medium: 버튼 텍스트
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      );

  /// Label Small: 메타데이터 (날짜, 상태 등)
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      );

  // Special Styles
  /// Secure Vault Header: 암호화 상태 표시용 (watch face 느낌)
  static TextStyle get secureVaultHeader => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.0,
        height: 1.45,
      );
}
