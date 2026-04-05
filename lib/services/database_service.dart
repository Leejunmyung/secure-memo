import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../models/note_type.dart';

/// 데이터베이스 서비스
///
/// Hive 로컬 데이터베이스 CRUD 작업
class DatabaseService {
  static const String _notesBoxName = 'notes';
  Box<Note>? _notesBox;

  /// Hive 초기화
  ///
  /// 앱 시작 시 main.dart에서 호출
  Future<void> initialize() async {
    // Hive 초기화
    await Hive.initFlutter();

    // TypeAdapter 등록
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(NoteAdapter());
    }

    // Box 열기
    _notesBox = await Hive.openBox<Note>(_notesBoxName);
  }

  /// Notes Box 가져오기
  Box<Note> get notesBox {
    if (_notesBox == null || !_notesBox!.isOpen) {
      throw Exception('데이터베이스가 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
    }
    return _notesBox!;
  }

  /// 모든 메모 가져오기
  ///
  /// 최신순 정렬
  List<Note> getAllNotes() {
    final notes = notesBox.values.toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  /// 타입별 메모 가져오기
  List<Note> getNotesByType(NoteType type) {
    final notes = notesBox.values.where((note) => note.type == type).toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  /// 즐겨찾기 메모 가져오기
  List<Note> getFavoriteNotes() {
    final notes = notesBox.values.where((note) => note.isFavorite).toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  /// 메모 검색 (제목)
  ///
  /// 내용은 암호화되어 있어 검색 불가
  List<Note> searchNotes(String query) {
    if (query.trim().isEmpty) {
      return getAllNotes();
    }

    final lowerQuery = query.toLowerCase();
    final notes = notesBox.values
        .where((note) => note.title.toLowerCase().contains(lowerQuery))
        .toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  /// 메모 저장 (생성 또는 수정)
  ///
  /// id가 이미 존재하면 수정, 없으면 생성
  Future<void> saveNote(Note note) async {
    // Hive Box에 저장 (key = note.id)
    await notesBox.put(note.id, note);
  }

  /// 메모 삭제
  Future<void> deleteNote(String id) async {
    await notesBox.delete(id);
  }

  /// 메모 ID로 가져오기
  Note? getNoteById(String id) {
    return notesBox.get(id);
  }

  /// 즐겨찾기 토글
  Future<void> toggleFavorite(String id) async {
    final note = getNoteById(id);
    if (note != null) {
      final updatedNote = note.copyWith(
        isFavorite: !note.isFavorite,
        updatedAt: DateTime.now(),
      );
      await saveNote(updatedNote);
    }
  }

  /// 모든 메모 삭제 (테스트용)
  Future<void> deleteAllNotes() async {
    await notesBox.clear();
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    await _notesBox?.close();
  }
}
