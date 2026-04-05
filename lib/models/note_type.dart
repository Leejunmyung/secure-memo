import 'package:hive/hive.dart';

part 'note_type.g.dart';

/// 메모 타입
///
/// Phase 1: 일반 메모
/// Phase 3: 계정 정보, 카드 정보 추가
@HiveType(typeId: 0)
enum NoteType {
  /// 일반 메모 (텍스트)
  @HiveField(0)
  general,

  /// 계정 정보 (서비스명, 사용자명, 비밀번호, URL)
  @HiveField(1)
  account,

  /// 카드 정보 (카드 소유자, 카드 번호, 만료일, CVV)
  @HiveField(2)
  card,
}

/// NoteType 확장 메서드
extension NoteTypeExtension on NoteType {
  /// 타입별 아이콘
  String get icon {
    switch (this) {
      case NoteType.general:
        return '📝';
      case NoteType.account:
        return '🔑';
      case NoteType.card:
        return '💳';
    }
  }

  /// 타입별 이름
  String get displayName {
    switch (this) {
      case NoteType.general:
        return '일반 메모';
      case NoteType.account:
        return '계정 정보';
      case NoteType.card:
        return '카드 정보';
    }
  }
}
