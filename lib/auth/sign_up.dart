import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<String> _roles = ['patient', 'nurse', 'doctor'];
  String _selectedRole = 'patient';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Text(
                "sign_up".tr(),
                style: const TextStyle(fontSize: 38, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              _buildField("name".tr(), _nameController),
              const SizedBox(height: 15),
              _buildField("email".tr(), _emailController),
              const SizedBox(height: 15),
              _buildField("password".tr(), _passwordController, isPasswordField: true),
              const SizedBox(height: 15),
              _buildField("confirm_password".tr(), _confirmPasswordController, isConfirmPassword: true),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles
                    .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role.tr()),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                style: TextStyle(color:Colors.grey),
                decoration: InputDecoration(
                  hintStyle: TextStyle(color:Colors.grey),
                 labelStyle: TextStyle(color:Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "select_role".tr(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xff64B5F6)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  if (_passwordController.text != _confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("passwords_not_match".tr())),
                    );
                    return;
                  }

                  try {
                    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                    );
                    await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
                      'uid': credential.user!.uid,
                      'name': _nameController.text.trim(),
                      'email': _emailController.text.trim(),
                      'role': _selectedRole.tr(),
                      'createdAt': Timestamp.now(),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("account_created".tr())),
                    );

                    final userDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(credential.user!.uid)
                        .get();

                    final role = userDoc['role'];

                    if (role == 'Patient' || role == 'مريض/ مريضه') {
                      Navigator.pushReplacementNamed(context, '/patient_home');
                    } else if (role == 'Nurse' || role == 'ممرض/ ممرضة') {
                      Navigator.pushReplacementNamed(context, '/nurse_home');
                    } else if (role == 'Doctor' || role == 'طبيب/ طبيبه') {
                      Navigator.pushReplacementNamed(context, '/doctor_home');
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                },
                child: Text("sign_up".tr()),
              ),
              const SizedBox(height: 20),
              Text(
                "already_have_account".tr(),
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: Text(
                  "login".tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller,
      {bool isPasswordField = false, bool isConfirmPassword = false}) {
    bool isPassword = hint.toLowerCase().contains("password");

    return TextField(
      controller: controller,
      obscureText: isPasswordField ? !_showPassword : isConfirmPassword ? !_showConfirmPassword : false,
      style: TextStyle(color:Colors.grey),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xff64B5F6)),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            (isPasswordField && _showPassword) || (isConfirmPassword && _showConfirmPassword)
                ? Icons.visibility
                : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              if (isPasswordField) {
                _showPassword = !_showPassword;
              } else if (isConfirmPassword) {
                _showConfirmPassword = !_showConfirmPassword;
              }
            });
          },
        )
            : null,
      ),
    );
  }
}
