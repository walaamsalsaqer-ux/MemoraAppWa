import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class SafeZonePage extends StatefulWidget {
  const SafeZonePage({super.key});

  @override
  State<SafeZonePage> createState() => _SafeZonePageState();
}

class _SafeZonePageState extends State<SafeZonePage> {

  GoogleMapController? mapController;

  LatLng selectedLocation = const LatLng(26.4207, 50.0888); // الدمام افتراضي
  double radius = 200;

  Set<Circle> circles = {};

  void updateCircle() {
    circles = {
      Circle(
        circleId: const CircleId("safeZone"),
        center: selectedLocation,
        radius: radius,
        fillColor: const Color(0xFF5B2E91).withOpacity(0.3),
        strokeColor: const Color(0xFF5B2E91),
        strokeWidth: 3,
      )
    };
    setState(() {});
  }

  Future<void> saveSafeZone() async {

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("patients")
        .doc(user.uid)
        .set({
      "safeZoneLat": selectedLocation.latitude,
      "safeZoneLng": selectedLocation.longitude,
      "safeZoneRadius": radius,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("تم حفظ المنطقة الآمنة ✅")),
    );

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    updateCircle();
  }

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "تحديد المنطقة الآمنة",
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [

            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: selectedLocation,
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  mapController = controller;
                },
                onTap: (LatLng position) {
                  selectedLocation = position;
                  updateCircle();
                },
                circles: circles,
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [

                  const Text(
                    "نطاق المنطقة (بالمتر)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Slider(
                    value: radius,
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    activeColor: const Color(0xFF5B2E91),
                    onChanged: (value) {
                      radius = value;
                      updateCircle();
                    },
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: saveSafeZone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B2E91),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text("حفظ المنطقة الآمنة"),
                    ),
                  ),

                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}