import 'package:flutter/foundation.dart';
import '../services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/audio_provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);
    final isAnonymous = FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

    return Scaffold(
      backgroundColor: AppColors.appPurpleBg,
      bottomNavigationBar: !kIsWeb ? const CustomBannerAd() : const SizedBox.shrink(),
      appBar: AppBar(
        title: const Text('AYARLAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white)),
        backgroundColor: AppColors.appPurpleBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D2250), Color(0xFF08152F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader('SES VE DENEYİM'),
            _buildSettingTile(
              title: 'Arka Plan Müziği',
              icon: Icons.music_note,
              value: audioProvider.isMusicEnabled,
              onChanged: (val) => audioProvider.toggleMusic(),
            ),
            _buildSettingTile(
              title: 'Ses Efektleri',
              icon: Icons.volume_up,
              value: audioProvider.isSfxEnabled,
              onChanged: (val) => audioProvider.toggleSfx(),
            ),
            _buildSettingTile(
              title: 'Titreşim',
              icon: Icons.vibration,
              value: audioProvider.isVibrationEnabled,
              onChanged: (val) => audioProvider.toggleVibration(),
            ),
            const SizedBox(height: 30),
            
            _buildSectionHeader('HESAP VE VERİ'),
            
            if (isAnonymous)
              GestureDetector(
                onTap: () => _showLinkAccountDialog(context),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amberAccent, width: 2),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amberAccent, size: 28),
                      SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          'Hesabını Kalıcı Yap (Kaydet)',
                          style: TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.amberAccent, size: 18),
                    ],
                  ),
                ),
              ),
              
            // Çıkış Yap Butonu
            GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orangeAccent, width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.logout, color: Colors.orangeAccent, size: 28),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'Hesaptan Çıkış Yap',
                        style: TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.orangeAccent, size: 18),
                  ],
                ),
              ),
            ),
            
            GestureDetector(
              onTap: () => _showResetDialog(context),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.redAccent, width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.redAccent, size: 28),
                    SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        'İlerlemeyi Sıfırla',
                        style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.redAccent, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkAccountDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    bool isLoading = false;
    String errorMessage = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.appPurpleBg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.amberAccent, width: 2)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amberAccent, size: 48),
                    const SizedBox(height: 16),
                    const Text('Hesabını Kaydet', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Misafir hesabındaki tüm elmasları, paraları ve skorları kaybetmemek için hesabını bir e-postaya bağla!', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 20),
                    
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Kullanıcı Adın',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        prefixIcon: const Icon(Icons.person, color: Colors.amberAccent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: emailCtrl,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'E-posta Adresi',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        prefixIcon: const Icon(Icons.email, color: Colors.amberAccent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: passCtrl,
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Şifre Belirle',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white10,
                        prefixIcon: const Icon(Icons.lock, color: Colors.amberAccent),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    
                    if (errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(errorMessage, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ],
                    
                    const SizedBox(height: 24),
                    if (isLoading)
                      const CircularProgressIndicator(color: Colors.amberAccent)
                    else
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('İPTAL', style: TextStyle(color: Colors.white54)),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () async {
                                if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
                                  setState(() => errorMessage = 'Lütfen tüm alanları doldurun.');
                                  return;
                                }
                                
                                setState(() {
                                  isLoading = true;
                                  errorMessage = '';
                                });
                                
                                try {
                                  AuthCredential credential = EmailAuthProvider.credential(
                                    email: emailCtrl.text.trim(), 
                                    password: passCtrl.text.trim()
                                  );
                                  
                                  UserCredential userCred = await FirebaseAuth.instance.currentUser!.linkWithCredential(credential);
                                  
                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setString('user_name', nameCtrl.text.trim());
                                  await userCred.user?.updateDisplayName(nameCtrl.text.trim());
                                  
                                  if (ctx.mounted) {
                                    await Provider.of<QuizProvider>(ctx, listen: false).updateUserName(nameCtrl.text.trim());
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(ctx).showSnackBar(
                                      const SnackBar(content: Text('Hesabın başarıyla kaydedildi! 🎉'), backgroundColor: Colors.green),
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  setState(() {
                                    isLoading = false;
                                    if (e.code == 'email-already-in-use') {
                                      errorMessage = 'Bu e-posta adresi zaten kullanılıyor.';
                                    } else if (e.code == 'weak-password') {
                                      errorMessage = 'Şifre çok zayıf. En az 6 karakter girin.';
                                    } else {
                                      errorMessage = e.message ?? 'Bir hata oluştu.';
                                    }
                                  });
                                } catch (e) {
                                  setState(() {
                                    isLoading = false;
                                    errorMessage = 'Hata: $e';
                                  });
                                }
                              },
                              child: const Text('KAYDET', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 10),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white54, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSettingTile({required String title, required IconData icon, required bool value, required Function(bool) onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.menuButtonBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textGold, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.textGold,
            activeTrackColor: AppColors.textGold.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }


  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.redAccent, width: 2)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 30),
            SizedBox(width: 10),
            Text('DİKKAT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Tüm puanların, paran ve elmasların silinecek. İlerlemeyi sıfırlamak istediğine emin misin?',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İPTAL', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<QuizProvider>(context, listen: false).resetAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tüm veriler sıfırlandı!')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('SIFIRLA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
