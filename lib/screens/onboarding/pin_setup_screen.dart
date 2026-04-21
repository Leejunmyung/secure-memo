import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/secure_storage_service.dart';
import '../../utils/constants.dart';
import '../../widgets/pin_input_field.dart';
import '../home/home_screen.dart';

/// PIN 설정 화면
///
/// 첫 실행 시 사용자가 PIN을 설정하는 화면
/// PIN 확인을 위해 2번 입력받음
class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final AuthService _authService = AuthService();
  final SecureStorageService _storage = SecureStorageService();

  String? _firstPin;
  bool _isConfirming = false;
  String _errorMessage = '';
  bool _isLoading = false;

  void _onFirstPinCompleted(String pin) {
    setState(() {
      _firstPin = pin;
      _isConfirming = true;
      _errorMessage = '';
    });
  }

  int _confirmAttempt = 0;

  Future<void> _onSecondPinCompleted(String pin) async {
    if (_firstPin != pin) {
      setState(() {
        _errorMessage = 'PIN이 일치하지 않습니다';
        _confirmAttempt++; // ValueKey 변경으로 위젯 재생성
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // PIN 저장
    final success = await _authService.setupPin(pin);

    if (success && mounted) {
      // 생체 인증 활성화 여부 확인
      final biometricAvailable = await _authService.isBiometricAvailable();

      if (biometricAvailable) {
        await _authService.setBiometricEnabled(true);
      }

      // 첫 실행 완료 표시
      await _storage.write(AppConstants.firstLaunchKey, 'false');

      // 홈 화면으로 이동
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'PIN 저장에 실패했습니다';
        _isLoading = false;
      });
    }
  }

  void _onBack() {
    if (_isConfirming) {
      setState(() {
        _firstPin = null;
        _isConfirming = false;
        _errorMessage = '';
        _confirmAttempt = 0; // 초기화
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: AppTheme.spacing8),

              // 제목
              Text(
                _isConfirming ? 'PIN 확인' : AppConstants.pinSetupTitle,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppTheme.spacing2),

              // 부제목
              Text(
                _isConfirming
                    ? '동일한 PIN을 다시 입력하세요'
                    : AppConstants.pinSetupSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppTheme.spacing8),

              // PIN 입력 필드
              if (!_isConfirming)
                PinInputField(
                  key: const ValueKey('first_pin'),
                  pinLength: AppConstants.maxPinLength,
                  onCompleted: _onFirstPinCompleted,
                  onChanged: () {
                    setState(() {
                      _errorMessage = '';
                    });
                  },
                )
              else
                PinInputField(
                  key: ValueKey('second_pin_$_confirmAttempt'),
                  pinLength: AppConstants.maxPinLength,
                  onCompleted: _onSecondPinCompleted,
                  onChanged: () {
                    setState(() {
                      _errorMessage = '';
                    });
                  },
                ),

              SizedBox(height: AppTheme.spacing4),

              // 에러 메시지
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing2),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 20,
                        color: AppColors.error,
                      ),
                      SizedBox(width: AppTheme.spacing1),
                      Text(
                        _errorMessage,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ],
                  ),
                ),

              // 로딩 인디케이터
              if (_isLoading) ...[
                SizedBox(height: AppTheme.spacing4),
                CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ],

              const Spacer(),

              // 안내 문구
              Container(
                padding: EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: AppTheme.spacing2),
                    Expanded(
                      child: Text(
                        'PIN은 앱 잠금 해제에 사용됩니다.\n안전한 장소에 기록해 두세요.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
