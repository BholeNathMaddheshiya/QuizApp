import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quiz_model.dart';
import '../models/question_model.dart';
import '../models/result_model.dart';

class QuizStateProvider extends ChangeNotifier {
  QuizModel? _currentQuiz;
  int _currentQuestionIndex = 0;
  List<int?> _userAnswers = [];
  int _remainingTimeInSeconds = 0;
  Timer? _timer;
  DateTime? _startTime;
  bool _isQuizCompleted = false;

  // Getters
  QuizModel? get currentQuiz => _currentQuiz;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<int?> get userAnswers => _userAnswers;
  int get remainingTimeInSeconds => _remainingTimeInSeconds;
  bool get isQuizCompleted => _isQuizCompleted;

  QuestionModel? get currentQuestion {
    if (_currentQuiz == null) return null;
    if (_currentQuestionIndex >= _currentQuiz!.questions.length) return null;
    return _currentQuiz!.questions[_currentQuestionIndex];
  }

  int? get currentAnswer => _userAnswers.isNotEmpty &&
      _currentQuestionIndex < _userAnswers.length
      ? _userAnswers[_currentQuestionIndex]
      : null;

  // Start quiz
  void startQuiz(QuizModel quiz) {
    _currentQuiz = quiz;
    _currentQuestionIndex = 0;
    _userAnswers = List.filled(quiz.questions.length, null);
    _remainingTimeInSeconds = quiz.totalTimeInSeconds;
    _startTime = DateTime.now();
    _isQuizCompleted = false;

    _startTimer();
    notifyListeners();
  }

  // Start timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTimeInSeconds > 0) {
        _remainingTimeInSeconds--;
        notifyListeners();
      } else {
        completeQuiz();
      }
    });
  }

  // Select answer
  void selectAnswer(int optionIndex) {
    if (_currentQuestionIndex < _userAnswers.length) {
      _userAnswers[_currentQuestionIndex] = optionIndex;
      notifyListeners();
    }
  }

  // Next question
  void nextQuestion() {
    if (_currentQuiz == null) return;

    if (_currentQuestionIndex < _currentQuiz!.questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    } else {
      completeQuiz();
    }
  }

  // Complete quiz
  void completeQuiz() {
    _timer?.cancel();
    _isQuizCompleted = true;
    notifyListeners();
  }

  // Calculate result
  QuizResult calculateResult() {
    if (_currentQuiz == null || _startTime == null) {
      throw Exception('Quiz not started');
    }

    int correctAnswers = 0;
    List<UserAnswer> userAnswersList = [];

    for (int i = 0; i < _currentQuiz!.questions.length; i++) {
      QuestionModel question = _currentQuiz!.questions[i];
      int? userAnswer = _userAnswers[i];

      bool isCorrect = userAnswer != null && question.isCorrect(userAnswer);

      if (isCorrect) correctAnswers++;

      userAnswersList.add(UserAnswer(
        questionIndex: i,
        questionText: question.questionText,
        selectedOption: userAnswer ?? -1,
        correctOption: question.correctAnswerIndex,
        options: question.options,
        isCorrect: isCorrect,
      ));
    }

    int timeTaken = _currentQuiz!.totalTimeInSeconds - _remainingTimeInSeconds;

    return QuizResult(
      quizId: _currentQuiz!.id,
      quizTitle: _currentQuiz!.title,
      totalQuestions: _currentQuiz!.questions.length,
      correctAnswers: correctAnswers,
      wrongAnswers: _currentQuiz!.questions.length - correctAnswers,
      timeTakenInSeconds: timeTaken,
      userAnswers: userAnswersList,
      completedAt: DateTime.now(),
    );
  }

  // Format time
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Reset quiz
  void resetQuiz() {
    _timer?.cancel();
    _currentQuiz = null;
    _currentQuestionIndex = 0;
    _userAnswers = [];
    _remainingTimeInSeconds = 0;
    _startTime = null;
    _isQuizCompleted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}