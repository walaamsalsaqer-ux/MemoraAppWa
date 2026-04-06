import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateReminderPage extends StatefulWidget {
  const CreateReminderPage({super.key});

  @override
  State<CreateReminderPage> createState() => _CreateReminderPageState();
}

class _CreateReminderPageState extends State<CreateReminderPage> {

  final medicineNameController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? selectedTime;
  String? audioPath;
  String? audioUrl;

  bool afterMeal = true;
  bool isLoading = false;

  File? selectedImage;
  String? imageUrl;

  final ImagePicker _picker = ImagePicker();

  int doseAmount = 1;
  String doseUnit = "حبة";

  Widget greyBox({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: child,
      ),
    );
  }

  Future<void> pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        selectedImage = File(file.path);
      });
    }
  }

  Future<void> pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => startDate = picked);
    }
  }

  Future<void> pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => endDate = picked);
    }
  }

  Future<void> pickTime() async {
    final picked =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> createReminder() async {

    if (medicineNameController.text.trim().isEmpty ||
        startDate == null ||
        endDate == null ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("اكمل جميع البيانات")),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("المستخدم غير مسجل دخول");

      final reminderDateTime = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      /// ✅ رفع الصورة
      if (selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('reminder_images')
            .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

        final uploadTask = await ref.putFile(selectedImage!);

        if (uploadTask.state == TaskState.success) {
          imageUrl = await ref.getDownloadURL();
        } else {
          imageUrl = "";
        }
      }

      /// ✅ رفع الصوت
      if (audioPath != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('audio')
            .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.mp4');

        final uploadTask = await ref.putFile(File(audioPath!));

        if (uploadTask.state == TaskState.success) {
          audioUrl = await ref.getDownloadURL();
        } else {
          audioUrl = "";
        }
      }

      /// ✅ حفظ البيانات
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('reminders')
          .add({
        "medicineName": medicineNameController.text.trim(),
        "startDate": Timestamp.fromDate(startDate!),
        "endDate": Timestamp.fromDate(endDate!),
        "time": Timestamp.fromDate(reminderDateTime),
        "doseAmount": doseAmount,
        "doseUnit": doseUnit,
        "afterMeal": afterMeal,
        "imageUrl": imageUrl ?? "",
        "audioUrl": audioUrl ?? "",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إنشاء التذكير")),
      );

      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("خطأ: $e")));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
          centerTitle: true,
          title: const Text(
            "إنشاء تذكير",
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text("معلومات الدواء",
                            style: TextStyle(fontWeight: FontWeight.bold)),

                        const SizedBox(height: 16),

                        greyBox(
                          child: TextField(
                            controller: medicineNameController,
                            decoration: const InputDecoration(
                              hintText: "ادخل اسم الدواء",
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        greyBox(
                          onTap: pickImage,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedImage != null
                                        ? "تم اختيار صورة"
                                        : "التقط صورة للدواء",
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "صورة الدواء تساعد على التذكر",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.image_outlined),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        greyBox(
                          onTap: () async {
                            final file = await _picker.pickVideo(source: ImageSource.gallery);
                            if (file != null) {
                              setState(() {
                                audioPath = file.path;
                              });
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// النص
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    audioPath != null
                                        ? "تم اختيار صوت"
                                        : "اختر تسجيل صوتي",
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "الصوت يساعد على التذكر",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),

                              /// الأيقونة
                              const Icon(Icons.mic_none),

                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// 📅 التاريخ
                        Row(
                          children: [
                            Expanded(
                              child: greyBox(
                                onTap: pickStartDate,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(startDate == null
                                        ? "تاريخ البداية"
                                        : "${startDate!.day}/${startDate!.month}/${startDate!.year}"),
                                    const Icon(Icons.calendar_today_outlined),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: greyBox(
                                onTap: pickEndDate,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(endDate == null
                                        ? "تاريخ النهاية"
                                        : "${endDate!.day}/${endDate!.month}/${endDate!.year}"),
                                    const Icon(Icons.calendar_today_outlined),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// ⏰ الوقت
                        greyBox(
                          onTap: pickTime,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedTime == null
                                    ? "اختاري الوقت"
                                    : selectedTime!.format(context),
                              ),
                              const Icon(Icons.access_time),
                            ],
                          ),
                        ),



                        const SizedBox(height: 28),

                        Row(
                          children: [
                            Expanded(
                              child: greyBox(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (doseAmount > 1) doseAmount--;
                                        });
                                      },
                                      icon: const Icon(Icons.remove),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                    ),
                                    Text("$doseAmount $doseUnit"),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          doseAmount++;
                                        });
                                      },
                                      icon: const Icon(Icons.add),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),


                        const SizedBox(height: 24),

                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEDED),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => afterMeal = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: afterMeal
                                          ? const Color(0xFF5B2E91)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "بعد الأكل",
                                        style: TextStyle(
                                          color: afterMeal
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => afterMeal = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: !afterMeal
                                          ? const Color(0xFF5B2E91)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "قبل الأكل",
                                        style: TextStyle(
                                          color: !afterMeal
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isLoading ? null : createReminder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B2E91),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(
                      isLoading ? "جاري الحفظ..." : "إنشاء التذكير"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}