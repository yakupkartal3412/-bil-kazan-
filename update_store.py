import sys

with open(r'lib\screens\store_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

start_index = text.find('  Widget _buildPremiumTab')
if start_index == -1:
    print('Error: Could not find _buildPremiumTab')
    sys.exit(1)

new_code = """  Widget _buildPremiumTab(BuildContext context, QuizProvider provider) {
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
    
    final diamondPacks = [
      getProduct(IapService.diamond1000),
      getProduct(IapService.diamond5000),
      getProduct(IapService.diamond20000)
    ].whereType<ProductDetails>().toList();

    final utilityPacks = [
      getProduct(IapService.roomCard10),
      getProduct(IapService.roomCard50),
      getProduct(IapService.jokerPack100)
    ].whereType<ProductDetails>().toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (starterPack != null) ...[
            _buildSpecialOfferCard(
              context: context,
              product: starterPack!,
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

          if (utilityPacks.isNotEmpty) ...[
            const Text('GÜÇLENDİRMELER', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
              itemCount: utilityPacks.length,
              itemBuilder: (context, index) {
                final p = utilityPacks[index];
                bool isRoom = p.id.contains('room');
                return _buildGridCard(
                  context: context,
                  product: p,
                  title: isRoom ? 'Oda Kartı' : 'Mega Joker',
                  subtitle: p.price,
                  imagePath: isRoom ? 'assets/images/diamond.png' : 'assets/images/3d_cash_icon_nobg.png',
                  gradientColors: isRoom ? [const Color(0xFF7F00FF), const Color(0xFFE100FF)] : [const Color(0xFFFFD700), const Color(0xFFF7971E)],
                );
              },
            ),
            const SizedBox(height: 30),
          ],

          if (einsteinPack != null) ...[
            _buildSpecialOfferCard(
              context: context,
              product: einsteinPack!,
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
  }) {
    return GestureDetector(
      onTap: () => _iapService.buyProduct(product),
      child: Container(
        height: 140,
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
                          child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                        ),
                        const SizedBox(height: 8),
                        Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                              child: Text(product.price, style: TextStyle(color: gradientColors.first, fontWeight: FontWeight.w900, fontSize: 16)),
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
      onTap: () => _iapService.buyProduct(product),
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
}
"""

text = text[:start_index] + new_code

with open(r'lib\screens\store_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print("Updated store_screen.dart successfully!")
