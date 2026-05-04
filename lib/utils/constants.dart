/// 앱 전역 상수
class AppConstants {
  // 앱 정보
  static const String appName = '메모르';
  static const String appNameEn = 'Memore';
  static const String appVersion = '1.2.0';

  // PIN 설정
  static const int minPinLength = 4;
  static const int maxPinLength = 6;

  // 스토리지 키
  static const String firstLaunchKey = 'first_launch';

  // 메시지
  static const String welcomeMessage = '메모르';
  static const String welcomeSubtitle =
      '나만 알고 남들은 메모르(모르)는 노트';
  static const String pinSetupTitle = 'PIN 설정';
  static const String pinSetupSubtitle = '앱 잠금 해제에 사용할 PIN을 설정하세요';
  static const String unlockTitle = '잠금 해제';
}
