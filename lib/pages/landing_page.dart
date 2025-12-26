import 'package:flutter/material.dart';
import 'package:help_x_web/widgets/sections.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// The Nuclear Option: Single Import
import '../core/all_constants.dart';

import 'library_page.dart';
import 'services_page.dart';
import 'premium_hub.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController(); // Search Controller
  
  User? _user;
  bool _isPremium = false;
  // ignore: unused_field
  bool _isMentor = false;

  @override
  void initState() {
    super.initState();
    _initAuthAndSync();
  }

  Future<void> _initAuthAndSync() async {
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
      _user = auth.currentUser;
      if (_user != null) {
        _syncUserStatus();
      }
    } catch (e) {
      debugPrint("Auth Init Error: $e");
    }
  }

  void _syncUserStatus() {
    if (_user == null) return;
    FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(_user!.uid)
        .collection('profile')
        .doc('status')
        .snapshots()
        .listen((doc) {
      if (doc.exists && mounted) {
        setState(() {
          _isPremium = doc.data()?['isPremium'] ?? false;
          _isMentor = doc.data()?['isMentor'] ?? false;
        });
      }
    }, onError: (e) => debugPrint("Firestore Sync Error: $e"));
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  // Functional Search Navigation
  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => LibraryPage(initialSearchQuery: query))
      );
    } else {
       // Just go to library if empty
       _navigateTo(context, const LibraryPage());
    }
  }

  // ignore: unused_element
  void _contactSupport() async {
    final Uri url = Uri.parse("https://wa.me/$whatsappNumber");
    if (!await launchUrl(url)) debugPrint("Could not launch WhatsApp");
  }

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final bool isMobile = sw < Layout.mobileLimit;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Positioned.fill(child: _buildMeshBackground()),
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(context, isMobile),
              SliverList(
                delegate: SliverChildListDelegate([
                  Section(child: _buildHero(isMobile)),
                  Section(child: _buildTrustBar()),
                  Section(child: _buildServicesSection(context, isMobile)),
                  Section(
                    backgroundColor: AppColors.bgSurface.withAlpha(100),
                    fullWidth: true,
                    child: _buildRescueKitsSection(context, isMobile),
                  ),
                  Section(child: _buildPremiumCTA(context, isMobile)),
                  Section(child: _buildFooter()),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeshBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [Color(0x1A137FEC), AppColors.bgPrimary],
        ),
      ),
      child: Opacity(
        opacity: 0.03,
        child: GridPaper(color: Colors.white, divisions: 1, subdivisions: 1, interval: 40, child: Container()),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isMobile) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: AppColors.bgPrimary.withAlpha(240),
      elevation: 0,
      title: InkWell(
        onTap: () => _navigateTo(context, const PremiumHub()),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isPremium ? AppColors.accent : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _isPremium ? Colors.white.withAlpha(50) : AppColors.borderSubtle),
              ),
              child: Icon(_isPremium ? Icons.stars_rounded : Icons.local_library, color: AppColors.textPrimary, size: 18),
            ),
            const SizedBox(width: 12),
            Text(appName.toUpperCase(), style: AppText.h3.copyWith(letterSpacing: 2)),
          ],
        ),
      ),
      actions: isMobile
          ? [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))]
          : [
              _navAction("Protocols", () => _navigateTo(context, const ServicesPage())),
              _navAction("Library", () => _navigateTo(context, const LibraryPage())),
              const SizedBox(width: 20),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: ElevatedButton(
                  onPressed: () => _navigateTo(context, const PremiumHub()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPremium ? AppColors.bgSurface : AppColors.accent,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: Text(_isPremium ? "OPERATOR HUB" : "UNLOCK ACCESS", style: AppText.button),
                ),
              ),
            ],
    );
  }

  Widget _navAction(String label, VoidCallback onTap) {
    return TextButton(onPressed: onTap, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)));
  }

  Widget _buildHero(bool isMobile) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isPremium ? AppColors.accent.withAlpha(30) : AppColors.bgSurface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _isPremium ? AppColors.accent.withAlpha(100) : AppColors.borderSubtle),
          ),
          child: Text(
            _isPremium ? "PREMIUM ACCESS ACTIVE" : appEdition.toUpperCase(),
            style: AppText.label.copyWith(color: _isPremium ? AppColors.accent : AppColors.textMuted),
          ),
        ),
        const SizedBox(height: Layout.itemGap),
        Text("Pass Fast.\nWith Certainty.", textAlign: TextAlign.center, style: AppText.h1(isMobile)),
        const SizedBox(height: Layout.itemGap),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Layout.narrowMaxWidth),
          child: Text(
            "The outcome-driven rescue system for Batch Tech students. Get exact fixes, pre-checked blueprints, and priority rescue operators.",
            textAlign: TextAlign.center,
            style: AppText.body,
          ),
        ),
        const SizedBox(height: 50),
        _buildHeroSearch(isMobile),
      ],
    );
  }

  Widget _buildHeroSearch(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 650,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 30, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          Icon(Icons.search, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _performSearch(), // Trigger search on Enter
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search rescue kits (e.g., '121b fix')...",
                hintStyle: TextStyle(color: AppColors.textSubtle),
                border: InputBorder.none,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _performSearch, // Trigger search on Click
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            ),
            child: const Text("FIND FIX", style: AppText.button),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBar() {
    return Wrap(
      spacing: 40,
      runSpacing: 20,
      alignment: WrapAlignment.center,
      children: [
        _trustItem(Icons.verified, "Outcome Verified"),
        _trustItem(Icons.bolt, "Instant Execution"),
        _trustItem(Icons.lock, "Secure Platform"),
      ],
    );
  }

  Widget _trustItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accent, size: 16),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildServicesSection(BuildContext context, bool isMobile) {
    return Column(
      children: [
        Text("RESCUE PROTOCOLS", style: AppText.label),
        const SizedBox(height: 16),
        Text("Stop Struggling. Start Finishing.", style: AppText.h2(isMobile), textAlign: TextAlign.center),
        const SizedBox(height: 60),
        Wrap(
          spacing: Layout.itemGap,
          runSpacing: Layout.itemGap,
          alignment: WrapAlignment.center,
          children: [
            _serviceCard(context, "Technical Rescue", "Environment broken? Tools fighting you? We log in and fix it so you can submit.", Icons.terminal),
            _serviceCard(context, "Concept Unblock", "Stuck on logic? We explain the exact concept blocking you until it clicks.", Icons.lightbulb_outline),
            _serviceCard(context, "Course Stabilization", "Falling behind? We build a recovery plan to get you passing by Friday.", Icons.health_and_safety),
          ],
        ),
      ],
    );
  }

  Widget _serviceCard(BuildContext context, String title, String desc, IconData icon) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 40),
          const SizedBox(height: 24),
          Text(title, style: AppText.h3),
          const SizedBox(height: 16),
          Text(desc, style: AppText.body),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => _navigateTo(context, const ServicesPage()),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("INITIATE PROTOCOL", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16, color: AppColors.accent),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRescueKitsSection(BuildContext context, bool isMobile) {
    return Column(
      children: [
        Text("RESCUE KITS", style: AppText.label),
        const SizedBox(height: 16),
        Text("Submission-Ready Blueprints", style: AppText.h2(isMobile), textAlign: TextAlign.center),
        const SizedBox(height: 60),
        Wrap(
          spacing: Layout.itemGap,
          runSpacing: Layout.itemGap,
          alignment: WrapAlignment.center,
          children: [
            _libraryCard(context, "Python Masterclass", "assets/python.png", "PASS KIT", isPremium: true),
            _libraryCard(context, "Calculus II Rescue", "assets/calculus.jpg", "PASS KIT", isPremium: true),
            _libraryCard(context, "Data Types Map", "assets/data_types.jpg", "FREE", isPremium: false),
          ],
        ),
      ],
    );
  }

  Widget _libraryCard(BuildContext context, String title, String asset, String badge, {bool isPremium = false}) {
    bool isUnlocked = _isPremium || !isPremium;

    return InkWell(
      onTap: () => _navigateTo(context, const LibraryPage()),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  Image.asset(
                    asset,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      color: Colors.white.withAlpha(10),
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.white24)),
                    ),
                  ),
                  if (!isUnlocked)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withAlpha(180),
                        child: const Center(child: Icon(Icons.lock, color: Colors.white54, size: 32)),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPremium ? AppColors.accent : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.h3.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text("Complete blueprint to pass assignment 3.", style: AppText.body.copyWith(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCTA(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accent.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.accent.withAlpha(80), blurRadius: 60, offset: const Offset(0, 20))],
      ),
      child: Column(
        children: [
          Text(
            _isPremium ? "Operator Access Granted" : "Stop Guessing.",
            style: AppText.h2(isMobile).copyWith(fontSize: 40),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            _isPremium 
              ? "Welcome to the elite circle. Your tools are ready."
              : "Get the exact commands, checklists, and blueprints to pass with certainty.",
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(color: Colors.white.withAlpha(220), fontSize: 18),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => _navigateTo(context, const PremiumHub()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
            ),
            child: Text(
              _isPremium ? "ENTER HUB" : "UNLOCK CERTAINTY",
              style: AppText.button.copyWith(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Icon(Icons.local_library, color: AppColors.textSubtle, size: 32),
        const SizedBox(height: 24),
        Text("A Greyway.Co Production | Batch Tech 2025", style: AppText.label.copyWith(color: AppColors.textSubtle)),
        const SizedBox(height: 12),
        Text("© 2023 Help X. All rights reserved.", style: TextStyle(color: AppColors.textSubtle, fontSize: 12)),
      ],
    );
  }
}