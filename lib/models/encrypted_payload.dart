import 'dart:convert';

/// 암호화 페이로드
///
/// 암호화되기 전의 원본 데이터 구조
class EncryptedPayload {
  /// 메모 내용 (일반 메모의 경우)
  final String? content;

  /// 추가 필드 (계정 정보, 카드 정보 등)
  final Map<String, dynamic>? fields;

  const EncryptedPayload({
    this.content,
    this.fields,
  });

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      if (content != null) 'content': content,
      if (fields != null) 'fields': fields,
    };
  }

  /// JSON에서 역직렬화
  factory EncryptedPayload.fromJson(Map<String, dynamic> json) {
    return EncryptedPayload(
      content: json['content'] as String?,
      fields: json['fields'] as Map<String, dynamic>?,
    );
  }

  /// JSON 문자열로 직렬화
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// JSON 문자열에서 역직렬화
  factory EncryptedPayload.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return EncryptedPayload.fromJson(json);
  }

  /// 일반 메모용 생성자
  factory EncryptedPayload.general(String content) {
    return EncryptedPayload(content: content);
  }

  /// 계정 정보용 생성자
  factory EncryptedPayload.account({
    required String serviceName,
    required String username,
    required String password,
    String? url,
    String? notes,
  }) {
    return EncryptedPayload(
      fields: {
        'serviceName': serviceName,
        'username': username,
        'password': password,
        if (url != null) 'url': url,
        if (notes != null) 'notes': notes,
      },
    );
  }

  /// 카드 정보용 생성자
  factory EncryptedPayload.card({
    required String cardholderName,
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    String? bankName,
    String? notes,
  }) {
    return EncryptedPayload(
      fields: {
        'cardholderName': cardholderName,
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cvv': cvv,
        if (bankName != null) 'bankName': bankName,
        if (notes != null) 'notes': notes,
      },
    );
  }

  @override
  String toString() {
    return 'EncryptedPayload(content: $content, fields: $fields)';
  }
}
