import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';
import 'secure_storage_service.dart';

/// 인증 서비스
///
/// 주요 기능:
/// - 생체 인증 (Face ID, 지문)
/// - PIN 설정 및 검증 (PBKDF2 해싱)
/// - 복구 키 기반 마스터 키 재생성
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _storage = SecureStorageService();

  // Storage Keys
  static const String _pinHashKey = 'pin_hash';
  static const String _pinSaltKey = 'pin_salt';
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// 생체 인증 가능 여부 확인
  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// 사용 가능한 생체 인증 종류 확인
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// 생체 인증 활성화 여부 확인
  Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(_biometricEnabledKey);
    return enabled == 'true';
  }

  /// 생체 인증 활성화/비활성화 설정
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(_biometricEnabledKey, enabled.toString());
  }

  /// 생체 인증 수행
  Future<bool> authenticateWithBiometric({
    required String reason,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // PIN 백업 허용
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );
    } catch (e) {
      print('생체 인증 오류: $e');
      return false;
    }
  }

  /// PIN 설정 (첫 실행 시)
  ///
  /// PBKDF2 해싱 적용:
  /// - Iterations: 100,000
  /// - Key Length: 32 bytes (256 bits)
  /// - Random Salt: 16 bytes
  Future<bool> setupPin(String pin) async {
    try {
      // 랜덤 Salt 생성 (16 bytes)
      final salt = _generateRandomBytes(16);

      // PBKDF2 해싱
      final hashedPin = _pbkdf2(pin, salt, 100000, 32);

      // 해시 + Salt 저장
      await _storage.write(_pinHashKey, base64Encode(hashedPin));
      await _storage.write(_pinSaltKey, base64Encode(salt));

      return true;
    } catch (e) {
      print('PIN 설정 오류: $e');
      return false;
    }
  }

  /// PIN 검증
  Future<bool> verifyPin(String pin) async {
    try {
      final storedHash = await _storage.read(_pinHashKey);
      final storedSalt = await _storage.read(_pinSaltKey);

      if (storedHash == null || storedSalt == null) {
        return false;
      }

      final salt = base64Decode(storedSalt);
      final inputHash = _pbkdf2(pin, salt, 100000, 32);

      return base64Encode(inputHash) == storedHash;
    } catch (e) {
      print('PIN 검증 오류: $e');
      return false;
    }
  }

  /// PIN 존재 여부 확인
  Future<bool> hasPin() async {
    return await _storage.containsKey(_pinHashKey);
  }

  /// PIN 변경
  Future<bool> changePin(String oldPin, String newPin) async {
    // 기존 PIN 검증
    final isValid = await verifyPin(oldPin);
    if (!isValid) {
      return false;
    }

    // 새 PIN 설정
    return await setupPin(newPin);
  }

  /// PIN 삭제 (앱 리셋 시)
  Future<void> deletePin() async {
    await _storage.delete(_pinHashKey);
    await _storage.delete(_pinSaltKey);
  }

  /// 앱 잠금 해제 (생체 인증 우선, PIN 백업)
  Future<bool> unlockApp() async {
    final biometricAvailable = await isBiometricAvailable();
    final biometricEnabled = await isBiometricEnabled();

    if (biometricAvailable && biometricEnabled) {
      try {
        final authenticated = await authenticateWithBiometric(
          reason: '메모르 앱을 잠금 해제하려면 인증이 필요합니다',
        );
        if (authenticated) return true;
      } catch (e) {
        print('생체 인증 실패: $e');
      }
    }

    // 생체 인증 실패 시 PIN 입력으로 폴백
    // (UI에서 PinInputScreen으로 이동)
    return false;
  }

  // ====================
  // Private Helper Methods
  // ====================

  /// 랜덤 바이트 생성
  Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// PBKDF2 해싱
  ///
  /// [password] 비밀번호
  /// [salt] 솔트
  /// [iterations] 반복 횟수 (기본 100,000)
  /// [keyLength] 키 길이 (바이트, 기본 32)
  Uint8List _pbkdf2(
    String password,
    Uint8List salt,
    int iterations,
    int keyLength,
  ) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, iterations, keyLength));

    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }
}
