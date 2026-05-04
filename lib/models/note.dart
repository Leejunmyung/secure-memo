import 'package:hive/hive.dart';
import 'note_type.dart';

part 'note.g.dart';

/// 메모 모델
///
/// Hive 데이터베이스에 저장되는 메인 엔티티
@HiveType(typeId: 1)
class Note extends HiveObject {
  /// 고유 ID (UUID)
  @HiveField(0)
  String id;

  /// 제목 (평문 - 검색 가능)
  @HiveField(1)
  String title;

  /// 메모 타입 (Deprecated: 모든 메모는 자유 포맷)
  /// 기존 데이터 호환성을 위해 유지, 항상 general 사용
  @HiveField(2)
  NoteType type;

  /// 암호화된 내용 (Base64)
  @HiveField(3)
  String encryptedContent;

  /// 초기화 벡터 (IV, Base64)
  @HiveField(4)
  String iv;

  /// 인증 태그 (AuthTag, Base64)
  @HiveField(5)
  String authTag;

  /// 생성 일시
  @HiveField(6)
  DateTime createdAt;

  /// 수정 일시
  @HiveField(7)
  DateTime updatedAt;

  /// 즐겨찾기 여부
  @HiveField(8)
  bool isFavorite;

  /// 사용자 정의 카테고리 (입력하지 않으면 '일반')
  @HiveField(9)
  String category;

  Note({
    required this.id,
    required this.title,
    this.type = NoteType.general, // 자유 포맷: 항상 general 사용
    required this.encryptedContent,
    required this.iv,
    required this.authTag,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.category = '일반',
  });

  /// 복사본 생성 (일부 필드 변경)
  Note copyWith({
    String? id,
    String? title,
    NoteType? type,
    String? encryptedContent,
    String? iv,
    String? authTag,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    String? category,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      encryptedContent: encryptedContent ?? this.encryptedContent,
      iv: iv ?? this.iv,
      authTag: authTag ?? this.authTag,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, type: $type, createdAt: $createdAt)';
  }
}
