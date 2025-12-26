import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// Global App ID for Rule 1
const String appId = "help-x-web";

class MentorPortal extends StatefulWidget {
  const MentorPortal({super.key});

  @override
  State<MentorPortal> createState() => _MentorPortalState();
}

class _MentorPortalState extends State<MentorPortal> {
  User? _user;
  bool _isLoading = true;
  Map<String, dynamic>? _mentorData;

  @override
  void initState() {
    super.initState();
    _initAuthAndData();
  }

  // RULE 3: Auth Before Queries
  Future<void> _initAuthAndData() async {
    try {
      final auth = FirebaseAuth.instance;
      // Ensure we are signed in
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
      _user = auth.currentUser;

      if (_user != null) {
        _syncMentorProfile();
      }
    } catch (e) {
      debugPrint("Auth Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // RULE 1: Strict Paths
  void _syncMentorProfile() {
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
        setState(() => _mentorData = doc.data());
      }
    });
  }

  Future<void> _claimBooking(String bookingId) async {
    if (_user == null) return;

    try {
      // RULE 1: Strict Paths
      await FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('bookings')
          .doc(bookingId)
          .update({
        'status': 'claimed',
        'mentorId': _user!.uid,
        'claimedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking claimed successfully! Check your active list.")),
        );
      }
    } catch (e) {
      debugPrint("Claim Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("MENTOR PORTAL",
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings, size: 20)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF137FEC)))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEarningsCard(),
                  const SizedBox(height: 40),
                  const Text("ACTIVE REQUESTS",
                      style: TextStyle(
                          color: Color(0xFF137FEC),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          fontSize: 12)),
                  const SizedBox(height: 20),
                  Expanded(child: _buildRequestList()),
                ],
              ),
            ),
    );
  }

  Widget _buildEarningsCard() {
    final earnings = _mentorData?['earnings'] ?? 0.0;
    final completed = _mentorData?['completedSessions'] ?? 0;
    final rating = _mentorData?['rating'] ?? 5.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Pending Payout",
              style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 8),
          Text("\$${earnings.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 20),
          Row(
            children: [
              _statMini("Completed", completed.toString()),
              const SizedBox(width: 24),
              _statMini("Rating", "${rating.toStringAsFixed(1)}/5"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statMini(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRequestList() {
    // RULE 2: Fetch all data with simple collection queries, then filter in memory
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('public')
          .doc('data')
          .collection('bookings')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFF137FEC)));
        }

        final allDocs = snapshot.data!.docs;
        // Filtering in memory as per Rule 2
        final pendingBookings = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['status'] == 'pending';
        }).toList();

        if (pendingBookings.isEmpty) {
          return const Center(
              child: Text("No active help requests found.",
                  style: TextStyle(color: Colors.white38)));
        }

        return ListView.builder(
          itemCount: pendingBookings.length,
          itemBuilder: (context, index) {
            final doc = pendingBookings[index];
            final data = doc.data() as Map<String, dynamic>;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.help_center_outlined, color: Color(0xFF137FEC)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['course'] ?? "Unknown Course",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(data['service'] ?? "General Support",
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _claimBooking(doc.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF137FEC).withAlpha(30),
                      foregroundColor: const Color(0xFF137FEC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("CLAIM",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}