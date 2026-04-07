import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EnterCodePage extends StatefulWidget {
  const EnterCodePage({super.key});

  @override
  State<EnterCodePage> createState() => _EnterCodePageState();
}

class _EnterCodePageState extends State<EnterCodePage> {

  final codeController = TextEditingController();
  String message = "";

  Future<void> pairWatch() async {

    final code = codeController.text.trim();

    if (code.isEmpty) {
      setState(() => message = "❌ أدخل الكود");
      return;
    }

    final docRef = FirebaseFirestore.instance
        .collection('pairing_codes')
        .doc(code);

    final doc = await docRef.get();

    if (!doc.exists) {
      setState(() => message = "❌ الكود غير موجود");
      return;
    }

    final data = doc.data()!;

    if (data['paired'] == true) {
      setState(() => message = "❌ الكود مستخدم");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    //////////////////////////////////////////////////////
    // 🔥 ربط
    //////////////////////////////////////////////////////
    await docRef.update({
      "paired": true,
      "pairedBy": user!.uid,
    });

    //////////////////////////////////////////////////////
    // 🔥 تحديث المستخدم
    //////////////////////////////////////////////////////
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      "paired": true,
    }, SetOptions(merge: true));

    //////////////////////////////////////////////////////
    // 🔥 حذف الكود بعد النجاح
    //////////////////////////////////////////////////////
    await docRef.delete();

    setState(() => message = "✅ تم الربط");

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text("ربط الساعة")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              const SizedBox(height: 40),

              const Text("أدخل كود الساعة",
                  style: TextStyle(fontSize: 18)),

              const SizedBox(height: 20),

              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "------",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: pairWatch,
                child: const Text("ربط"),
              ),

              const SizedBox(height: 20),

              Text(
                message,
                style: TextStyle(
                  color: message.contains("✅")
                      ? Colors.green
                      : Colors.red,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}