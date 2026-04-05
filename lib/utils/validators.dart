/// 입력 검증 유틸리티
class Validators {
  /// 카드 번호 Luhn 알고리즘 검증
  ///
  /// 신용카드 번호 유효성 검증 (체크섬 알고리즘)
  static bool isValidCardNumber(String cardNumber) {
    // 공백 제거
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');

    // 숫자만 포함하는지 확인
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return false;
    }

    // 13-19자리 확인 (일반적인 카드 번호 길이)
    if (cleaned.length < 13 || cleaned.length > 19) {
      return false;
    }

    // Luhn 알고리즘
    int sum = 0;
    bool alternate = false;

    for (int i = cleaned.length - 1; i >= 0; i--) {
      int digit = int.parse(cleaned[i]);

      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// 만료일 포맷 검증 (MM/YY)
  ///
  /// 01/25, 12/30 등의 형식 확인
  static bool isValidExpiryDate(String expiryDate) {
    final pattern = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
    if (!pattern.hasMatch(expiryDate)) {
      return false;
    }

    final parts = expiryDate.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]) + 2000; // YY → YYYY

    final now = DateTime.now();
    final expiry = DateTime(year, month + 1, 0); // 해당 월의 마지막 날

    // 만료일이 현재보다 미래인지 확인
    return expiry.isAfter(now);
  }

  /// URL 포맷 검증
  ///
  /// http://, https:// 프로토콜 확인
  static bool isValidUrl(String url) {
    if (url.isEmpty) {
      return true; // 선택 필드이므로 빈 값 허용
    }

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 이메일 포맷 검증
  static bool isValidEmail(String email) {
    final pattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return pattern.hasMatch(email);
  }

  /// CVV 검증 (3-4자리 숫자)
  static bool isValidCvv(String cvv) {
    final pattern = RegExp(r'^\d{3,4}$');
    return pattern.hasMatch(cvv);
  }

  /// 빈 값 검증
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName을(를) 입력해주세요';
    }
    return null;
  }

  /// 최소 길이 검증
  static String? minLength(String? value, int length, String fieldName) {
    if (value == null || value.length < length) {
      return '$fieldName은(는) 최소 $length자 이상이어야 합니다';
    }
    return null;
  }

  /// 최대 길이 검증
  static String? maxLength(String? value, int length, String fieldName) {
    if (value != null && value.length > length) {
      return '$fieldName은(는) 최대 $length자까지 입력 가능합니다';
    }
    return null;
  }
}
