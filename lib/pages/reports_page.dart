import 'package:flutter/material.dart';
import 'safe_zone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}
class _ReportsPageState extends State<ReportsPage> {

  bool isInsideSafeZone = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkSafeZoneStatus();
  }

  Future<void> checkSafeZoneStatus() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("patients")
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    double safeLat = data["safeZoneLat"];
    double safeLng = data["safeZoneLng"];
    double radius = data["safeZoneRadius"];

    double currentLat = data["currentLat"];
    double currentLng = data["currentLng"];

    double distance = Geolocator.distanceBetween(
      currentLat,
      currentLng,
      safeLat,
      safeLng,
    );

    setState(() {
      isInsideSafeZone = distance <= radius;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF5B2E91),

        body: SafeArea(
          child: Column(
            children: [

              /// 🟣 العنوان
              const SizedBox(height: 20),
              const Text(
                "التقارير",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// ⚪ المحتوى
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// 📊 الملخص
                        Row(
                          children: const [
                            Expanded(
                              child: _SummaryCard(
                                title: "حالات السقوط",
                                value: "1 هذا الأسبوع",
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _SummaryCard(
                                title: "تحديثات الموقع",
                                value: "المنطقة الآمنة 1",
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        /// 📍 معلومات الموقع
                        const Text(
                          "معلومات الموقع",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// 🗺️ الخريطة (Placeholder)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SafeZonePage(),
                              ),
                            );
                          },
                          child: Container(
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey[200],
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map, size: 50, color: Color(0xFF5B2E91)),
                                SizedBox(height: 8),
                                Text(
                                  "اضغطي لتحديد أو تعديل المنطقة الآمنة",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// 📌 حالة الموقع
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _LocationInfo(
                              title: "الحالة",
                              value: isLoading
                                  ? "جاري التحقق..."
                                  : isInsideSafeZone
                                  ? "داخل النطاق الآمن"
                                  : "خارج النطاق الآمن",
                            ),
                            _LocationInfo(
                              title: "آخر تحديث",
                              value: "منذ دقيقتين",
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        /// ⚠️ سجل السقوط
                        const Text(
                          "سجل السقوط",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: const [
                            Expanded(
                              child: FallCard(
                                date: "22 يناير 2025",
                                time: "3:20 م",
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: FallCard(
                                date: "20 يناير 2025",
                                time: "2:10 م",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 📊 كرت الملخص
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// 📍 معلومات الموقع
class _LocationInfo extends StatelessWidget {
  final String title;
  final String value;

  const _LocationInfo({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(value),
      ],
    );
  }
}

/// ⚠️ كرت السقوط
class FallCard extends StatelessWidget {
  final String date;
  final String time;

  const FallCard({
    super.key,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "حادثة سقوط",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(date),
          Text("الوقت: $time"),

          const SizedBox(height: 8),

          const Text(
            "تم إرسال تنبيه للمرافق",
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}