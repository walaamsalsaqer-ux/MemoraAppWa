import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الملف الشخصي"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .snapshots(),

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data =
            snapshot.data!.data() as Map<String, dynamic>;

            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [

                  /// 👤 الاسم + الصورة
                  Column(
                    children: [
                      const CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(height: 10),

                      Text(
                        data["patientName"] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text("الجنس: ${data["gender"] ?? ""}"),
                      Text("العمر: ${data["age"] ?? ""}"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  /// 📊 حالة الجهاز
                  const Text(
                    "حالة الجهاز",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("الحالة: متصل"),
                  const Text("البطارية: 82%"),

                  const SizedBox(height: 30),

                  /// 📈 إحصائيات اليوم
                  const Text(
                    "إحصائيات اليوم",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text("عدد السقوط: 0"),
                  const Text("الأدوية: 2 تم / 1 مفقود"),
                  const Text("الموقع: داخل المنطقة الآمنة"),

                  const SizedBox(height: 40),

                  /// 🔴 تسجيل الخروج
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => logout(context),
                    child: const Text("تسجيل الخروج"),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}