import 'package:flutter/material.dart';
import 'dart:math' as math;

class PhoneCallDialog extends StatefulWidget {
  final String correctOption;
  final String avatarPath;
  
  const PhoneCallDialog({super.key, required this.correctOption, required this.avatarPath});

  @override
  State<PhoneCallDialog> createState() => _PhoneCallDialogState();
}

class _PhoneCallDialogState extends State<PhoneCallDialog> {
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.2), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Telefon Jokeri',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (_isConnecting) ...[
              const CircularProgressIndicator(color: Colors.blueAccent),
              const SizedBox(height: 16),
              const Text('Aranıyor...', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ] else ...[
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blueAccent,
                backgroundImage: AssetImage(widget.avatarPath),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'Dostum eminim, cevap kesinlikle "${widget.correctOption}"!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontStyle: FontStyle.italic),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isConnecting ? null : () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Kapat', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class AudienceChartDialog extends StatefulWidget {
  final int correctOptionIndex;
  final List<String> options;

  const AudienceChartDialog({
    super.key,
    required this.correctOptionIndex,
    required this.options,
  });

  @override
  State<AudienceChartDialog> createState() => _AudienceChartDialogState();
}

class _AudienceChartDialogState extends State<AudienceChartDialog> {
  List<int> _currentPercentages = [0, 0, 0, 0];
  List<int> _targetPercentages = [0, 0, 0, 0];
  bool _isVoting = true;

  @override
  void initState() {
    super.initState();
    _calculateTargetPercentages();
    
    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isVoting = false;
          _currentPercentages = _targetPercentages;
        });
      }
    });
  }

  void _calculateTargetPercentages() {
    final random = math.Random();
    _targetPercentages = [0, 0, 0, 0];
    
    // Correct answer gets 60-80%
    _targetPercentages[widget.correctOptionIndex] = 60 + random.nextInt(21);
    
    // Distribute remaining
    int remaining = 100 - _targetPercentages[widget.correctOptionIndex];
    List<int> otherIndices = [0, 1, 2, 3]..remove(widget.correctOptionIndex);
    
    _targetPercentages[otherIndices[0]] = random.nextInt(remaining);
    remaining -= _targetPercentages[otherIndices[0]];
    
    _targetPercentages[otherIndices[1]] = random.nextInt(remaining);
    remaining -= _targetPercentages[otherIndices[1]];
    
    _targetPercentages[otherIndices[2]] = remaining;
  }

  @override
  Widget build(BuildContext context) {
    List<String> labels = ['A', 'B', 'C', 'D'];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 420,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.blueAccent.withValues(alpha: 0.2), blurRadius: 20),
          ],
        ),
        child: Column(
          children: [
            Text(
              _isVoting ? 'Oylar Sayılıyor...' : 'Seyirci Oylaması',
              style: TextStyle(
                color: _isVoting ? Colors.orangeAccent : Colors.white, 
                fontSize: 24, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (_isVoting) 
              const LinearProgressIndicator(color: Colors.orangeAccent),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(4, (index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedOpacity(
                        opacity: _isVoting ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: _currentPercentages[index].toDouble()),
                          duration: const Duration(milliseconds: 2500),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Text(
                              '%${value.toInt()}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 2500),
                        curve: Curves.easeOutCubic,
                        width: 45,
                        height: (_currentPercentages[index] / 100) * 140, // max 140px height
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.blueAccent, Colors.indigo],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (!_isVoting)
                              BoxShadow(
                                color: Colors.blueAccent.withValues(alpha: 0.6),
                                blurRadius: 15,
                                spreadRadius: 3,
                              )
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          labels[index],
                          style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isVoting ? null : () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text('TAMAM', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
