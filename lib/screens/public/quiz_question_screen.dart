import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/colors.dart';
import '../../providers/quiz_state_provider.dart';
import '../../widgets/option_button.dart';
import '../../widgets/gradient_button.dart';
import 'quiz_result_screen_with_ad.dart';

class QuizQuestionScreen extends StatelessWidget {
  const QuizQuestionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await _showExitDialog(context);
        return shouldExit;
      },
      child: Consumer<QuizStateProvider>(
        builder: (context, quizState, child) {
          if (quizState.currentQuiz == null || quizState.currentQuestion == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () async {
                  bool shouldExit = await _showExitDialog(context);
                  if (shouldExit && context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time, size: 20, color: AppColors.primaryPurple),
                  const SizedBox(width: 8),
                  Text(
                    quizState.formatTime(quizState.remainingTimeInSeconds),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              actions: const [SizedBox(width: 48)],
            ),
            body: Column(
              children: [
                // Progress Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Question ${quizState.currentQuestionIndex + 1}/${quizState.currentQuiz!.questionCount}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${((quizState.currentQuestionIndex + 1) / quizState.currentQuiz!.questionCount * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (quizState.currentQuestionIndex + 1) /
                              quizState.currentQuiz!.questionCount,
                          backgroundColor: AppColors.backgroundColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryPurple,
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                // Question and Options
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
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
                          child: Text(
                            quizState.currentQuestion!.questionText,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...List.generate(
                          quizState.currentQuestion!.options.length,
                              (index) => OptionButton(
                            option: quizState.currentQuestion!.options[index],
                            index: index,
                            isSelected: quizState.currentAnswer == index,
                            onTap: () {
                              quizState.selectAnswer(index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Next Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: GradientButton(
                      text: quizState.currentQuestionIndex ==
                          quizState.currentQuiz!.questionCount - 1
                          ? 'Finish Quiz'
                          : 'Next Question',
                      icon: Icons.arrow_forward,
                      onPressed: quizState.currentAnswer != null
                          ? () {
                        if (quizState.currentQuestionIndex ==
                            quizState.currentQuiz!.questionCount - 1) {
                          quizState.completeQuiz();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizResultScreenWithAd(
                                result: quizState.calculateResult(),
                              ),
                            ),
                          );
                        } else {
                          quizState.nextQuestion();
                        }
                      }
                          : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select an answer'),
                            backgroundColor: AppColors.errorRed,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Are you sure you want to exit? Your progress will be lost.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<QuizStateProvider>(context, listen: false).resetQuiz();
              Navigator.pop(context, true);
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}