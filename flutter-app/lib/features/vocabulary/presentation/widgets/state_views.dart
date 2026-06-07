import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../core/theme/app_colors.dart';

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SpinKitPulse(
        color: AppColors.primary,
        size: 80.0,
      ),
    );
  }
}

class ErrorStateView extends StatefulWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  State<ErrorStateView> createState() => _ErrorStateViewState();
}

class _ErrorStateViewState extends State<ErrorStateView> with SingleTickerProviderStateMixin {
  bool _isRetrying = false;
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _handleRetry() {
    if (_isRetrying) return;
    setState(() {
      _isRetrying = true;
    });
    _spinController.repeat();

    // Trigger retry callback
    widget.onRetry();

    // Reset local spinner state after a short delay (in case the refetch completes instantly)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _spinController.stop();
        setState(() {
          _isRetrying = false;
        });
      }
    });
  }

  void _showErrorDetails() {
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
                widget.message.isNotEmpty ? widget.message : 'Unknown connection error.',
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visual Illustration Area
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Decorative Soft Glow Circle
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryContainer.withAlpha(25),
                        AppColors.primaryContainer.withAlpha(0),
                      ],
                    ),
                  ),
                ),
                // Central Iconography Box
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: AppColors.cardBorder,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryContainer.withAlpha(30),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cloud_off,
                    size: 80,
                    color: AppColors.primaryContainer,
                  ),
                ),
                // Floating Leaf/Air Elements
                Positioned(
                  top: -8,
                  right: -8,
                  child: Transform.rotate(
                    angle: 12 * 3.14159 / 180,
                    child: Icon(
                      Icons.eco,
                      size: 32,
                      color: AppColors.accent.withAlpha(76),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -4,
                  left: -8,
                  child: Transform.rotate(
                    angle: -12 * 3.14159 / 180,
                    child: Icon(
                      Icons.air,
                      size: 24,
                      color: AppColors.primary.withAlpha(50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Text Content
            Text(
              "Oops! We couldn't fetch your words.",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                "A small breeze blew us off track. Let's try to reconnect and get your learning back on pace.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // Action Buttons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Retry Button
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _handleRetry,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RotationTransition(
                          turns: _spinController,
                          child: const Icon(Icons.refresh, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(_isRetrying ? 'Fetching...' : 'Retry'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Check Connection / Details Button
                TextButton(
                  onPressed: _showErrorDetails,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateView extends StatefulWidget {
  final VoidCallback onAddPressed;

  const EmptyStateView({super.key, required this.onAddPressed});

  @override
  State<EmptyStateView> createState() => _EmptyStateViewState();
}

class _EmptyStateViewState extends State<EmptyStateView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration Area with Glow
            Stack(
              alignment: Alignment.center,
              children: [
                // Soft glow background
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryContainer.withAlpha(25), // Soft glow
                        AppColors.primaryContainer.withAlpha(0),
                      ],
                    ),
                  ),
                ),
                // Floating Bird Illustration
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _animation.value),
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/bird_nest.png',
                    width: 240,
                    height: 240,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        color: AppColors.cardBorder,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.book_outlined,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Text Content
            Text(
              "Your vocabulary is looking a bit light!",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                "Start collecting new words and phrases to build your language nest. Every word counts!",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // Call to Action Button
            ElevatedButton.icon(
              onPressed: widget.onAddPressed,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add your first word'),
              style: ElevatedButton.styleFrom(
                shadowColor: AppColors.primaryContainer.withAlpha(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoSearchResultsView extends StatelessWidget {
  final VoidCallback onClearPressed;

  const NoSearchResultsView({super.key, required this.onClearPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Visual Illustration Area
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Soft glow background
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryContainer.withAlpha(20),
                        AppColors.primaryContainer.withAlpha(0),
                      ],
                    ),
                  ),
                ),
                // Inner box containing search icon
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
                        color: AppColors.primaryContainer.withAlpha(15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.search_off,
                    size: 56,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Messaging
            Text(
              "No matches found",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppColors.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                "We couldn't find any words matching your search query. Try typing something else!",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // Actions
            ElevatedButton(
              onPressed: onClearPressed,
              child: const Text('Clear Search'),
            ),
          ],
        ),
      ),
    );
  }
}
