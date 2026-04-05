import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'secure_storage_service.dart';
import 'recovery_key_service.dart';

/// 암호화 서비스
///
/// AES-256-GCM 암호화/복호화
/// Phase 1: 하드코딩된 마스터 키 (테스트용)
/// Phase 3: BIP39 복구 키 기반 마스터 키 생성
class EncryptionService {
  static const String _masterKeyStorageKey = 'master_encryption_key';
  final SecureStorageService _storage = SecureStorageService();

  /// 마스터 키 가져오기 또는 생성
  ///
  /// Phase 1: 랜덤 256비트 키 생성
  /// Phase 3: BIP39 복구 키에서 파생
  Future<Uint8List> _getMasterKey() async {
    final RecoveryKeyService recoveryService = RecoveryKeyService();

    // 1순위: 복구 키 기반 마스터 키 (Phase 3)
    final recoveryKey = await recoveryService.getMasterKey();
    if (recoveryKey != null) {
      return recoveryKey;
    }

    // 2순위: 저장된 랜덤 마스터 키 (Phase 1/2 호환성)
    final storedKey = await _storage.read(_masterKeyStorageKey);
    if (storedKey != null) {
      return base64Decode(storedKey);
    }

    // 3순위: 새 랜덤 마스터 키 생성 (Phase 3 이후 발생하지 않음)
    final random = Random.secure();
    final keyBytes = Uint8List(32); // 256비트
    for (int i = 0; i < 32; i++) {
      keyBytes[i] = random.nextInt(256);
    }

    // 마스터 키 저장
    await _storage.write(_masterKeyStorageKey, base64Encode(keyBytes));

    return keyBytes;
  }

  /// 암호화
  ///
  /// AES-256-GCM 모드
  /// @param plaintext 평문
  /// @return {ciphertext, iv, authTag} Base64 인코딩
  Future<Map<String, String>> encrypt(String plaintext) async {
    try {
      final masterKey = await _getMasterKey();

      // 랜덤 IV 생성 (12바이트 = 96비트, GCM 권장)
      final random = Random.secure();
      final iv = Uint8List(12);
      for (int i = 0; i < 12; i++) {
        iv[i] = random.nextInt(256);
      }

      // AES-GCM 암호화
      final key = encrypt_lib.Key(masterKey);
      final ivObj = encrypt_lib.IV(iv);
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.gcm),
      );

      final encrypted = encrypter.encrypt(plaintext, iv: ivObj);

      // GCM 모드에서 ciphertext는 이미 authTag를 포함하고 있음
      // encrypt 패키지는 자동으로 16바이트 authTag를 ciphertext 끝에 추가
      final ciphertextWithTag = encrypted.bytes;

      // authTag 분리 (마지막 16바이트)
      final ciphertext = ciphertextWithTag.sublist(
        0,
        ciphertextWithTag.length - 16,
      );
      final authTag = ciphertextWithTag.sublist(
        ciphertextWithTag.length - 16,
      );

      return {
        'ciphertext': base64Encode(ciphertext),
        'iv': base64Encode(iv),
        'authTag': base64Encode(authTag),
      };
    } catch (e) {
      throw Exception('암호화 실패: $e');
    }
  }

  /// 복호화
  ///
  /// AES-256-GCM 모드
  /// @param ciphertext 암호문 (Base64)
  /// @param iv 초기화 벡터 (Base64)
  /// @param authTag 인증 태그 (Base64)
  /// @return 평문
  Future<String> decrypt({
    required String ciphertext,
    required String iv,
    required String authTag,
  }) async {
    try {
      final masterKey = await _getMasterKey();

      // Base64 디코딩
      final ciphertextBytes = base64Decode(ciphertext);
      final ivBytes = base64Decode(iv);
      final authTagBytes = base64Decode(authTag);

      // ciphertext + authTag 결합 (encrypt 패키지 형식)
      final ciphertextWithTag = Uint8List.fromList([
        ...ciphertextBytes,
        ...authTagBytes,
      ]);

      // AES-GCM 복호화
      final key = encrypt_lib.Key(masterKey);
      final ivObj = encrypt_lib.IV(ivBytes);
      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.gcm),
      );

      final encrypted = encrypt_lib.Encrypted(ciphertextWithTag);
      final decrypted = encrypter.decrypt(encrypted, iv: ivObj);

      return decrypted;
    } catch (e) {
      throw Exception('복호화 실패: $e');
    }
  }

  /// 마스터 키 초기화 (테스트용)
  ///
  /// 주의: 프로덕션에서는 사용하지 말 것
  Future<void> resetMasterKey() async {
    await _storage.delete(_masterKeyStorageKey);
  }
}
