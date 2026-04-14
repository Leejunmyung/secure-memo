import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_theme.dart';
import '../../models/note.dart';
import '../../models/note_type.dart';
import '../../models/encrypted_payload.dart';
import '../../providers/note_provider.dart';

/// 일반 메모 편집 화면
///
/// 일반 텍스트 메모 생성/편집
class NoteEditorScreen extends StatefulWidget {
  final Note? note; // null이면 새 메모, 값이 있으면 편집 모드

  const NoteEditorScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingContent = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _loadNote();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 기존 메모 로드 (복호화)
  Future<void> _loadNote() async {
    setState(() => _isLoadingContent = true);

    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final payload = await noteProvider.decryptNote(widget.note!);

      setState(() {
        _titleController.text = widget.note!.title;
        _contentController.text = payload.content ?? '';
        _isLoadingContent = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingContent = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메모 로드 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  /// 메모 저장
  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목을 입력하세요')),
      );
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내용을 입력하세요')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final payload = EncryptedPayload.general(_contentController.text.trim());

      if (widget.note == null) {
        // 새 메모 생성
        await noteProvider.createNote(
          title: _titleController.text.trim(),
          payload: payload,
          type: NoteType.general,
        );
      } else {
        // 기존 메모 업데이트
        await noteProvider.updateNote(
          id: widget.note!.id,
          title: _titleController.text.trim(),
          payload: payload,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.note == null ? '메모가 생성되었습니다' : '메모가 수정되었습니다'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 메모 삭제
  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('메모 삭제'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final noteProvider = Provider.of<NoteProvider>(context, listen: false);
        await noteProvider.deleteNote(widget.note!.id);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('메모가 삭제되었습니다'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('삭제 실패: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(widget.note == null ? '새 메모' : '메모 편집'),
        actions: [
          if (widget.note != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteNote,
              tooltip: '삭제',
            ),
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing3),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveNote,
              tooltip: '저장',
            ),
        ],
      ),
      body: _isLoadingContent
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppTheme.spacing4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    TextField(
                      controller: _titleController,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                      decoration: InputDecoration(
                        hintText: '제목',
                        hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                        border: InputBorder.none,
                      ),
                      maxLines: 1,
                    ),

                    SizedBox(height: AppTheme.spacing2),

                    // 구분선
                    Container(
                      height: 1,
                      color: AppColors.ghostBorder,
                    ),

                    SizedBox(height: AppTheme.spacing4),

                    // 내용
                    TextField(
                      controller: _contentController,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                      decoration: InputDecoration(
                        hintText: '내용을 입력하세요...',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
