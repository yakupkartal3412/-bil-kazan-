import 'package:flutter/foundation.dart';
import '../services/ad_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import '../services/iap_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final IapService _iapService = IapService();
  bool _iapInitialized = false;
  bool _isSurpriseBoxReady = false;

  @override
  void initState() {
    super.initState();
    _initIap();
  }

  Future<void> _initIap() async {
    await _iapService.init(context);
    if (mounted) {
      setState(() {
        _iapInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _iapService.dispose();
    super.dispose();
  }

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
    AvatarItem('einstein', 'Einstein', 'assets/images/einstein_avatar.png', 80000),
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
      length: 4,
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
                    '${provider.formattedTotalCoins}',
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
              Tab(text: 'PREMİUM 💎', icon: Icon(Icons.workspace_premium)),
              Tab(text: 'Ekstralar', icon: Icon(Icons.star)),
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
                      _buildPremiumTab(context, provider),
                      _buildExtrasTab(context, provider),
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

  Widget _buildPremiumTab(BuildContext context, QuizProvider provider) {
    if (!_iapInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.amber));
    }
    if (!_iapService.isAvailable || _iapService.products.isEmpty) {
      return const Center(child: Text('Mağaza şu an kullanılamıyor.', style: TextStyle(color: Colors.white)));
    }
    
    ProductDetails? getProduct(String id) {
      try { return _iapService.products.firstWhere((p) => p.id == id); } catch (e) { return null; }
    }

    final starterPack = getProduct(IapService.packStarter);
    final einsteinPack = getProduct(IapService.avatarEinstein);
    final removeAdsPack = getProduct(IapService.removeAdsVip);
    
    final diamondPacks = [
      getProduct(IapService.diamond1000),
      getProduct(IapService.diamond5000),
      getProduct(IapService.diamond20000)
    ].whereType<ProductDetails>().toList();

    final jokerPacks = [
      getProduct(IapService.jokerPack20),
      getProduct(IapService.jokerPack50),
      getProduct(IapService.jokerPack100)
    ].whereType<ProductDetails>().toList();

    final roomCardPacks = [
      getProduct(IapService.roomCard10),
      getProduct(IapService.roomCard50)
    ].whereType<ProductDetails>().toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (removeAdsPack != null && !provider.hasRemovedAds) ...[
            _buildSpecialOfferCard(
              context: context,
              product: removeAdsPack,
              title: 'VIP REKLAM KALDIR',
              subtitle: 'Reklamları kapat ve tüm bedava ödülleri tıkla anında al!',
              imagePath: 'assets/images/no_ads_vip_icon.png',
              gradientColors: [const Color(0xFFD4145A), const Color(0xFFFBB03B)],
              icon: Icons.block,
            ),
            const SizedBox(height: 30),
          ],

          if (starterPack != null) ...[
            _buildSpecialOfferCard(
              context: context,
              product: starterPack,
              title: 'HOŞ GELDİN PAKETİ',
              subtitle: 'Galileo + 2000 💎 + 10 Oda + 20 Joker',
              imagePath: 'assets/images/galileo_avatar.png',
              gradientColors: [const Color(0xFF8A2387), const Color(0xFFE94057), const Color(0xFFF27121)],
              icon: Icons.star_rounded,
            ),
            const SizedBox(height: 30),
          ],
          
          if (diamondPacks.isNotEmpty) ...[
            const Text('ELMAS PAKETLERİ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: diamondPacks.length,
              itemBuilder: (context, index) {
                final p = diamondPacks[index];
                String img = 'assets/images/diamond_bag.png';
                if (p.id == IapService.diamond5000) img = 'assets/images/diamond_chest.png';
                if (p.id == IapService.diamond20000) img = 'assets/images/diamond_safe.png';
                return _buildGridCard(
                  context: context,
                  product: p,
                  title: p.title.split(' ').first + ' Elmas',
                  subtitle: p.price,
                  imagePath: img,
                  gradientColors: [const Color(0xFF00C9FF), const Color(0xFF92FE9D)],
                );
              },
            ),
            const SizedBox(height: 30),
          ],

          if (jokerPacks.isNotEmpty) ...[
            const Text('JOKER PAKETLERİ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: jokerPacks.length,
              itemBuilder: (context, index) {
                final p = jokerPacks[index];
                String img = 'assets/images/joker_bag.png';
                if (p.id == IapService.jokerPack50) img = 'assets/images/joker_chest.png';
                // Uses the recolored safe image (diamonds turned to gold)
                if (p.id == IapService.jokerPack100) img = 'assets/images/joker_safe.png';
                
                return _buildGridCard(
                  context: context,
                  product: p,
                  title: '${p.id.contains('20') ? '20' : p.id.contains('50') ? '50' : '100'} Joker',
                  subtitle: p.price,
                  imagePath: img,
                  gradientColors: [const Color(0xFFFFD700), const Color(0xFFF7971E)],
                );
              },
            ),
            const SizedBox(height: 30),
          ],

          if (roomCardPacks.isNotEmpty) ...[
            const Text('ODA KARTLARI', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: roomCardPacks.length,
              itemBuilder: (context, index) {
                final p = roomCardPacks[index];
                return _buildGridCard(
                  context: context,
                  product: p,
                  title: '${p.id.contains('10') ? '10' : '50'} Oda Kartı',
                  subtitle: p.price,
                  imagePath: 'assets/images/room_card.png',
                  gradientColors: [const Color(0xFF7F00FF), const Color(0xFFE100FF)],
                );
              },
            ),
            const SizedBox(height: 30),
          ],

          if (einsteinPack != null) ...[
            _buildSpecialOfferCard(
              context: context,
              product: einsteinPack,
              title: 'EINSTEIN VIP',
              subtitle: 'En Nadir Efsanevi Avatar',
              imagePath: 'assets/images/einstein_avatar.png',
              gradientColors: [const Color(0xFF141E30), const Color(0xFF243B55)],
              borderColor: Colors.amber,
              icon: Icons.workspace_premium,
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecialOfferCard({
    required BuildContext context,
    required ProductDetails product,
    required String title,
    required String subtitle,
    required String imagePath,
    required List<Color> gradientColors,
    required IconData icon,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => _iapService.buyProduct(product, context),
      child: Container(
        constraints: const BoxConstraints(minHeight: 140),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor ?? Colors.white.withValues(alpha: 0.2), width: 2),
          boxShadow: [
            BoxShadow(color: gradientColors.last.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(icon, size: 150, color: Colors.white.withValues(alpha: 0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
                      image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 3, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(product.price, style: TextStyle(color: gradientColors.first, fontWeight: FontWeight.w900, fontSize: 16)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -10,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: const Text('FIRSAT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard({
    required BuildContext context,
    required ProductDetails product,
    required String title,
    required String subtitle,
    required String imagePath,
    required List<Color> gradientColors,
  }) {
    return GestureDetector(
      onTap: () => _iapService.buyProduct(product, context),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: gradientColors.first.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(16)),
                child: Text(subtitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtrasTab(BuildContext context, QuizProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // JOKER INVENTORY
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A0845), Color(0xFF6441A5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.cyanAccent, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1),
              ],
            ),
            child: Column(
              children: [
                Image.asset('assets/images/joker_pack.png', height: 64),
                const SizedBox(height: 10),
                const Text('JOKER ENVANTERİ', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildJokerRow(
                  context,
                  provider,
                  icon: Icons.exposure_minus_2_rounded,
                  label: 'Yarı Yarıya',
                  count: provider.jokerFiftyFiftyTokens,
                  color: const Color(0xFFFFB300),
                  onReward: () {
                    provider.addJokerFiftyFiftyToken(1);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+1 Yarı Yarıya Jokeri kazandınız! 🃏'), backgroundColor: Colors.green));
                  },
                ),
                const SizedBox(height: 10),
                _buildJokerRow(
                  context,
                  provider,
                  icon: Icons.call_rounded,
                  label: 'Telefon',
                  count: provider.jokerPhoneTokens,
                  color: const Color(0xFF7B2FFF),
                  onReward: () {
                    provider.addJokerPhoneToken(1);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+1 Telefon Jokeri kazandınız! 🃏'), backgroundColor: Colors.green));
                  },
                ),
                const SizedBox(height: 10),
                _buildJokerRow(
                  context,
                  provider,
                  icon: Icons.bar_chart_rounded,
                  label: 'Seyirci',
                  count: provider.jokerAudienceTokens,
                  color: const Color(0xFF00897B),
                  onReward: () {
                    provider.addJokerAudienceToken(1);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+1 Seyirci Jokeri kazandınız! 🃏'), backgroundColor: Colors.green));
                  },
                ),
                const SizedBox(height: 10),
                _buildJokerRow(
                  context,
                  provider,
                  icon: Icons.rocket_launch_rounded,
                  label: 'Soruyu Geç',
                  count: provider.jokerSkipTokens,
                  color: const Color(0xFFE53935),
                  onReward: () {
                    provider.addJokerSkipToken(1);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+1 Pas Jokeri kazandınız! 🃏'), backgroundColor: Colors.green));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // SURPRISE BOX
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.orangeAccent.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 1),
              ],
            ),
            child: Column(
              children: [
                Image.asset('assets/images/diamond_chest.png', height: 64),
                const SizedBox(height: 10),
                const Text('GÜNLÜK SÜRPRİZ KUTU', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text('İçinden Elmas, Oda Kartı, Para veya Joker çıkabilir!', style: TextStyle(color: Colors.black87, fontSize: 14), textAlign: TextAlign.center),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    if (provider.hasRemovedAds) {
                      if (provider.consumeVipAction('surprise_box')) {
                        _openSurpriseBox(provider);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Günlük VIP Sürpriz Kutu sınırına ulaştınız! (Max 10)')));
                      }
                    } else if (_isSurpriseBoxReady) {
                      _openSurpriseBox(provider);
                    } else {
                      AdService().showRewardedAd(
                        context: context,
                        onRewardEarned: (amount) {
                          setState(() {
                            _isSurpriseBoxReady = true;
                          });
                        },
                      );
                    }
                  },
                  icon: Icon((provider.hasRemovedAds || _isSurpriseBoxReady) ? Icons.card_giftcard : Icons.ondemand_video, color: Colors.white),
                  label: Text((provider.hasRemovedAds || _isSurpriseBoxReady) ? 'KUTUYU AÇ' : 'VİDEOYU İZLE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (provider.hasRemovedAds || _isSurpriseBoxReady) ? Colors.green : Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSurpriseBox(QuizProvider provider) {
    int rand = DateTime.now().millisecondsSinceEpoch % 4;
    String rewardText = '';
    String rewardIcon = '';

    if (rand == 0) {
      provider.addCoins(50);
      rewardText = '50 Elmas';
      rewardIcon = 'assets/images/diamond_chest.png';
    } else if (rand == 1) {
      provider.giveFreeRoomCard();
      rewardText = '1 Oda Kartı';
      rewardIcon = 'assets/images/room_card.png';
    } else if (rand == 2) {
      provider.addMoney(5000);
      rewardText = '5.000 ₺';
      rewardIcon = 'assets/images/3d_cash_icon_nobg.png';
    } else {
      int jokerType = DateTime.now().millisecondsSinceEpoch % 4;
      if (jokerType == 0) { provider.addJokerFiftyFiftyToken(1); rewardText = '+1 Yarı Yarıya Jokeri'; }
      else if (jokerType == 1) { provider.addJokerPhoneToken(1); rewardText = '+1 Telefon Jokeri'; }
      else if (jokerType == 2) { provider.addJokerAudienceToken(1); rewardText = '+1 Seyirci Jokeri'; }
      else { provider.addJokerSkipToken(1); rewardText = '+1 Soruyu Geç Jokeri'; }
      rewardIcon = 'assets/images/joker_chest.png';
    }

    setState(() {
      _isSurpriseBoxReady = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF2994A), Color(0xFFF2C94C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎉 TEBRİKLER! 🎉', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Image.asset(rewardIcon, height: 100),
                const SizedBox(height: 20),
                const Text('Sürpriz Kutudan Çıkan Hediye:', style: TextStyle(color: Colors.black87, fontSize: 16)),
                const SizedBox(height: 10),
                Text(rewardText, style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('HARİKA!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildJokerRow(BuildContext context, QuizProvider provider, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required VoidCallback onReward,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Sahip: $count', style: const TextStyle(color: Colors.amberAccent, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (provider.hasRemovedAds) {
                  String actionType = '';
                  if (label == 'Yarı Yarıya') actionType = 'joker_ff';
                  else if (label == 'Telefon') actionType = 'joker_phone';
                  else if (label == 'Seyirci') actionType = 'joker_aud';
                  else actionType = 'joker_skip';
                  
                  if (provider.consumeVipAction(actionType)) {
                     onReward();
                  } else {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Günlük VIP Joker sınırına ulaştınız! (Max 15)')));
                  }
              } else {
                  AdService().showRewardedAd(
                    context: context,
                    onRewardEarned: (amount) => onReward(),
                  );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: provider.hasRemovedAds ? Colors.amberAccent : Colors.cyanAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: const Size(80, 36),
            ),
            child: Text(provider.hasRemovedAds ? 'AL' : 'İZLE'),
          ),
        ],
      ),
    );
  }
}
