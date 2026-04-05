import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';
import '../config/app_theme.dart';

/// 보안 텍스트 필드 위젯
///
/// 비밀번호 입력용 TextField
/// - obscureText 지원
/// - 가시성 토글 아이콘 (👁️)
/// - 복사 버튼 (선택)
class SecureTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final bool showVisibilityToggle;
  final bool showCopyButton;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int? maxLines;
  final ValueChanged<String>? onChanged;

  const SecureTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.showVisibilityToggle = false,
    this.showCopyButton = false,
    this.validator,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  State<SecureTextField> createState() => _SecureTextFieldState();
}

class _SecureTextFieldState extends State<SecureTextField> {
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  void _toggleVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  Future<void> _copyToClipboard() async {
    if (widget.controller.text.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: widget.controller.text));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('클립보드에 복사되었습니다'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.primary,
        ),
      );

      // 1분 후 클립보드 자동 삭제
      Future.delayed(const Duration(minutes: 1), () {
        Clipboard.setData(const ClipboardData(text: ''));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscureText && _isObscured,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      onChanged: widget.onChanged,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurface,
          ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppColors.ghostBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 가시성 토글 버튼
            if (widget.showVisibilityToggle)
              IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: _toggleVisibility,
                tooltip: _isObscured ? '비밀번호 표시' : '비밀번호 숨김',
              ),

            // 복사 버튼
            if (widget.showCopyButton)
              IconButton(
                icon: Icon(
                  Icons.copy,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: _copyToClipboard,
                tooltip: '복사',
              ),
          ],
        ),
      ),
    );
  }
}
