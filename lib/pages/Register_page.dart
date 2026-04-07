import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'enter_code_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final patientNameController = TextEditingController();
  final ageController = TextEditingController();

  String? selectedGender;
  bool isLoading = false;

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

  Future<void> goToPairing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const EnterCodePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String msg = "خطأ في التسجيل";

      if (e.code == "email-already-in-use") {
        msg = "الإيميل مستخدم من قبل";
      } else if (e.code == "invalid-email") {
        msg = "الإيميل غير صحيح";
      } else if (e.code == "weak-password") {
        msg = "كلمة المرور ضعيفة";
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("صار خطأ، حاولي مرة ثانية")),
      );
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
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _field("الاسم", nameController),
                        _field(
                          "البريد الإلكتروني",
                          emailController,
                          keyboard: TextInputType.emailAddress,
                        ),
                        _field(
                          "رقم الجوال",
                          phoneController,
                          keyboard: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),
                        _field(
                          "كلمة المرور",
                          passwordController,
                          isPassword: true,
                        ),
                        _field("اسم المريض", patientNameController),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: const InputDecoration(
                            labelText: "الجنس",
                            filled: true,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "ذكر",
                              child: Text("ذكر"),
                            ),
                            DropdownMenuItem(
                              value: "أنثى",
                              child: Text("أنثى"),
                            ),
                          ],
                          onChanged: (v) => setState(() => selectedGender = v),
                          validator: (v) => v == null ? "اختاري الجنس" : null,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          "العمر",
                          ageController,
                          keyboard: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : goToPairing,
                            child: isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text("التالي"),
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

  Widget _field(
      String label,
      TextEditingController controller, {
        bool isPassword = false,
        TextInputType? keyboard,
        List<TextInputFormatter>? inputFormatters,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboard,
        inputFormatters: inputFormatters,
        validator: (v) {
          if (v == null || v.trim().isEmpty) {
            return "$label مطلوب";
          }

          if (label == "البريد الإلكتروني" && !v.contains("@")) {
            return "أدخلي بريدًا صحيحًا";
          }

          if (label == "كلمة المرور" && v.length < 6) {
            return "كلمة المرور لازم تكون 6 أحرف أو أكثر";
          }

          if (label == "العمر") {
            final age = int.tryParse(v);
            if (age == null || age <= 0) {
              return "أدخلي عمرًا صحيحًا";
            }
          }

          return null;
        },
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