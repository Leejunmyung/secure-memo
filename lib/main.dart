import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/app_colors.dart';
import 'config/app_theme.dart';
import 'services/secure_storage_service.dart';
import 'utils/constants.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/auth/unlock_screen.dart';
import 'providers/note_provider.dart';

/// SecureKeep 앱 진입점
///
/// Phase 1: 생체 인증, PIN 검증
/// Phase 2: 메모 CRUD, AES-256-GCM 암호화
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 상태 표시줄 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // 세로 방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SecureKeepApp());
}

/// SecureKeep 앱 루트 위젯
class SecureKeepApp extends StatelessWidget {
  const SecureKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NoteProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

/// 스플래시 화면
///
/// 첫 실행 여부 확인 후 적절한 화면으로 라우팅
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorageService _storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    // 약간의 딜레이로 자연스러운 스플래시 효과
    await Future.delayed(const Duration(milliseconds: 500));

    final isFirstLaunch = await _storage.read(AppConstants.firstLaunchKey);

    if (!mounted) return;

    // 첫 실행 여부에 따라 라우팅
    if (isFirstLaunch == null || isFirstLaunch == 'true') {
      // 첫 실행 → 온보딩
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
      );
    } else {
      // 기존 사용자 → 잠금 해제
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const UnlockScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 앱 아이콘
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge * 3),
              ),
              child: Icon(
                Icons.shield_outlined,
                size: 64,
                color: AppColors.onPrimary,
              ),
            ),

            SizedBox(height: AppTheme.spacing4),

            // 앱 이름
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),

            SizedBox(height: AppTheme.spacing8),

            // 로딩 인디케이터
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
