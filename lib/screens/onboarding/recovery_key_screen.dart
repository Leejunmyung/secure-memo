import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../services/recovery_key_service.dart';
import '../../widgets/recovery_key_grid.dart';
import '../home/home_screen.dart';

/// 복구 키 표시 화면
///
/// PIN 설정 후 24단어 복구 키 표시
/// 사용자가 복구 키를 안전하게 보관할 때까지 진행 불가
class RecoveryKeyScreen extends StatefulWidget {
  const RecoveryKeyScreen({super.key});

  @override
  State<RecoveryKeyScreen> createState() => _RecoveryKeyScreenState();
}

class _RecoveryKeyScreenState extends State<RecoveryKeyScreen> {
  final RecoveryKeyService _recoveryService = RecoveryKeyService();

  String _mnemonic = '';
  List<String> _words = [];
  bool _hasConfirmed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateRecoveryKey();
  }

  Future<void> _generateRecoveryKey() async {
    setState(() => _isLoading = true);

    // 복구 키 생성
    _mnemonic = _recoveryService.generateRecoveryKey();
    _words = _recoveryService.splitMnemonicToWords(_mnemonic);

    // 복구 키 해시 저장
    await _recoveryService.saveRecoveryKeyHash(_mnemonic);

    // 복구 키 기반 마스터 키 생성 및 저장
    await _recoveryService.saveMasterKeyFromRecovery(_mnemonic);

    setState(() => _isLoading = false);
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _mnemonic));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('복구 키가 클립보드에 복사되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _continueToHome() {
    if (!_hasConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('복구 키를 안전하게 보관했는지 확인해주세요'),
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: const SizedBox.shrink(), // 뒤로가기 버튼 숨김
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacing4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                '복구 키 백업',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.onSurface,
                    ),
              ),

              SizedBox(height: AppTheme.spacing2),

              // 설명
              Text(
                '이 24개 단어는 앱을 복구하는 유일한 방법입니다.\n안전한 장소에 보관하세요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),

              SizedBox(height: AppTheme.spacing6),

              // 복구 키 그리드
              Expanded(
                child: SingleChildScrollView(
                  child: RecoveryKeyGrid(
                    words: _words,
                    selectable: true,
                  ),
                ),
              ),

              SizedBox(height: AppTheme.spacing4),

              // 복사 버튼
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy),
                  label: const Text('전체 복사'),
                ),
              ),

              SizedBox(height: AppTheme.spacing2),

              // 확인 체크박스
              Container(
                padding: EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _hasConfirmed,
                      onChanged: (value) {
                        setState(() {
                          _hasConfirmed = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Text(
                        '복구 키를 안전하게 보관했습니다',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurface,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.spacing3),

              // 계속 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _hasConfirmed ? _continueToHome : null,
                  child: const Text('계속'),
                ),
              ),

              SizedBox(height: AppTheme.spacing2),

              // 경고 메시지
              Container(
                padding: EdgeInsets.all(AppTheme.spacing3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
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
                        '복구 키를 잃어버리면 데이터를 복구할 수 없습니다',
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
