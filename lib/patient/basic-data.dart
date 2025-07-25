import 'package:cardiac_app/patient/patient_date.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({super.key});

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _gender = TextEditingController();
  final _weight = TextEditingController();
  final _height = TextEditingController();

  String? _selectedSex;

  double _calculateBMI() {
    final weight = double.tryParse(_weight.text) ?? 0;
    final heightCm = double.tryParse(_height.text) ?? 0;
    final heightM = heightCm / 100;

    if (heightM == 0) return 0.0;

    final bmi = weight / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }


  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _gender.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  Future<void> _submitBasicData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('patient_data').doc(uid).set({
        'uid': uid,
        'name': _name.text.trim(),
        'age': int.tryParse(_age.text) ?? 0,
        'gender': _selectedSex!,
        'weight': double.tryParse(_weight.text) ?? 0.0,
        'height': double.tryParse(_height.text) ?? 0.0,
        'bmi': _calculateBMI(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PatientProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:  Text("Patient Info".tr(),style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.bold,
      ),)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField("Name".tr(), _name),
              _buildField("Age".tr(), _age, isNum: true),
              _buildDropdown('Gender'.tr(), _selectedSex, ['F', 'M'], (val) => setState(() => _selectedSex = val)),
              _buildField("Weight (kg)".tr(), _weight, isNum: true),
              _buildField("Height (cm)".tr(), _height, isNum: true),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submitBasicData,   style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.blue,
              ),child: Text("Submit".tr(), style: const TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDropdown(String label, String? value, List<String> options, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true, // مهم جداً
              value: value,
              items: options.map((e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: onChanged,
              validator: (val) => (val == null || val.isEmpty) ? 'Required'.tr() : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) => (val == null || val.isEmpty) ? "Required".tr() : null,
      ),
    );
  }
}
