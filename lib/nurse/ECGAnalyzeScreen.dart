import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../core/ecg_cubit.dart';
import '../core/ecg_state.dart';

class ECGAnalyzeScreen extends StatefulWidget {
  final String patientId;
  const ECGAnalyzeScreen({super.key, required this.patientId});

  @override
  State<ECGAnalyzeScreen> createState() => _ECGAnalyzeScreenState();
}

class _ECGAnalyzeScreenState extends State<ECGAnalyzeScreen>
    with TickerProviderStateMixin {
  File? _filePath;
  String? predictedClass;
  double? confidence;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xff3b82f6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "ECG Analysis".tr(),
          style: const TextStyle(
            color: Color(0xff3b82f6),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Image Upload Card
            GestureDetector(
              onTap: () => _showImageSourceSheet(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: _filePath == null
                      ? const LinearGradient(
                    colors: [Color(0xffebf8ff), Color(0xffdbeafe)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _filePath == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.monitor_heart,
                          size: 70, color: Color(0xff3b82f6)),
                      const SizedBox(height: 16),
                      Text(
                        "Tap to upload ECG image".tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff1e40af),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Supports JPG, PNG".tr(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  )
                      : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(_filePath!, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5)
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _filePath = null;
                              predictedClass = null;
                              confidence = null;
                            });
                            context.read<ECGCubit>().emit(ECGInitial());
                          },
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.redAccent,
                            child: Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Analyze Button
            BlocBuilder<ECGCubit, ECGState>(
              builder: (context, state) {
                bool isLoading = state is ECGLoading;
                return AnimatedScale(
                  scale: isLoading ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _filePath == null || isLoading
                          ? null
                          : () {
                        context.read<ECGCubit>().predictECG(_filePath!);
                        _animationController.forward(from: 0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff3b82f6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xff3b82f6).withOpacity(0.4),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.analytics, size: 26),
                          const SizedBox(width: 12),
                          Text(
                            "Analyze ECG".tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            BlocListener<ECGCubit, ECGState>(
              listener: (context, state) {
                if (state is ECGSuccess) {
                  setState(() {
                    predictedClass = state.predictedClass;
                    confidence = state.confidence;
                  });
                  _animationController.forward(from: 0);
                } else if (state is ECGError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Analysis failed. Please try again.".tr()),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: predictedClass != null && confidence != null
                    ? Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xffdbeafe), Color(0xffbfdbfe)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: _getResultColor(),
                              child: Icon(
                                _getResultIcon(),
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Diagnosis Result".tr(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff1e3a8a),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    predictedClass!,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff1e40af),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Confidence Level".tr(),
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${(confidence! * 100).toStringAsFixed(1)}%",
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff1d4ed8),
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('patient_data')
                                    .doc(widget.patientId)
                                    .update({
                                  'ecg_prediction': predictedClass,
                                  'ecg_confidence': confidence,
                                  'ecg_image_path': _filePath?.path ?? '',
                                  'ecg_timestamp': Timestamp.now(),
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Saved to patient record'.tr()),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.save_alt),
                              label: Text("Save".tr()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xff3b82f6), size: 28),
              title: Text("Take Photo".tr(), style: const TextStyle(fontSize: 18)),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xff3b82f6), size: 28),
              title: Text("Choose from Gallery".tr(), style: const TextStyle(fontSize: 18)),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    final XFile? photo = await ImagePicker().pickImage(source: source);
    if (photo != null) {
      setState(() {
        _filePath = File(photo.path);
        predictedClass = null;
        confidence = null;
      });
      context.read<ECGCubit>().emit(ECGInitial());
    }
    Navigator.pop(context);
  }

  Color _getResultColor() {
    if (predictedClass == null) return Colors.grey;
    return predictedClass!.toLowerCase().contains("normal")
        ? Colors.green
        : Colors.orangeAccent;
  }

  IconData _getResultIcon() {
    return predictedClass?.toLowerCase().contains("normal") ?? false
        ? Icons.favorite
        : Icons.warning_amber;
  }
}