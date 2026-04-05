import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/pin_input_field.dart';

/// PIN 입력 화면
///
/// 앱 잠금 해제를 위한 PIN 입력
class PinInputScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const PinInputScreen({
    super.key,
    required this.onSuccess,
  });

  @override
  State<PinInputScreen> createState() => _PinInputScreenState();
}

class _PinInputScreenState extends State<PinInputScreen> {
  final AuthService _authService = AuthService();

  String _errorMessage = '';
  bool _isLoading = false;
  int _failedAttempts = 0;

  Future<void> _onPinCompleted(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final isValid = await _authService.verifyPin(pin);

    if (isValid && mounted) {
      widget.onSuccess();
    } else {
      setState(() {
        _failedAttempts++;
        _errorMessage = 'PIN이 올바르지 않습니다';
        _isLoading = false;
      });

      // PIN 입력 필드 초기화 (간단히 build 재실행으로 처리)
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                'PIN 입력',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppTheme.spacing2),

              // 부제목
              Text(
                '앱 잠금 해제를 위해 PIN을 입력하세요',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppTheme.spacing8),

              // PIN 입력 필드
              PinInputField(
                key: ValueKey(_failedAttempts), // 실패 시 재생성
                pinLength: AppConstants.maxPinLength,
                onCompleted: _onPinCompleted,
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

              // 복구 안내 (나중에 복구 키 기능 추가 시 활성화)
              if (_failedAttempts >= 3)
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing3),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_outlined,
                        size: 20,
                        color: AppColors.error,
                      ),
                      SizedBox(width: AppTheme.spacing2),
                      Expanded(
                        child: Text(
                          'PIN을 잊으셨나요?\n복구 키를 사용하여 앱을 복원할 수 있습니다.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.error,
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
