import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';
import '../config/app_theme.dart';

/// PIN 입력 커스텀 위젯
///
/// 4-6자리 PIN을 입력받는 원형 인디케이터 UI
class PinInputField extends StatefulWidget {
  final int pinLength;
  final ValueChanged<String>? onCompleted;
  final VoidCallback? onChanged;

  const PinInputField({
    super.key,
    this.pinLength = 6,
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  String _currentPin = '';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.pinLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onPinChanged(int index, String value) {
    if (value.isNotEmpty) {
      _currentPin += value;

      // 다음 필드로 포커스 이동
      if (index < widget.pinLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // 마지막 자리 입력 완료
        _focusNodes[index].unfocus();
        if (widget.onCompleted != null) {
          widget.onCompleted!(_currentPin);
        }
      }
    } else {
      // 백스페이스 처리
      if (_currentPin.isNotEmpty) {
        _currentPin = _currentPin.substring(0, _currentPin.length - 1);
      }
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    if (widget.onChanged != null) {
      widget.onChanged!();
    }
  }

  /// PIN 초기화
  void clear() {
    setState(() {
      _currentPin = '';
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 화면 너비에 맞게 필드 크기 계산
    final screenWidth = MediaQuery.of(context).size.width;
    final totalSpacing = AppTheme.spacing1 * 2 * widget.pinLength; // 좌우 margin
    final availableWidth = screenWidth - AppTheme.spacing6 * 2 - totalSpacing; // padding 고려
    final fieldWidth = (availableWidth / widget.pinLength).clamp(40.0, 50.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.pinLength,
        (index) => Container(
          margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing1),
          child: SizedBox(
            width: fieldWidth,
            height: 60,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              obscureText: true,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  borderSide: BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) => _onPinChanged(index, value),
            ),
          ),
        ),
      ),
    );
  }
}
