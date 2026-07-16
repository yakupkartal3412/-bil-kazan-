import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:milyarder_test_oyunu/utils/constants.dart';
import 'package:milyarder_test_oyunu/services/referral_service.dart';
import 'package:milyarder_test_oyunu/providers/quiz_provider.dart';
import 'package:provider/provider.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({Key? key}) : super(key: key);

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  final ReferralService _referralService = ReferralService();
  final TextEditingController _codeController = TextEditingController();
  
  bool _isLoading = false;
  String? _myReferralCode;

  @override
  void initState() {
    super.initState();
    _loadMyCode();
  }
  
  Future<void> _loadMyCode() async {
    final code = await _referralService.getOrCreateReferralCode();
    if (mounted) {
      setState(() {
        _myReferralCode = code;
      });
    }
  }

  void _copyToClipboard() {
    if (_myReferralCode != null) {
      Clipboard.setData(ClipboardData(text: _myReferralCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Davet kodu kopyalandı!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _submitCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final quizProvider = context.read<QuizProvider>();
    final answered = quizProvider.totalQuestionsAnswered;

    setState(() => _isLoading = true);
    
    final result = await _referralService.submitReferralCode(code, answered);
    
    setState(() => _isLoading = false);
    
    if (result == "SUCCESS") {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tebrikler! Kod onaylandı ve 300 Elmas kazandınız!'),
          backgroundColor: Colors.green,
        ),
      );
      _codeController.clear();
      context.read<QuizProvider>().addCoins(300);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Davet Et & Kazan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Üst Kısım: Senin Kodun
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.diamond, color: Colors.cyanAccent, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    "Davet Et, Sen de Kazan!",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bu kodu arkadaşlarına gönder. Onlar oyuna girip bu kodu yazdıklarında onlar 300 ELMAS, sen ise her davette GİDEREK ARTAN (300, 400, 500...) elmaslar kazan!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  if (_myReferralCode == null)
                    CircularProgressIndicator(color: AppColors.primary)
                  else
                    GestureDetector(
                      onTap: _copyToClipboard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _myReferralCode!,
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.copy, color: Colors.white54),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const Text("Kopyalamak için koda dokun", style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Alt Kısım: Kod Girme
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text(
                    "Arkadaşının Kodunu Gir",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    style: const TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1),
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "DAVET KODU",
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "KODU ONAYLA",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
