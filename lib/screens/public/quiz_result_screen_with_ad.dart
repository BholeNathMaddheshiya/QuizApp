import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/colors.dart';
import '../../models/result_model.dart';
import '../../services/admob_service.dart';
import '../../widgets/gradient_button.dart';
import 'detailed_analysis_screen.dart';
import 'start_quiz_screen.dart';

class QuizResultScreenWithAd extends StatefulWidget {
  final QuizResult result;

  const QuizResultScreenWithAd({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  State<QuizResultScreenWithAd> createState() => _QuizResultScreenWithAdState();
}

class _QuizResultScreenWithAdState extends State<QuizResultScreenWithAd> {
  final AdMobService _adMobService = AdMobService();
  bool _showResults = false;
  bool _isLoadingAd = true;
  bool _adFailed = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    setState(() {
      _isLoadingAd = true;
      _adFailed = false;
    });

    try {
      await _adMobService.loadRewardedAd();
      setState(() {
        _isLoadingAd = false;
      });
    } catch (e) {
      print('❌ Ad load error: $e');
      setState(() {
        _isLoadingAd = false;
        _adFailed = true;
      });
    }
  }

  Future<void> _watchAdAndShowResults() async {
    if (_isLoadingAd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad is still loading, please wait...'),
          backgroundColor: AppColors.warningYellow,
        ),
      );
      return;
    }

    if (_adFailed || !_adMobService.isAdLoaded) {
      // If ad failed, show results anyway
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad not available. Showing results...'),
          backgroundColor: AppColors.warningYellow,
        ),
      );
      setState(() {
        _showResults = true;
      });
      return;
    }

    // Show ad
    bool adWatched = await _adMobService.showRewardedAd();

    if (adWatched || mounted) {
      setState(() {
        _showResults = true;
      });
    }
  }

  @override
  void dispose() {
    _adMobService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const StartQuizScreen()),
              (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const StartQuizScreen()),
                    (route) => false,
              );
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 20, color: AppColors.primaryPurple),
              const SizedBox(width: 8),
              Text(
                widget.result.formattedTimeTaken,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: const [SizedBox(width: 48)],
        ),
        body: _showResults ? _buildResultsView() : _buildAdPromptView(),
      ),
    );
  }

  Widget _buildAdPromptView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_circle_outline,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Quiz Completed!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Watch a short video to see your results',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          if (_isLoadingAd) ...[
            const CircularProgressIndicator(
              color: AppColors.primaryPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading ad...',
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ] else ...[
            GradientButton(
              text: _adFailed ? 'View Results' : 'Watch Ad & View Results',
              icon: _adFailed ? Icons.arrow_forward : Icons.play_arrow,
              onPressed: _watchAdAndShowResults,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _showResults = true;
                });
              },
              child: const Text(
                'Skip Ad (If Available)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Quiz Result',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          // Circular Progress
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: CircularProgressPainter(
                percentage: widget.result.percentage,
                color: _getPerformanceColor(widget.result.percentage),
              ),
              child: Center(
                child: Text(
                  '${widget.result.percentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getPerformanceColor(widget.result.percentage),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Performance Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _getPerformanceColor(widget.result.percentage).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getPerformanceIcon(widget.result.percentage),
                  color: _getPerformanceColor(widget.result.percentage),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.result.performanceLevel,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getPerformanceColor(widget.result.percentage),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Score Breakdown
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildScoreItem(
                    'Correct',
                    widget.result.correctAnswers,
                    AppColors.successGreen,
                    Icons.check_circle,
                  ),
                ),
                Container(width: 1, height: 60, color: AppColors.backgroundColor),
                Expanded(
                  child: _buildScoreItem(
                    'Wrong',
                    widget.result.wrongAnswers,
                    AppColors.errorRed,
                    Icons.cancel,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Detailed Analysis',
            icon: Icons.analytics,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailedAnalysisScreen(
                    result: widget.result,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const StartQuizScreen()),
                    (route) => false,
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              side: const BorderSide(color: AppColors.primaryPurple, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Try Again',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, int value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Color _getPerformanceColor(double percentage) {
    if (percentage >= 80) return AppColors.successGreen;
    if (percentage >= 50) return AppColors.warningYellow;
    return AppColors.errorRed;
  }

  IconData _getPerformanceIcon(double percentage) {
    if (percentage >= 80) return Icons.emoji_events;
    if (percentage >= 50) return Icons.thumb_up;
    return Icons.restart_alt;
  }
}

class CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color color;

  CircularProgressPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = AppColors.backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}