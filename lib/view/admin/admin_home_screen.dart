import 'package:bnultrasoft/view/admin/manage_categories_screen.dart';
import 'package:bnultrasoft/view/admin/manage_quizes_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../model/quiz.dart';
import '../../theme/theme.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchStatistics() async {
    final categoriesCount = await _firestore
        .collection('categories')
        .count()
        .get();

    final quizzesCount = await _firestore.collection('quizzes').count().get();

    // get latest quizzes
    final latestQuizzes = await _firestore
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    final categories = await _firestore.collection('categories').get();

    final categoryData = await Future.wait(
      categories.docs.map((category) async {
        final quizCount = await _firestore
            .collection('quizzes')
            .where('categoryId', isEqualTo: category.id)
            .count()
            .get();

        return {
          'name': category.data()['name'] as String,
          'count': quizCount.count,
        };
      }),
    );

    return {
      'categoriesCount': categoriesCount.count,
      'quizzesCount': quizzesCount.count,
      'latestQuizzes': latestQuizzes.docs
          .map((doc) => Quiz.fromMap(doc.id, doc.data()))
          .toList(),
      'categoryData': categoryData,
    };
  }

  String _formatDate(DateTime date) {
    // Check for null date before formatting
    return date.isAtSameMomentAs(DateTime(0))
        ? 'N/A'
        : '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ), // BoxDecoration
              child: Icon(icon, color: color, size: 25),
            ), // Container

            SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ), // TextStyle
            ), // Text

            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ), // TextStyle
            ), // Text
          ],
        ), // Column
      ), // Padding
    ); // Card
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ), // BoxDecoration
                child: Icon(icon, color: AppTheme.primaryColor, size: 32),
              ), // Container

              SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ), // TextStyle
              ), // Text
            ],
          ), // Column
        ), // Padding
      ), // InkWell
    ); // Card
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold), // TextStyle
        ), // Text
        elevation: 0,
      ), // AppBar
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ), // CircularProgressIndicator
            ); // Center
          }

          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}')); // Center
          }

          final Map<String, dynamic> stats = snapshot.data!;
          final List<dynamic> categoryData = stats['categoryData'];

          final List<Quiz> latestQuizzes = (stats['latestQuizzes'] as List)
              .cast<Quiz>();

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Admin",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ), // TextStyle
                  ), // Text
                  SizedBox(height: 8),
                  Text(
                    "Here's your quiz application overview",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ), // TextStyle
                  ), // Text
                  SizedBox(height: 24),
                  // Row of Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Categories',
                          stats['categoriesCount'].toString(),
                          Icons.category_rounded,
                          AppTheme.primaryColor,
                        ), // _buildStatCard
                      ), // Expanded
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Total Quizzes',
                          stats['quizzesCount'].toString(),
                          Icons.quiz_rounded,
                          AppTheme.secondaryColor,
                        ), // _buildStatCard
                      ), // Expanded
                    ],
                  ), // Row
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart_rounded,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Category Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: categoryData.length,
                            itemBuilder: (context, index) {
                              final category = categoryData[index];
                              final totalQuizzes = categoryData.fold<int>(
                                0,
                                    (sum, item) => sum + (item['count'] as int),
                              );

                              final percentage = totalQuizzes > 0
                                  ? (category['count'] as int) /
                                  totalQuizzes *
                                  100
                                  : 0.0;

                              return Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category['name'] as String,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textPrimaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "${category['count']} ${(category['count'] as int) == 1 ? 'quiz' : 'quizzes'}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color:
                                              AppTheme.textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ); //
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: latestQuizzes.length,
                            itemBuilder: (context, index) {
                              final Quiz quiz = latestQuizzes[index];

                              return Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.quiz_rounded,
                                        color: AppTheme.primaryColor,
                                        size:20,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              quiz.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimaryColor,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              _formatDate(quiz.createdAt ?? DateTime.now()),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textSecondaryColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                              ); //
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Quiz Actions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            // *** FIX APPLIED HERE: Reduce childAspectRatio to prevent overflow ***
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 16,
                            children: [
                              _buildDashboardCard(
                                title: 'Quizzes',
                                icon: Icons.quiz_rounded,
                                onTap: (){
                                  Navigator.push(
                                      context,MaterialPageRoute(
                                      builder: (context)=>
                                          ManageQuizzesScreen()));
                                },
                              ),
                              _buildDashboardCard(
                                title: 'Categories',
                                icon: Icons.category_rounded,
                                onTap: (){
                                  Navigator.push(
                                      context,MaterialPageRoute(
                                      builder: (context)=>
                                          ManageCategoriesScreen()));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Extra space at the bottom to ensure the last card isn't cut off by the screen edge/notch
                  SizedBox(height: 20),
                ],
              ), // Column
            ), // SingleChildScrollView
          ); // SafeArea
        }, // builder
      ), // FutureBuilder
    ); // Scaffold
  }
}