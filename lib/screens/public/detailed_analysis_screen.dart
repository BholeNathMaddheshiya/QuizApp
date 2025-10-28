import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../models/result_model.dart';
import '../../widgets/option_button.dart';
import '../../widgets/gradient_button.dart';
import 'start_quiz_screen.dart';

class DetailedAnalysisScreen extends StatelessWidget {
  final QuizResult result;

  const DetailedAnalysisScreen({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detailed Analysis',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: result.userAnswers.length,
              itemBuilder: (context, index) {
                UserAnswer answer = result.userAnswers[index];
                return _buildQuestionCard(answer, index);
              },
            ),
          ),
          // Try Again Button
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
                text: 'Try Again',
                icon: Icons.restart_alt,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const StartQuizScreen()),
                        (route) => false,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(UserAnswer answer, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: answer.isCorrect
              ? AppColors.successGreen.withOpacity(0.3)
              : AppColors.errorRed.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: answer.isCorrect
                  ? AppColors.successGreen.withOpacity(0.1)
                  : AppColors.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              answer.isCorrect ? Icons.check : Icons.close,
              color: answer.isCorrect
                  ? AppColors.successGreen
                  : AppColors.errorRed,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'Question ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                answer.isCorrect ? Icons.check_circle : Icons.cancel,
                color: answer.isCorrect
                    ? AppColors.successGreen
                    : AppColors.errorRed,
                size: 24,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              answer.questionText,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          children: [
            const Divider(height: 24),
            // Show all options
            ...List.generate(
              answer.options.length,
                  (optionIndex) {
                bool isUserAnswer = optionIndex == answer.selectedOption;
                bool isCorrectAnswer = optionIndex == answer.correctOption;

                return OptionButton(
                  option: answer.options[optionIndex],
                  index: optionIndex,
                  isSelected: isUserAnswer,
                  isCorrect: isCorrectAnswer,
                  isReviewMode: true,
                  onTap: () {},
                );
              },
            ),
            // Explanation section
            if (!answer.isCorrect) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.successGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Correct Answer',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.successGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            answer.correctAnswerText,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}