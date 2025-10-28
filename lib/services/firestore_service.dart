import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/quiz_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== CATEGORIES ==========

  Stream<List<CategoryModel>> getCategories() {
    return _firestore
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc))
        .toList());
  }

  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('categories').doc(id).get();
      if (doc.exists) {
        return CategoryModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting category: $e');
      return null;
    }
  }

  Future<String?> addCategory(CategoryModel category) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('categories')
          .add(category.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding category: $e');
      return null;
    }
  }

  Future<bool> updateCategory(String id, CategoryModel category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(id)
          .update(category.toFirestore());
      return true;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _firestore.collection('categories').doc(id).delete();

      // Delete all quizzes in this category
      QuerySnapshot quizzes = await _firestore
          .collection('quizzes')
          .where('categoryId', isEqualTo: id)
          .get();

      for (var doc in quizzes.docs) {
        await doc.reference.delete();
      }

      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // ========== QUIZZES ==========

  Stream<List<QuizModel>> getAllQuizzes() {
    return _firestore
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => QuizModel.fromFirestore(doc))
        .toList());
  }

  Stream<List<QuizModel>> getQuizzesByCategory(String categoryId) {
    return _firestore
        .collection('quizzes')
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => QuizModel.fromFirestore(doc))
        .toList());
  }

  Future<QuizModel?> getQuizById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('quizzes').doc(id).get();
      if (doc.exists) {
        return QuizModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting quiz: $e');
      return null;
    }
  }

  Future<String?> addQuiz(QuizModel quiz) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('quizzes')
          .add(quiz.toFirestore());

      // Update category quiz count
      await _updateCategoryQuizCount(quiz.categoryId);

      return docRef.id;
    } catch (e) {
      print('Error adding quiz: $e');
      return null;
    }
  }

  Future<bool> updateQuiz(String id, QuizModel quiz) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(id)
          .update(quiz.toFirestore());
      return true;
    } catch (e) {
      print('Error updating quiz: $e');
      return false;
    }
  }

  Future<bool> deleteQuiz(String id, String categoryId) async {
    try {
      await _firestore.collection('quizzes').doc(id).delete();
      await _updateCategoryQuizCount(categoryId);
      return true;
    } catch (e) {
      print('Error deleting quiz: $e');
      return false;
    }
  }

  // ========== STATISTICS ==========

  Future<int> getTotalCategoriesCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting categories count: $e');
      return 0;
    }
  }

  Future<int> getTotalQuizzesCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('quizzes').get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting quizzes count: $e');
      return 0;
    }
  }

  Future<List<QuizModel>> getRecentQuizzes({int limit = 5}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('quizzes')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => QuizModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting recent quizzes: $e');
      return [];
    }
  }

  // ========== HELPER METHODS ==========

  Future<void> _updateCategoryQuizCount(String categoryId) async {
    try {
      QuerySnapshot quizzes = await _firestore
          .collection('quizzes')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      await _firestore
          .collection('categories')
          .doc(categoryId)
          .update({'quizCount': quizzes.docs.length});
    } catch (e) {
      print('Error updating category quiz count: $e');
    }
  }
}