import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PairQRPage extends StatelessWidget {
  const PairQRPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("لا يوجد مستخدم")),
      );
    }

    final uid = user.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ربط الساعة"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                "امسحي الكود من الساعة",
                style: TextStyle(fontSize: 18),
              ),

              const SizedBox(height: 20),

              QrImageView(
                data: uid,
                size: 200,
              ),

            ],
          ),
        ),
      ),
    );
  }
}