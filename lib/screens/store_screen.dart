import 'package:flutter/foundation.dart';
import '../services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';

class AvatarItem {
  final String id;
  final String name;
  final String path;
  final int price;

  AvatarItem(this.id, this.name, this.path, this.price);
}

class ThemeItem {
  final String name;
  final int price;
  final Color primaryColor;
  final Color accentColor;

  ThemeItem(this.name, this.price, this.primaryColor, this.accentColor);
}

class StoreScreen extends StatelessWidget {
  StoreScreen({super.key});
  final List<AvatarItem> _avatars = [
    AvatarItem('pythagoras', 'Pisagor', 'assets/images/pythagoras_avatar.png', 2000),
    AvatarItem('turing', 'Alan Turing', 'assets/images/turing_avatar.png', 2000),
    AvatarItem('darwin', 'Darwin', 'assets/images/darwin_avatar.png', 5000),
    AvatarItem('curie', 'Marie Curie', 'assets/images/curie_avatar.png', 5000),
    AvatarItem('galileo', 'Galileo', 'assets/images/galileo_avatar.png', 10000),
    AvatarItem('hawking', 'Hawking', 'assets/images/hawking_avatar.png', 20000),
    AvatarItem('newton', 'Newton', 'assets/images/newton_avatar.png', 30000),
    AvatarItem('davinci', 'Da Vinci', 'assets/images/davinci_avatar.png', 30000),
    AvatarItem('tesla', 'Tesla', 'assets/images/tesla_avatar.png', 35000),
    AvatarItem('bell', 'Graham Bell', 'assets/images/bell_avatar.png', 40000),
    AvatarItem('edison', 'Edison', 'assets/images/edison_avatar.png', 45000),
    AvatarItem('einstein', 'Einstein', 'assets/images/einstein_avatar.png', 50000),
  ];

