/// 카드 정보 필드
///
/// 신용/체크카드 정보 저장용
class CardFields {
  final String cardholderName; // 카드 소유자
  final String cardNumber; // 카드 번호
  final String expiryDate; // 만료일 (MM/YY)
  final String cvv; // CVV/CVC
  final String? bankName; // 은행명 (선택)
  final String? notes; // 추가 메모 (선택)

  CardFields({
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    this.bankName,
    this.notes,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'cardholderName': cardholderName,
      'cardNumber': cardNumber,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'bankName': bankName,
      'notes': notes,
    };
  }

  /// JSON 역직렬화
  factory CardFields.fromJson(Map<String, dynamic> json) {
    return CardFields(
      cardholderName: json['cardholderName'] as String,
      cardNumber: json['cardNumber'] as String,
      expiryDate: json['expiryDate'] as String,
      cvv: json['cvv'] as String,
      bankName: json['bankName'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// 복사 메서드
  CardFields copyWith({
    String? cardholderName,
    String? cardNumber,
    String? expiryDate,
    String? cvv,
    String? bankName,
    String? notes,
  }) {
    return CardFields(
      cardholderName: cardholderName ?? this.cardholderName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      bankName: bankName ?? this.bankName,
      notes: notes ?? this.notes,
    );
  }

  /// 카드 번호 포맷팅 (1234 5678 9012 3456)
  String get formattedCardNumber {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }

  /// 카드 번호 마스킹 (**** **** **** 1234)
  String get maskedCardNumber {
    final cleaned = cardNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 4) return cleaned;
    final lastFour = cleaned.substring(cleaned.length - 4);
    return '**** **** **** $lastFour';
  }
}
