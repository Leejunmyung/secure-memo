import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_typography.dart';
import '../../config/app_theme.dart';
import '../../providers/note_provider.dart';
import '../../widgets/note_card.dart';
import '../note/note_editor_screen.dart';
import '../settings/settings_screen.dart';

/// 홈 화면 (메모 목록)
///
/// Toss 스타일 디자인 적용
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '전체';
  final List<String> _categories = ['전체', '금융', '법률', '개인', '의료', '신분', '일반'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> get _filteredNotes {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    var notes = noteProvider.notes;

    // Category filter
    if (_selectedCategory != '전체') {
      notes = notes.where((note) => note.category == _selectedCategory).toList();
    }

    // Search filter
    if (_searchController.text.trim().isNotEmpty) {
      notes = notes
          .where((note) =>
              note.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              note.category.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Consumer<NoteProvider>(
          builder: (context, noteProvider, child) {
            if (noteProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            final filteredNotes = _filteredNotes;

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppTheme.spacing4,
                      AppTheme.spacing6,
                      AppTheme.spacing4,
                      0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '안녕하세요 👋',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing1),
                            Text(
                              '보안 기록',
                              style: AppTypography.headlineLarge.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            SizedBox(height: AppTheme.spacing1 / 2),
                            Text(
                              '${noteProvider.notes.length}개 메모',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.settings_outlined, size: 24),
                          color: AppColors.onSurfaceVariant,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Search bar (메모가 있을 때만 표시)
                if (noteProvider.notes.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppTheme.spacing4,
                        AppTheme.spacing4,
                        AppTheme.spacing4,
                        0,
                      ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: '메모 검색...',
                          hintStyle: AppTypography.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.onSurfaceVariant,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing3,
                            vertical: AppTheme.spacing2 + 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Category chips (메모가 있을 때만 표시)
                if (noteProvider.notes.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.only(
                        left: AppTheme.spacing4,
                        top: AppTheme.spacing1,
                        bottom: AppTheme.spacing1,
                      ),
                      height: 52,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category;

                          return Padding(
                            padding: EdgeInsets.only(right: AppTheme.spacing2),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                constraints: BoxConstraints(minWidth: 50),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.visible,
                                  softWrap: false,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Memo list or empty state
                if (filteredNotes.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchController.text.isNotEmpty || _selectedCategory != '전체'
                                ? Icons.search_off
                                : Icons.note_add_outlined,
                            size: 64,
                            color: AppColors.surfaceContainerHigh,
                          ),
                          SizedBox(height: AppTheme.spacing3),
                          Text(
                            _searchController.text.isNotEmpty || _selectedCategory != '전체'
                                ? '검색 결과가 없습니다'
                                : '메모가 없습니다',
                            style: AppTypography.bodyLarge.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          if (noteProvider.notes.isEmpty) ...[
                            SizedBox(height: AppTheme.spacing2),
                            Text(
                              '새 메모를 추가하려면\n아래 + 버튼을 눌러주세요',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      AppTheme.spacing4,
                      AppTheme.spacing4,
                      AppTheme.spacing4,
                      AppTheme.spacing6,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final note = filteredNotes[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: AppTheme.spacing3),
                            child: NoteCard(
                              note: note,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => NoteEditorScreen(note: note),
                                  ),
                                );
                              },
                              onFavoriteTap: () {
                                noteProvider.toggleFavorite(note.id);
                              },
                            ),
                          );
                        },
                        childCount: filteredNotes.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NoteEditorScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: Colors.white, size: 26),
      ),
    );
  }
}
