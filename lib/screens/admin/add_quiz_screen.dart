import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../models/category_model.dart';
import '../../models/quiz_model.dart';
import '../../models/question_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/gradient_button.dart';

class AddQuizScreen extends StatefulWidget {
  final QuizModel? quiz;

  const AddQuizScreen({Key? key, this.quiz}) : super(key: key);

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  List<CategoryModel> _categories = [];
  List<QuestionData> _questions = [];
  bool _isLoading = false;
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (widget.quiz != null) {
      _titleController.text = widget.quiz!.title;
      _timeController.text = widget.quiz!.timeInMinutes.toString();
      _selectedCategoryId = widget.quiz!.categoryId;
      _selectedCategoryName = widget.quiz!.categoryName;

      _questions = widget.quiz!.questions.map((q) => QuestionData(
        questionText: q.questionText,
        options: List.from(q.options),
        correctAnswerIndex: q.correctAnswerIndex,
      )).toList();
    } else {
      _addNewQuestion();
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _loadingCategories = true);
    _firestoreService.getCategories().listen((categories) {
      setState(() {
        _categories = categories;
        _loadingCategories = false;
      });
    });
  }

  void _addNewQuestion() {
    setState(() {
      _questions.add(QuestionData(
        questionText: '',
        options: ['', '', '', ''],
        correctAnswerIndex: 0,
      ));
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one question'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    // Validate questions
    for (int i = 0; i < _questions.length; i++) {
      if (_questions[i].questionText.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Question ${i + 1} text is required'),
            backgroundColor: AppColors.errorRed,
          ),
        );
        return;
      }
      for (int j = 0; j < 4; j++) {
        if (_questions[i].options[j].trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Question ${i + 1}, Option ${j + 1} is required'),
              backgroundColor: AppColors.errorRed,
            ),
          );
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      List<QuestionModel> questions = _questions.map((q) => QuestionModel(
        questionText: q.questionText.trim(),
        options: q.options.map((o) => o.trim()).toList(),
        correctAnswerIndex: q.correctAnswerIndex,
      )).toList();

      if (widget.quiz == null) {
        final newQuiz = QuizModel(
          id: '',
          title: _titleController.text.trim(),
          categoryId: _selectedCategoryId!,
          categoryName: _selectedCategoryName!,
          timeInMinutes: int.parse(_timeController.text.trim()),
          questions: questions,
          createdAt: DateTime.now(),
        );

        final quizId = await _firestoreService.addQuiz(newQuiz);

        if (quizId != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz added successfully!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final updatedQuiz = QuizModel(
          id: widget.quiz!.id,
          title: _titleController.text.trim(),
          categoryId: _selectedCategoryId!,
          categoryName: _selectedCategoryName!,
          timeInMinutes: int.parse(_timeController.text.trim()),
          questions: questions,
          createdAt: widget.quiz!.createdAt,
        );

        final success = await _firestoreService.updateQuiz(
          widget.quiz!.id,
          updatedQuiz,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz updated successfully!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
        title: Text(
          widget.quiz == null ? 'Add Quiz' : 'Edit Quiz',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: AppColors.primaryPurple),
            onPressed: _saveQuiz,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quiz Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quiz Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quiz Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Quiz Name',
                        prefixIcon: Icon(Icons.quiz),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter quiz name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    _loadingCategories
                        ? const CircularProgressIndicator()
                        : DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Select Category',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                          _selectedCategoryName = _categories
                              .firstWhere((c) => c.id == value)
                              .name;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Time in Minutes
                    TextFormField(
                      controller: _timeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Time (in minutes)',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter time';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Questions Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addNewQuestion,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Question'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Questions List
              ..._questions.asMap().entries.map((entry) {
                int index = entry.key;
                QuestionData question = entry.value;
                return _buildQuestionCard(index, question);
              }).toList(),

              const SizedBox(height: 24),

              // Save Button
              GradientButton(
                text: widget.quiz == null ? 'Save Quiz' : 'Update Quiz',
                icon: Icons.save,
                isLoading: _isLoading,
                onPressed: _saveQuiz,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index, QuestionData question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_questions.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.errorRed),
                  onPressed: () => _removeQuestion(index),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Question Text
          TextFormField(
            initialValue: question.questionText,
            decoration: const InputDecoration(
              labelText: 'Question Title',
              prefixIcon: Icon(Icons.help_outline),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            onChanged: (value) {
              question.questionText = value;
            },
          ),
          const SizedBox(height: 16),

          // Options
          ...List.generate(4, (optionIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Radio<int>(
                    value: optionIndex,
                    groupValue: question.correctAnswerIndex,
                    onChanged: (value) {
                      setState(() {
                        question.correctAnswerIndex = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: question.options[optionIndex],
                      decoration: InputDecoration(
                        labelText: 'Option ${optionIndex + 1}',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        question.options[optionIndex] = value;
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}

class QuestionData {
  String questionText;
  List<String> options;
  int correctAnswerIndex;

  QuestionData({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });
}