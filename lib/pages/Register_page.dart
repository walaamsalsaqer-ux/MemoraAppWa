import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final patientNameController = TextEditingController();
  final ageController = TextEditingController();

  String? selectedGender;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    patientNameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> createAccount() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final credential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) throw Exception("فشل إنشاء المستخدم");

      await user.updateDisplayName(nameController.text.trim());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        "caregiverName": nameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "patientName": patientNameController.text.trim().isEmpty
            ? "غير معروف"
            : patientNameController.text.trim(),
        "gender": selectedGender ?? "غير محدد",
        "age": int.tryParse(ageController.text.trim()) ?? 0,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/home');

    } on FirebaseAuthException catch (e) {

      String msg = "فشل إنشاء الحساب";

      if (e.code == "email-already-in-use") {
        msg = "هذا البريد مستخدم مسبقًا";
      } else if (e.code == "weak-password") {
        msg = "كلمة المرور ضعيفة (6 أحرف على الأقل)";
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

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
        backgroundColor: const Color(0xFF5B2E91),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 24),

                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.favorite,
                      color: Colors.white, size: 28),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        _field("الاسم", nameController),

                        _field("البريد الإلكتروني",
                            emailController,
                            keyboard: TextInputType.emailAddress),

                        _field("رقم الجوال",
                            phoneController,
                            keyboard: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ]),

                        _field("كلمة المرور",
                            passwordController,
                            isPassword: true),

                        _field("اسم المريض",
                            patientNameController),

                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration:
                          const InputDecoration(labelText: "الجنس"),
                          items: const [
                            DropdownMenuItem(
                                value: "ذكر", child: Text("ذكر")),
                            DropdownMenuItem(
                                value: "أنثى", child: Text("أنثى")),
                          ],
                          onChanged: (v) =>
                              setState(() => selectedGender = v),
                          validator: (v) =>
                          v == null ? "اختاري الجنس" : null,
                        ),

                        const SizedBox(height: 12),

                        _field("العمر",
                            ageController,
                            keyboard: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ]),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed:
                            isLoading ? null : createAccount,
                            child: isLoading
                                ? const CircularProgressIndicator(
                                color: Colors.white)
                                : const Text("إنشاء حساب"),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label,
      TextEditingController controller,
      {bool isPassword = false,
        TextInputType? keyboard,
        List<TextInputFormatter>? inputFormatters}) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboard,
        inputFormatters: inputFormatters,
        validator: (v) =>
        v == null || v.isEmpty ? "$label مطلوب" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}