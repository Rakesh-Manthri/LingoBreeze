import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/word_card.dart';
import '../widgets/state_views.dart';
import '../widgets/add_word_bottom_sheet.dart';
import '../../../../core/theme/app_colors.dart';

class VocabularyScreen extends ConsumerStatefulWidget {
  const VocabularyScreen({super.key});

  @override
  ConsumerState<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends ConsumerState<VocabularyScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddWordBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddWordBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch raw vocabulary state to check if the database is entirely empty
    final rawVocabularyState = ref.watch(vocabularyProvider);
    // 2. Watch filtered vocabulary state to render the search/sort list
    final filteredVocabularyState = ref.watch(filteredVocabularyProvider);
    final sortBy = ref.watch(sortByProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('LingoBreeze'),
      ),
      body: rawVocabularyState.when(
        data: (rawWords) {
          // If the user has not saved any words at all, show the main Empty State view
          if (rawWords.isEmpty) {
            return EmptyStateView(
              onAddPressed: () => _showAddWordBottomSheet(context),
            );
          }

          // Otherwise, show the search & sort bar followed by the list
          return Column(
            children: [
              // Search & Sort Bar Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(8),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            ref.read(searchQueryProvider.notifier).update(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search words, meanings...',
                            hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.textSecondary,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref.read(searchQueryProvider.notifier).update('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sort Popup Button
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(8),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PopupMenuButton<SortOption>(
                        initialValue: sortBy,
                        icon: const Icon(
                          Icons.sort,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onSelected: (option) {
                          ref.read(sortByProvider.notifier).update(option);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: SortOption.newestAdded,
                            child: Row(
                              children: [
                                Icon(Icons.schedule, size: 18),
                                SizedBox(width: 8),
                                Text('Newest Added'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: SortOption.oldestAdded,
                            child: Row(
                              children: [
                                Icon(Icons.history, size: 18),
                                SizedBox(width: 8),
                                Text('Oldest Added'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: SortOption.alphabeticalAZ,
                            child: Row(
                              children: [
                                Icon(Icons.sort_by_alpha, size: 18),
                                SizedBox(width: 8),
                                Text('A - Z'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: SortOption.alphabeticalZA,
                            child: Row(
                              children: [
                                Icon(Icons.sort_by_alpha, size: 18),
                                SizedBox(width: 8),
                                Text('Z - A'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // List Content or Filter Empty State
              Expanded(
                child: filteredVocabularyState.when(
                  data: (filteredWords) {
                    if (filteredWords.isEmpty) {
                      return NoSearchResultsView(
                        onClearPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).update('');
                        },
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () => ref.read(vocabularyProvider.notifier).loadWords(),
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredWords.length,
                        itemBuilder: (context, index) {
                          return WordCard(word: filteredWords[index]);
                        },
                      ),
                    );
                  },
                  loading: () => const LoadingStateView(),
                  error: (error, stackTrace) => ErrorStateView(
                    message: error.toString(),
                    onRetry: () => ref.read(vocabularyProvider.notifier).loadWords(),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingStateView(),
        error: (error, stackTrace) => ErrorStateView(
          message: error.toString(),
          onRetry: () => ref.read(vocabularyProvider.notifier).loadWords(),
        ),
      ),
      floatingActionButton: rawVocabularyState.maybeWhen(
        data: (rawWords) => rawWords.isNotEmpty
            ? FloatingActionButton(
                onPressed: () => _showAddWordBottomSheet(context),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        orElse: () => null,
      ),
    );
  }
}

