import 'package:flutter/material.dart';

class HexagonButton extends StatelessWidget {
  final String label;
  final String text;
  final VoidCallback onTap;
  final Color fillColor;
  final Color borderColor;
  final bool isQuestion;

  const HexagonButton({
    super.key,
    required this.text,
    this.label = '',
    required this.onTap,
    required this.fillColor,
    required this.borderColor,
    this.isQuestion = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isHighlighted = fillColor != Colors.black && fillColor != const Color(0xFF000000);
    
    // For normal options (non-highlighted), use the default 3D pill colors.
    // If highlighted (e.g. correct/wrong/selected), use the provided fillColor as the base.
    List<Color> gradientColors;
    if (isQuestion) {
      gradientColors = [const Color(0xFF081221), const Color(0xFF081221)];
    } else if (!isHighlighted) {
      gradientColors = [
        const Color(0xFF1F5EFF), // İç Gövde Üst
        const Color(0xFF163D8C), // Orta
        const Color(0xFF0A1738), // Alt
      ];
    } else {
      gradientColors = [
        fillColor.withAlpha(200),
        fillColor,
      ];
    }

    Color effectiveBorderColor = isQuestion ? borderColor : (isHighlighted ? borderColor : const Color(0xFF00A8FF));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isQuestion ? 16.0 : 16.0,
          vertical: isQuestion ? 16.0 : 12.0,
        ),
        decoration: BoxDecoration(
          color: isQuestion ? const Color(0xFF081221) : null,
          gradient: isQuestion ? null : LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(isQuestion ? 20 : 20),
          border: Border.all(color: effectiveBorderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: effectiveBorderColor.withValues(alpha: 0.3), 
              blurRadius: 10,
            ),
          ],
        ),
        child: isQuestion
            ? Center(
                child: SingleChildScrollView(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1,1))],
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  if (label.isNotEmpty)
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFFFFC400),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        shadows: [Shadow(color: Color(0xFF7A5200), offset: Offset(1, 1), blurRadius: 2)],
                      ),
                    ),
                  if (label.isNotEmpty)
                    const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1,1))],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
