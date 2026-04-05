import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// flutter_secure_storage 래퍼 서비스
///
/// OS별 보안 스토리지에 민감한 데이터를 안전하게 저장합니다:
/// - Android: Keystore
/// - iOS: Keychain
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// 데이터 저장
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// 데이터 읽기
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// 데이터 삭제
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// 모든 데이터 삭제
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  /// 키 존재 여부 확인
  Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }

  /// 모든 키-값 쌍 읽기
  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }
}
