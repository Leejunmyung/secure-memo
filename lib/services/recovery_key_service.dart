import 'dart:convert';
import 'dart:typed_data';
import 'package:bip39/bip39.dart' as bip39;
import 'package:crypto/crypto.dart';
import 'secure_storage_service.dart';

/// 복구 키 서비스
///
/// BIP39 24단어 니모닉 관리
/// Phase 3: 복구 키 생성 및 검증
/// Phase 3+: 복구 키로 마스터 키 재생성
class RecoveryKeyService {
  static const String _recoveryKeyHashKey = 'recovery_key_hash';
  static const String _masterKeyFromRecoveryKey = 'master_key_from_recovery';

  final SecureStorageService _storage = SecureStorageService();

  /// 복구 키 생성 (24단어)
  ///
  /// BIP39 표준 니모닉 생성
  /// @return 24개 단어 리스트
  String generateRecoveryKey() {
    // 256비트 엔트로피 → 24단어
    return bip39.generateMnemonic(strength: 256);
  }

  /// 복구 키 검증
  ///
  /// BIP39 표준 검증 (체크섬 포함)
  /// @param mnemonic 니모닉 문자열 (공백으로 구분)
  /// @return 유효 여부
  bool validateRecoveryKey(String mnemonic) {
    return bip39.validateMnemonic(mnemonic);
  }

  /// 복구 키 해시 저장
  ///
  /// 원본 복구 키는 저장하지 않고, SHA-256 해시만 저장
  /// 나중에 사용자 입력 복구 키 검증에 사용
  Future<void> saveRecoveryKeyHash(String mnemonic) async {
    final hash = sha256.convert(utf8.encode(mnemonic)).toString();
    await _storage.write(_recoveryKeyHashKey, hash);
  }

  /// 복구 키 검증 (저장된 해시와 비교)
  ///
  /// @param mnemonic 사용자 입력 니모닉
  /// @return 일치 여부
  Future<bool> verifyRecoveryKey(String mnemonic) async {
    final storedHash = await _storage.read(_recoveryKeyHashKey);
    if (storedHash == null) {
      return false;
    }

    final inputHash = sha256.convert(utf8.encode(mnemonic)).toString();
    return storedHash == inputHash;
  }

  /// 복구 키로 마스터 키 생성
  ///
  /// BIP39 → 512비트 시드 → 처음 32바이트 추출
  /// @param mnemonic 복구 키
  /// @return 마스터 키 (32바이트)
  Uint8List generateMasterKeyFromRecovery(String mnemonic) {
    // BIP39 니모닉 → 512비트 시드
    final seed = bip39.mnemonicToSeed(mnemonic);

    // 처음 32바이트 (256비트) 추출
    return Uint8List.fromList(seed.sublist(0, 32));
  }

  /// 마스터 키 저장 (복구 키 기반)
  ///
  /// Phase 3: 복구 키 생성 시 호출
  /// EncryptionService와 통합하여 마스터 키 저장
  Future<void> saveMasterKeyFromRecovery(String mnemonic) async {
    final masterKey = generateMasterKeyFromRecovery(mnemonic);
    await _storage.write(
      _masterKeyFromRecoveryKey,
      base64Encode(masterKey),
    );
  }

  /// 저장된 마스터 키 가져오기
  Future<Uint8List?> getMasterKey() async {
    final stored = await _storage.read(_masterKeyFromRecoveryKey);
    if (stored == null) {
      return null;
    }
    return base64Decode(stored);
  }

  /// 복구 키 존재 여부 확인
  Future<bool> hasRecoveryKey() async {
    final hash = await _storage.read(_recoveryKeyHashKey);
    return hash != null;
  }

  /// 복구 키 초기화 (테스트용)
  Future<void> resetRecoveryKey() async {
    await _storage.delete(_recoveryKeyHashKey);
    await _storage.delete(_masterKeyFromRecoveryKey);
  }

  /// 24단어를 4x6 그리드로 분할
  ///
  /// UI 표시용
  /// @param mnemonic 니모닉 문자열
  /// @return 24개 단어 리스트
  List<String> splitMnemonicToWords(String mnemonic) {
    return mnemonic.trim().split(' ');
  }

  /// 단어 리스트를 니모닉 문자열로 결합
  ///
  /// @param words 24개 단어 리스트
  /// @return 니모닉 문자열
  String joinWordsToMnemonic(List<String> words) {
    return words.join(' ');
  }
}
