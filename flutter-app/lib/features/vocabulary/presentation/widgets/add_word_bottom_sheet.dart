import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/vocabulary_provider.dart';

class AddWordBottomSheet extends ConsumerStatefulWidget {
  const AddWordBottomSheet({super.key});

  @override
  ConsumerState<AddWordBottomSheet> createState() => _AddWordBottomSheetState();
}

class _AddWordBottomSheetState extends ConsumerState<AddWordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _translationController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _translationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(vocabularyProvider.notifier).addWord(
        word: _wordController.text.trim(),
        meaning: _meaningController.text.trim(),
        translation: _translationController.text.trim(),
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _showErrorDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connection Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Diagnostic Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Text(
                _errorMessage ?? 'Unknown error saving word.',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('form_view'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add New Word',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _wordController,
            decoration: const InputDecoration(labelText: 'Word'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _meaningController,
            decoration: const InputDecoration(labelText: 'Meaning'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _translationController,
            decoration: const InputDecoration(labelText: 'Translation'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required' : null,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Word'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey('success_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        // Success Icon (Breeze/Checkmark Hybrid)
        Center(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Outer ring
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryContainer.withAlpha(76),
                    width: 4,
                  ),
                ),
              ),
              // Inner circle background
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              // Decorative Breeze Particles
              Positioned(
                top: -8,
                right: -8,
                child: Transform.rotate(
                  angle: 12 * 3.14159 / 180,
                  child: const Icon(
                    Icons.air,
                    size: 20,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: -12,
                child: Transform.rotate(
                  angle: -12 * 3.14159 / 180,
                  child: const Icon(
                    Icons.spa,
                    size: 16,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Success Messaging
        Text(
          "Word Added!",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: AppColors.textPrimary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "Your vocabulary is growing. Keep it up!",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Actions
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _wordController.clear();
              _meaningController.clear();
              _translationController.clear();
              _isSuccess = false;
            });
          },
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add Another'),
          style: ElevatedButton.styleFrom(
            shadowColor: AppColors.primaryContainer.withAlpha(38),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.library_books, size: 20),
          label: const Text('View Collection'),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.accent.withAlpha(25),
            foregroundColor: AppColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildErrorView() {
    return Column(
      key: const ValueKey('error_view'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        // Error Icon
        Center(
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Glow background
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.error.withAlpha(25),
                      AppColors.error.withAlpha(0),
                    ],
                  ),
                ),
              ),
              // Inner box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.cardBorder,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.error.withAlpha(20),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.cloud_off,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              // Floating breeze particle for continuity
              Positioned(
                top: -6,
                right: -6,
                child: Transform.rotate(
                  angle: 12 * 3.14159 / 180,
                  child: Icon(
                    Icons.eco,
                    size: 24,
                    color: AppColors.accent.withAlpha(76),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Wording message requested
        const Text(
          "We can't add your word to the collection right now.",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Try Again Button
        ElevatedButton(
          onPressed: () {
            setState(() {
              _errorMessage = null; // resets back to form view
            });
          },
          child: const Text('Try Again'),
        ),
        const SizedBox(height: 16),
        // Check Connect text link
        Center(
          child: TextButton(
            onPressed: _showErrorDetailsDialog,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Check Connection',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;
    if (_isSuccess) {
      currentWidget = _buildSuccessView();
    } else if (_errorMessage != null) {
      currentWidget = _buildErrorView();
    } else {
      currentWidget = _buildFormView();
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: currentWidget,
      ),
    );
  }
}
