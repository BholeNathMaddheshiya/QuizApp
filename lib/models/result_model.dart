class QuizResult {
  final String quizId;
  final String quizTitle;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeTakenInSeconds;
  final List<UserAnswer> userAnswers;
  final DateTime completedAt;

  QuizResult({
    required this.quizId,
    required this.quizTitle,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeTakenInSeconds,
    required this.userAnswers,
    required this.completedAt,
  });

  double get percentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

  String get performanceLevel {
    if (percentage >= 80) return 'Outstanding!';
    if (percentage >= 50) return 'Good Effort!';
    return 'Keep Learning!';
  }

  String get formattedTimeTaken {
    final minutes = timeTakenInSeconds ~/ 60;
    final seconds = timeTakenInSeconds % 60;
    return '$minutes mins ${seconds}s';
  }
}

class UserAnswer {
  final int questionIndex;
  final String questionText;
  final int selectedOption;
  final int correctOption;
  final List<String> options;
  final bool isCorrect;

  UserAnswer({
    required this.questionIndex,
    required this.questionText,
    required this.selectedOption,
    required this.correctOption,
    required this.options,
    required this.isCorrect,
  });

  String get selectedAnswerText =>
      selectedOption >= 0 && selectedOption < options.length
          ? options[selectedOption]
          : 'Not answered';

  String get correctAnswerText => options[correctOption];
}