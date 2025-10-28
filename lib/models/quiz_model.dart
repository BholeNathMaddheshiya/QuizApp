import 'package:cloud_firestore/cloud_firestore.dart';
import 'question_model.dart';

class QuizModel {
  final String id;
  final String title;
  final String categoryId;
  final String categoryName;
  final int timeInMinutes;
  final List<QuestionModel> questions;
  final DateTime createdAt;

  QuizModel({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    required this.timeInMinutes,
    required this.questions,
    required this.createdAt,
  });

  int get questionCount => questions.length;
  int get totalTimeInSeconds => timeInMinutes * 60;

  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<QuestionModel> questionsList = [];
    if (data['questions'] != null) {
      questionsList = (data['questions'] as List)
          .map((q) => QuestionModel.fromMap(q as Map<String, dynamic>))
          .toList();
    }

    return QuizModel(
      id: doc.id,
      title: data['title'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      timeInMinutes: data['timeInMinutes'] ?? 5,
      questions: questionsList,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'timeInMinutes': timeInMinutes,
      'questionCount': questionCount,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}