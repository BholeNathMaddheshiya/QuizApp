import 'package:flutter/material.dart';
import '../config/colors.dart';

class OptionButton extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final bool? isCorrect;
  final bool isReviewMode;

  const OptionButton({
    Key? key,
    required this.option,
    required this.index,
    required this.isSelected,
    required this.onTap,
    this.isCorrect,
    this.isReviewMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isReviewMode) {
      if (isSelected && isCorrect == true) {
        backgroundColor = AppColors.successGreen.withOpacity(0.1);
        borderColor = AppColors.successGreen;
        textColor = AppColors.successGreen;
      } else if (isSelected && isCorrect == false) {
        backgroundColor = AppColors.errorRed.withOpacity(0.1);
        borderColor = AppColors.errorRed;
        textColor = AppColors.errorRed;
      } else if (!isSelected && isCorrect == true) {
        backgroundColor = AppColors.successGreen.withOpacity(0.1);
        borderColor = AppColors.successGreen;
        textColor = AppColors.successGreen;
      } else {
        backgroundColor = AppColors.backgroundColor;
        borderColor = AppColors.textLight;
        textColor = AppColors.textPrimary;
      }
    } else {
      if (isSelected) {
        backgroundColor = AppColors.primaryPurple.withOpacity(0.1);
        borderColor = AppColors.primaryPurple;
        textColor = AppColors.primaryPurple;
      } else {
        backgroundColor = AppColors.backgroundColor;
        borderColor = AppColors.textLight;
        textColor = AppColors.textPrimary;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isReviewMode ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2),
                    color: isSelected ? borderColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ),
                if (isReviewMode && isSelected) ...[
                  Icon(
                    isCorrect == true ? Icons.check_circle : Icons.cancel,
                    color: isCorrect == true
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}