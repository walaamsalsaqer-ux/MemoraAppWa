import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedsPage extends StatelessWidget {
  const MedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F3F3),

        appBar: AppBar(
          title: const Text("الأدوية"),
          centerTitle: true,
        ),

        body: user == null
            ? const Center(child: Text("المستخدم غير مسجل دخول"))
            : StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('reminders')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("لا يوجد أدوية بعد"),
              );
            }

            final reminders = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final doc = reminders[index];
                final data =
                doc.data() as Map<String, dynamic>;

                final name = data['medicineName'] ?? "";
                final doseAmount = data['doseAmount'] ?? 1;
                final doseUnit = data['doseUnit'] ?? "";
                final imageUrl = data['imageUrl'] ?? "";
                final isActive = data['isActive'] ?? true;

                final Timestamp time = data['time'];
                final DateTime date = time.toDate();

                final formattedTime =
                    "${date.hour > 12 ? date.hour - 12 : date.hour}:"
                    "${date.minute.toString().padLeft(2, '0')} "
                    "${date.hour >= 12 ? "PM" : "AM"}";

                return _buildMedicineCard(
                  doc: doc,
                  name: name,
                  doseAmount: doseAmount,
                  doseUnit: doseUnit,
                  imageUrl: imageUrl,
                  isActive: isActive,
                  formattedTime: formattedTime,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMedicineCard({
    required QueryDocumentSnapshot doc,
    required String name,
    required int doseAmount,
    required String doseUnit,
    required String imageUrl,
    required bool isActive,
    required String formattedTime,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🖼️ صورة (🔥 تم إصلاحها)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: 65,
              height: 65,
              fit: BoxFit.cover,

              /// 🔥 أهم إصلاح
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 65,
                  height: 65,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                );
              },
            )
                : Container(
              width: 65,
              height: 65,
              color: Colors.grey[200],
              child: const Icon(Icons.medication),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Switch(
                      value: isActive,
                      activeColor: Colors.green,
                      onChanged: (val) async {
                        await doc.reference.update({
                          'isActive': val,
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Text("$doseAmount $doseUnit"),

                    const SizedBox(width: 6),
                    const Text("|"),
                    const SizedBox(width: 6),

                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.orange,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      "at $formattedTime",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Edit",
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: 13,
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
}