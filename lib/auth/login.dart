import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'forget_password.dart';
import 'sign_up.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.favorite, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "ICU Cardiac \n Monitoring".tr(), // ICU Cardiac Monitoring
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                style: TextStyle(color:Colors.grey),
                decoration: InputDecoration(
                  hintText: 'email'.tr(),
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xff64B5F6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xff64B5F6)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !_showPassword,
                style: TextStyle(color:Colors.grey),
                decoration: InputDecoration(
                  hintText: 'password'.tr(),
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xff64B5F6)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xff64B5F6)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _showPassword = !_showPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue,
                ),
                  onPressed: () async {
                    try {
                      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("login_success".tr())),
                      );

                      final uid = userCredential.user!.uid;
                      await FirebaseMessaging.instance.requestPermission();

                      // 💡 Get FCM Token
                      final fcmToken = await FirebaseMessaging.instance.getToken();

                      // 💾 Save the token inside user's document
                      await FirebaseFirestore.instance.collection('users').doc(uid).update({
                        'fcmToken': fcmToken,
                      });

                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .get();

                      final role = userDoc['role'];

                      if (role == 'Patient') {
                        final dataDoc = await FirebaseFirestore.instance
                            .collection('patient_data')
                            .doc(uid)
                            .get();

                        if (dataDoc.exists) {
                          Navigator.pushReplacementNamed(context, '/patient_profile');
                        } else {
                          Navigator.pushReplacementNamed(context, '/patient_home');
                        }

                      } else if (role == 'Nurse') {
                        Navigator.pushReplacementNamed(context, '/nurse_home');
                      } else if (role == 'Doctor') {
                        Navigator.pushReplacementNamed(context, '/doctor_home');
                      }

                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${"login_failed".tr()}: ${e.toString()}")),
                      );
                    }
                  },
                  child: Text("login".tr(), style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: Text(
                  "forgot_password".tr(),
                  style: TextStyle(color: Colors.blue[600]),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("no_account".tr(), style: const TextStyle(color: Colors.grey),),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                    },
                    child: Text(
                      "sign_up".tr(),
                      style: const TextStyle(color: Colors.blue, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
