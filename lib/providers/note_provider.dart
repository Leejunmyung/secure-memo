import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../models/note_type.dart';
import '../models/encrypted_payload.dart';
import '../services/database_service.dart';
import '../services/encryption_service.dart';

/// 메모 상태 관리 Provider
///
/// 메모 CRUD, 암호화/복호화 통합
class NoteProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final EncryptionService _encryption = EncryptionService();

  List<Note> _notes = [];
  bool _isLoading = false;
  String? _errorMessage;
  NoteType? _filterType;
  String _searchQuery = '';

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  NoteType? get filterType => _filterType;
  String get searchQuery => _searchQuery;

  /// Provider 초기화
  ///
  /// 데이터베이스 초기화 및 메모 로드
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _db.initialize();
      await loadNotes();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '초기화 실패: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 메모 로드
  Future<void> loadNotes() async {
    try {
      if (_searchQuery.isNotEmpty) {
        _notes = _db.searchNotes(_searchQuery);
      } else if (_filterType != null) {
        _notes = _db.getNotesByType(_filterType!);
      } else {
        _notes = _db.getAllNotes();
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = '메모 로드 실패: $e';
      notifyListeners();
    }
  }

  /// 메모 생성
  ///
  /// @param title 제목 (평문)
  /// @param payload 암호화할 페이로드
  /// @param type 메모 타입 (Deprecated: 항상 general 사용)
  /// @param category 사용자 정의 카테고리 (입력하지 않으면 '일반')
  Future<void> createNote({
    required String title,
    required EncryptedPayload payload,
    NoteType type = NoteType.general, // 자유 포맷: 항상 general
    String? category,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 암호화
      final encrypted = await _encryption.encrypt(payload.toJsonString());

      // 메모 생성
      final note = Note(
        id: const Uuid().v4(),
        title: title,
        type: type,
        encryptedContent: encrypted['ciphertext']!,
        iv: encrypted['iv']!,
        authTag: encrypted['authTag']!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
        category: category?.trim().isEmpty ?? true ? '일반' : category!.trim(),
      );

      // 저장
      await _db.saveNote(note);
      await loadNotes();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '메모 생성 실패: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 메모 수정
  Future<void> updateNote({
    required String id,
    String? title,
    EncryptedPayload? payload,
    String? category,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final existingNote = _db.getNoteById(id);
      if (existingNote == null) {
        throw Exception('메모를 찾을 수 없습니다');
      }

      String encryptedContent = existingNote.encryptedContent;
      String iv = existingNote.iv;
      String authTag = existingNote.authTag;

      // 내용 변경 시 재암호화
      if (payload != null) {
        final encrypted = await _encryption.encrypt(payload.toJsonString());
        encryptedContent = encrypted['ciphertext']!;
        iv = encrypted['iv']!;
        authTag = encrypted['authTag']!;
      }

      // 카테고리 처리 (빈 문자열이면 '일반'으로)
      String? finalCategory;
      if (category != null) {
        finalCategory = category.trim().isEmpty ? '일반' : category.trim();
      }

      // 메모 업데이트
      final updatedNote = existingNote.copyWith(
        title: title ?? existingNote.title,
        encryptedContent: encryptedContent,
        iv: iv,
        authTag: authTag,
        updatedAt: DateTime.now(),
        category: finalCategory,
      );

      await _db.saveNote(updatedNote);
      await loadNotes();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '메모 수정 실패: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// 메모 삭제
  Future<void> deleteNote(String id) async {
    try {
      await _db.deleteNote(id);
      await loadNotes();
      notifyListeners();
    } catch (e) {
      _errorMessage = '메모 삭제 실패: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// 메모 복호화
  ///
  /// @param note 메모
  /// @return EncryptedPayload 복호화된 페이로드
  Future<EncryptedPayload> decryptNote(Note note) async {
    try {
      final decrypted = await _encryption.decrypt(
        ciphertext: note.encryptedContent,
        iv: note.iv,
        authTag: note.authTag,
      );

      return EncryptedPayload.fromJsonString(decrypted);
    } catch (e) {
      throw Exception('복호화 실패: $e');
    }
  }

  /// 즐겨찾기 토글
  Future<void> toggleFavorite(String id) async {
    try {
      await _db.toggleFavorite(id);
      await loadNotes();
      notifyListeners();
    } catch (e) {
      _errorMessage = '즐겨찾기 변경 실패: $e';
      notifyListeners();
    }
  }

  /// 타입 필터 설정
  void setFilterType(NoteType? type) {
    _filterType = type;
    loadNotes();
  }

  /// 검색어 설정
  void setSearchQuery(String query) {
    _searchQuery = query;
    loadNotes();
  }

  /// 즐겨찾기만 표시
  void showFavoritesOnly() {
    _notes = _db.getFavoriteNotes();
    notifyListeners();
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
