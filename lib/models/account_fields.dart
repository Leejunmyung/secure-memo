/// 계정 정보 필드
///
/// 서비스 계정 정보 저장용
class AccountFields {
  final String serviceName; // 서비스명 (예: Google, Naver)
  final String username; // 사용자명 또는 이메일
  final String password; // 비밀번호
  final String? url; // 서비스 URL (선택)
  final String? notes; // 추가 메모 (선택)

  AccountFields({
    required this.serviceName,
    required this.username,
    required this.password,
    this.url,
    this.notes,
  });

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'serviceName': serviceName,
      'username': username,
      'password': password,
      'url': url,
      'notes': notes,
    };
  }

  /// JSON 역직렬화
  factory AccountFields.fromJson(Map<String, dynamic> json) {
    return AccountFields(
      serviceName: json['serviceName'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      url: json['url'] as String?,
      notes: json['notes'] as String?,
    );
  }

  /// 복사 메서드
  AccountFields copyWith({
    String? serviceName,
    String? username,
    String? password,
    String? url,
    String? notes,
  }) {
    return AccountFields(
      serviceName: serviceName ?? this.serviceName,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
    );
  }
}
