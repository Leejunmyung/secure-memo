/// 앱 전역 상수
class AppConstants {
  // 앱 정보
  static const String appName = 'SecureKeep';
  static const String appVersion = '1.0.0';

  // PIN 설정
  static const int minPinLength = 4;
  static const int maxPinLength = 6;

  // 스토리지 키
  static const String firstLaunchKey = 'first_launch';

  // 메시지
  static const String welcomeMessage = 'SecureKeep에 오신 것을 환영합니다';
  static const String welcomeSubtitle =
      'BIP39 복구 키 기반\n로컬 전용 보안 메모장';
  static const String pinSetupTitle = 'PIN 설정';
  static const String pinSetupSubtitle = '앱 잠금 해제에 사용할 PIN을 설정하세요';
  static const String unlockTitle = '잠금 해제';
}
