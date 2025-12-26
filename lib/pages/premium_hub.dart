import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_constants.dart' as app_constants;
import 'mentor_portal.dart';

class PremiumHub extends StatefulWidget {
  const PremiumHub({super.key});

  @override
  State<PremiumHub> createState() => _PremiumHubState();
}

class _PremiumHubState extends State<PremiumHub> {
  User? _user;
  bool _isPremium = false;
  bool _isMentor = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAuthAndSync();
  }

  Future<void> _initAuthAndSync() async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      _user = FirebaseAuth.instance.currentUser;
      if (_user != null) {
        _syncUserStatus();
      }
    } catch (e) {
      debugPrint("Auth Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _syncUserStatus() {
    if (_user == null) return;

    FirebaseFirestore.instance
        .collection('artifacts')
        .doc(app_constants.appId)
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
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    }, onError: (e) => debugPrint("Firestore Error: $e"));
  }

  Future<void> _applyForMentor() async {
    if (_user == null) return;
    
    await FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('public')
        .doc('data')
        .collection('mentorApplications')
        .doc(_user!.uid)
        .set({
      'userId': _user!.uid,
      'appliedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Application submitted to Batch Tech HQ.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF137FEC))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildHeader(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 40),
                        _sectionTitle("YOUR GUARANTEES"), // Changed from "ELITE ACCESS"
                        const SizedBox(height: 20),
                        _buildOutcomeGrid(), // Changed from FeatureGrid
                        const SizedBox(height: 40),
                        if (_isPremium && !_isMentor) _buildMentorApplicationCTA(),
                        if (_isMentor) _buildMentorPortalButton(),
                        if (!_isPremium) _buildUpgradeCTA(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.5),
            radius: 1.2,
            colors: [const Color(0xFF137FEC).withAlpha(30), const Color(0xFF0A0A0A)],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        "PREMIUM ACCESS",
        style: GoogleFonts.inter(fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 16),
      ),
      actions: [
        if (_isPremium) const Padding(padding: EdgeInsets.only(right: 20), child: Icon(Icons.stars, color: Color(0xFF137FEC))),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _isPremium ? const Color(0xFF137FEC).withAlpha(100) : Colors.white.withAlpha(10)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundColor: Color(0xFF137FEC), child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nyasha Gabriel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(_isPremium ? "ACCESS GRANTED: UNLIMITED" : "STANDARD ACCESS: DIAGNOSIS ONLY", 
                style: TextStyle(color: _isPremium ? const Color(0xFF137FEC) : Colors.white.withAlpha(80), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(color: Color(0xFF137FEC), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12));
  }

  Widget _buildOutcomeGrid() {
    // Focus on OUTCOMES, not features
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _outcomeCard("Exact Code Fixes", "Copy-paste solutions for env errors", Icons.code, _isPremium),
        _outcomeCard("Submission Checks", "Pre-grade logic to guarantee passing", Icons.verified, _isPremium),
        _outcomeCard("Rescue Blueprints", "Step-by-step recovery plans", Icons.architecture, _isPremium),
        _outcomeCard("Priority Rescue", "Skip the line for urgent help", Icons.timer, _isPremium),
      ],
    );
  }

  Widget _outcomeCard(String title, String subtitle, IconData icon, bool unlocked) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF161616), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withAlpha(5))),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: unlocked ? const Color(0xFF137FEC) : Colors.white.withAlpha(20), size: 32),
                const SizedBox(height: 12),
                Text(title, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: unlocked ? Colors.white : Colors.white.withAlpha(50))),
                const SizedBox(height: 6),
                Text(subtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(30), height: 1.2)),
              ],
            ),
          ),
          if (!unlocked) const Positioned(top: 10, right: 10, child: Icon(Icons.lock, size: 14, color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildMentorApplicationCTA() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF137FEC).withAlpha(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF137FEC).withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Join the Operators", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF137FEC))),
          const SizedBox(height: 8),
          const Text("Help X Operators don't just 'help'. They execute known fixes. Apply to join the elite rescue team.", 
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _applyForMentor,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF137FEC), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Apply as Operator", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorPortalButton() {
    return ElevatedButton.icon(
      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MentorPortal())),
      icon: const Icon(Icons.dashboard_customize),
      label: const Text("OPEN OPERATOR DASHBOARD"),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildUpgradeCTA() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFF137FEC), const Color(0xFF137FEC).withAlpha(150)]),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          const Text("Stop Guessing.", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text("Get the exact commands, checklists, and blueprints to pass with certainty.", textAlign: TextAlign.center),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF137FEC), minimumSize: const Size(double.infinity, 55)),
            child: const Text("UNLOCK CERTAINTY", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}