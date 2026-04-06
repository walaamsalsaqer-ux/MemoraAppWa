import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'profile_page.dart';
import 'reports_page.dart';
import 'create_reminder_page.dart';
import 'meds_page.dart';
import 'alerts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  final ImagePicker _picker = ImagePicker();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _pickAndUploadImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("اختيار من المعرض"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("التقاط صورة بالكاميرا"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final file = File(picked.path);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_images")
          .child("${user.uid}.jpg");

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await user.updatePhotoURL(url);
      await user.reload();

      if (!mounted) return;
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم تحديث الصورة بنجاح"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("حدث خطأ أثناء رفع الصورة"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToTab(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final pages = <Widget>[
      _DashboardTab(
        user: user,
        onPickImage: _pickAndUploadImage,
        onOpenReports: () => _goToTab(2),
        onOpenMeds: () => _goToTab(1),
      ),
      const MedsPage(),
      ReportsPage(),
      ProfilePage(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: pages[currentIndex],

        /// ✅ زر ➕ بعد التعديل الصحيح
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF6A1B9A),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateReminderPage(), // 🔥 هنا التعديل
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),

        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                navItem(Icons.home, 0, "الرئيسية"),
                navItem(Icons.medication, 1, "الأدوية"),
                const SizedBox(width: 40),
                navItem(Icons.bar_chart, 2, "التقارير"),
                navItem(Icons.person, 3, "الملف الشخصي"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget navItem(IconData icon, int index, String label) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => _goToTab(index),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color:
                isActive ? const Color(0xFF6A1B9A) : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color:
                isActive ? const Color(0xFF6A1B9A) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final User? user;
  final VoidCallback onPickImage;
  final VoidCallback onOpenReports;
  final VoidCallback onOpenMeds;

  const _DashboardTab({
    required this.user,
    required this.onPickImage,
    required this.onOpenReports,
    required this.onOpenMeds,
  });

  @override
  Widget build(BuildContext context) {
    final name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : "مستخدم";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
              top: 60, left: 20, right: 20, bottom: 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onPickImage,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.grey,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "متصل • البطارية 82%",
                    style:
                    TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.notifications, color: Colors.white),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              buildCard(
                icon: Icons.insights,
                title: "الإحصائيات اليومية",
                subtitle:
                "تذكير الدواء\nلا يوجد سقوط\nالموقع داخل المنطقة الآمنة",
                onTap: () {},
              ),
              buildCard(
                icon: Icons.alarm,
                title: "التذكيرات",
                subtitle: "التذكير القادم\nحبة واحدة | 5 ملغ",
                onTap: onOpenMeds,
              ),
              buildCard(
                icon: Icons.location_on,
                title: "التقارير",
                subtitle: "الموقع الحالي\nداخل المنطقة الآمنة",
                onTap: onOpenReports,
              ),
              buildCard(
                icon: Icons.history,
                title: "سجل السقوط",
                subtitle: "آخر سقوط منذ يومين",
                onTap: onOpenReports,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  static Widget buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6A1B9A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
              Icon(icon, color: const Color(0xFF6A1B9A)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}