  final List<ThemeItem> _themes = [
    ThemeItem('Varsayılan Tema',  0,      const Color(0xFF260D4D), const Color(0xFF00E5FF)),
    ThemeItem('Karanlık Mod',     200,    const Color(0xFF121212), const Color(0xFF00E5FF)),
    ThemeItem('Okyanus',          400,    const Color(0xFF002B4A), const Color(0xFF00D4FF)),
    ThemeItem('Matrix',           700,    const Color(0xFF001A00), const Color(0xFF00FF41)),
    ThemeItem('Gün Batımı',       1000,   const Color(0xFF3D0C02), const Color(0xFFFF6B35)),
    ThemeItem('Neon Mor',         1500,   const Color(0xFF1A0033), const Color(0xFFBF00FF)),
    ThemeItem('Altın',            2000,   const Color(0xFF1C1800), const Color(0xFFFFD700)),
    ThemeItem('Kızıl Ateş',       3000,   const Color(0xFF2D0000), const Color(0xFFFF3333)),
    ThemeItem('Kutup Gecesi',     5000,   const Color(0xFF001122), const Color(0xFF00FFCC)),
  ];


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.appPurpleBg,
        bottomNavigationBar: !kIsWeb ? const CustomBannerAd() : const SizedBox.shrink(),
        appBar: AppBar(
          backgroundColor: AppColors.appPurpleBg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Mağaza', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
          actions: [
            Consumer<QuizProvider>(
              builder: (context, provider, child) => Row(
                children: [
                  Text(
                    '${provider.totalCoins}',
                    style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.diamond, color: Colors.cyanAccent, size: 20),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.cyanAccent,
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Avatarlar', icon: Icon(Icons.person)),
              Tab(text: 'Temalar', icon: Icon(Icons.palette)),
            ],
          ),
        ),
        body: Consumer<QuizProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                if (!kIsWeb)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: InkWell(
                      onTap: () {
                        AdService().showRewardedAd(
                          context: context,
                          onRewardEarned: (amount) {
                            // Give 25 diamonds
                            provider.addCoins(25);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tebrikler, 25 Elmas kazandınız! 💎'), backgroundColor: Colors.green));
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amberAccent, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.ondemand_video, color: Colors.white, size: 28),
                            SizedBox(width: 10),
                            Text('REKLAM İZLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(width: 10),
                            Text('+25 💎', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildAvatarTab(context, provider),
                      _buildThemeTab(context, provider),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarTab(BuildContext context, QuizProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Efsanevi Dehalar', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _avatars.length,
              itemBuilder: (context, index) {
                final avatar = _avatars[index];
                final isUnlocked = provider.unlockedAvatars.contains(avatar.path);
                final isActive = provider.activeAvatar == avatar.path;

                return _buildAvatarCard(context, provider, avatar, isUnlocked, isActive);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTab(BuildContext context, QuizProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Oyun Renk Temaları', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _themes.length,
              itemBuilder: (context, index) {
                final theme = _themes[index];
                final isUnlocked = provider.unlockedThemes.contains(theme.name);
                final isActive = provider.activeTheme == theme.name;

                return _buildThemeCard(context, provider, theme, isUnlocked, isActive);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard(BuildContext context, QuizProvider provider, AvatarItem avatar, bool isUnlocked, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.menuButtonBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.greenAccent : (isUnlocked ? Colors.cyan : AppColors.menuButtonBorder),
          width: isActive ? 3 : 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white12,
                backgroundImage: AssetImage(avatar.path),
              ),
              if (!isUnlocked)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, color: Colors.white, size: 30),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(avatar.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
              child: const Text('KULLANILIYOR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
            )
          else if (isUnlocked)
            ElevatedButton(
              onPressed: () => provider.equipAvatar(avatar.path),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('SEÇ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else
              ElevatedButton(
              onPressed: () {
                if (provider.totalCoins >= avatar.price) {
                  provider.buyAvatar(avatar.path, avatar.price);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Yetersiz Elmas! (${avatar.price} Gerekli)')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${avatar.price}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 4),
                  const Icon(Icons.diamond, color: Colors.white, size: 16),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, QuizProvider provider, ThemeItem theme, bool isUnlocked, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withValues(alpha: 0.85),
            theme.primaryColor.withValues(alpha: 0.4),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? Colors.greenAccent : (isUnlocked ? theme.accentColor.withValues(alpha: 0.6) : Colors.white12),
          width: isActive ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (isActive || isUnlocked)
            BoxShadow(color: theme.accentColor.withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 1),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Theme Preview Graphic
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.accentColor.withValues(alpha: 0.4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.accentColor, width: 2),
                boxShadow: [
                  BoxShadow(color: theme.accentColor.withValues(alpha: 0.35), blurRadius: 8, spreadRadius: 1),
                ],
              ),
              child: Center(
                child: !isUnlocked
                    ? Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.7), size: 24)
                    : Icon(Icons.palette_outlined, color: theme.accentColor, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            // Name & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.name,
                    style: TextStyle(
                      color: isUnlocked ? theme.accentColor : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Accent color preview dots
                  Row(
                    children: [
                      _colorDot(theme.primaryColor, size: 10),
                      const SizedBox(width: 4),
                      _colorDot(theme.accentColor, size: 10),
                      const SizedBox(width: 4),
                      _colorDot(Color.lerp(theme.primaryColor, theme.accentColor, 0.5)!, size: 10),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Action button
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.greenAccent, width: 1.5),
                ),
                child: const Text('✓ AKTİF', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              )
            else if (isUnlocked)
              GestureDetector(
                onTap: () => provider.setActiveTheme(theme.name),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade500],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.4), blurRadius: 6)],
                  ),
                  child: const Text('KULLAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              )
            else if (theme.price == 0)
              const SizedBox.shrink()
            else
              GestureDetector(
                onTap: () async {
                  bool success = await provider.buyTheme(theme.name, theme.price);
                  if (!success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Yetersiz Elmas! (${theme.price} 💎 gerekli)'), behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.accentColor.withValues(alpha: 0.8), theme.accentColor.withValues(alpha: 0.4)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.accentColor, width: 1),
                    boxShadow: [BoxShadow(color: theme.accentColor.withValues(alpha: 0.3), blurRadius: 6)],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.diamond_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('${theme.price}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _colorDot(Color color, {double size = 12}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
    );
  }
}

