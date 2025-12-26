import 'package:flutter/material.dart';
import 'package:help_x_web/widgets/sections.dart';
import '../core/all_constants.dart';

class LibraryPage extends StatefulWidget {
  final String? initialSearchQuery;

  const LibraryPage({super.key, this.initialSearchQuery});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late TextEditingController _searchController;
  String _searchQuery = "";

  // Mock Data for "Outcome-Based" Assets
  final List<Map<String, dynamic>> _allAssets = [
    {
      "title": "Python Masterclass",
      "desc": "Complete reference for Python 3.10+",
      "price": "\$15.00",
      "asset": "assets/python.png",
      "isPremium": true,
      "tag": "PASS KIT"
    },
    {
      "title": "Calculus II Rescue",
      "desc": "Integrals, derivatives, and series tests.",
      "price": "\$10.00",
      "asset": "assets/calculus.jpg",
      "isPremium": true,
      "tag": "PASS KIT"
    },
    {
      "title": "Data Types Map",
      "desc": "Visual guide to trees and Big O.",
      "price": "FREE",
      "asset": "assets/data_types.jpg",
      "isPremium": false, // Lead Magnet
      "tag": "FREE"
    },
    {
      "title": "Ultimate Exam Bundle",
      "desc": "All study guides plus 2h coaching.",
      "price": "\$45.00",
      "asset": "assets/exam_guides_bundle.png",
      "isPremium": true,
      "tag": "BUNDLE"
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialSearchQuery ?? "";
    _searchController = TextEditingController(text: _searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredAssets = _allAssets.where((asset) {
      final titleLower = asset["title"].toString().toLowerCase();
      final searchLower = _searchQuery.toLowerCase();
      return titleLower.contains(searchLower);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "RESCUE KITS", // Consistent Terminology
          style: AppText.h3.copyWith(letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Section(child: _buildSearchHeader()),
            Section(
              fullWidth: true,
              // Subtle background distinction for the grid area
              backgroundColor: AppColors.bgSurface.withAlpha(50), 
              child: _buildAssetGrid(filteredAssets),
            ),
            const SizedBox(height: Layout.sectionGap), // Bottom breathing room
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Column(
      children: [
        Text(
          "Premium Blueprints",
          style: AppText.h1(false).copyWith(fontSize: 48), // Slightly smaller hero for sub-page
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          "Submission-ready guides for high-stakes deadlines.",
          style: AppText.body,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Container(
          width: 600,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: AppColors.accent),
              hintText: "Filter by topic (e.g. 'Calculus')...",
              hintStyle: TextStyle(color: AppColors.textSubtle),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetGrid(List<Map<String, dynamic>> assets) {
    if (assets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 60, color: AppColors.textSubtle),
            const SizedBox(height: 20),
            Text("No rescue kits found for '$_searchQuery'", style: AppText.body),
          ],
        ),
      );
    }

    return Wrap(
      spacing: Layout.itemGap,
      runSpacing: Layout.itemGap,
      alignment: WrapAlignment.center,
      children: assets.map((asset) => _buildAssetCard(asset)).toList(),
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset) {
    bool isPremium = asset['isPremium'];
    // For now, assume unlocked if not premium, or logic to check user status would go here
    // ignore: unused_local_variable
    bool isUnlocked = !isPremium; 

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium ? AppColors.accent.withAlpha(100) : AppColors.borderSubtle
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.asset(
                  asset['asset'],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.white.withAlpha(5),
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.white10)),
                  ),
                ),
                if (isPremium) // Overlay lock if premium (simplified logic for UI demo)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withAlpha(150),
                      child: Center(
                        child: Icon(Icons.lock, color: Colors.white.withAlpha(200), size: 32),
                      ),
                    ),
                  ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPremium ? AppColors.accent : Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      asset['tag'],
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
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
                Text(asset['title'], style: AppText.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 8),
                Text(asset['desc'], style: AppText.body.copyWith(fontSize: 12)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      asset['price'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Future: Integration with Payment or Download
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPremium ? AppColors.accent : Colors.white.withAlpha(20),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(isPremium ? "Get Access" : "Download"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}