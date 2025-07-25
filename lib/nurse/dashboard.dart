import 'package:cardiac_app/patient_detials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'NurseEntryScreen.dart';

class PatientCard extends StatelessWidget {
  final String name;
  final String id;
  final int heartRate;
  final String bp;
  final int spo2;
  final String ecgStatus;
  final String riskLevel;
  final int systolic;
  final int diastolic;

  const PatientCard({
    super.key,
    required this.name,
    required this.id,
    required this.heartRate,
    required this.bp,
    required this.spo2,
    required this.ecgStatus,
    required this.riskLevel,
    required this.systolic,
    required this.diastolic,
  });



  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case "critical"||"critical risk":
        return Colors.red;
      case "moderate"||'moderate risk':
        return Colors.orange;
      case "stable"||'non-critical risk':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  String getBpStatus(int systolic, int diastolic) {
    if (systolic >= 140 || diastolic >= 90) {
      return "High";
    } else if (systolic < 90 || diastolic < 60) {
      return "Low";
    } else {
      return "Normal";
    }
  }

  String getLocalizedBpStatus(BuildContext context, int systolic, int diastolic) {
    final status = getBpStatus(systolic, diastolic);
    switch (status) {
      case "High":
        return "High".tr();
      case "Low":
        return "Low".tr();
      default:
        return "Normal".tr();
    }
  }

  IconData _getEcgIcon(String status) {
    if (status == "Arrhythmia" || status == "CritArr") {
      return Icons.warning_amber_rounded;
    }
    return Icons.check_circle_outline;
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatientDetailScreen(
              patientId: id,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: .5,
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    // استرجاع بيانات المريض من Firestore
                    final snapshot = await FirebaseFirestore.instance
                        .collection('patient_data')
                        .doc(id)
                        .get();

                    if (snapshot.exists) {
                      final data = snapshot.data()!;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NurseEntryScreen(
                            patientId: id,
                            patientData: data,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRiskColor(riskLevel),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      riskLevel.tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

              ],
            ),
            const SizedBox(height: 4),
            Text("#$id", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("Heart Rate  | ".tr(), style: Theme.of(context).textTheme.bodySmall),
                Text(
                  "$heartRate bpm",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                Text(
                  ecgStatus == "Arrhythmia" || ecgStatus == "CritArr" ? "Arrhythmia".tr() : "Normal".tr(),
                  style: TextStyle(
                    color: ecgStatus == "Arrhythmia" || ecgStatus == "CritArr"
                        ? Colors.orange
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (ecgStatus == "Arrhythmia" || ecgStatus == "CritArr") ...[
                  const SizedBox(width: 4),
                  Icon(_getEcgIcon(ecgStatus), color: Colors.orange, size: 16),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text("Blood Pressure  | ".tr(), style: Theme.of(context).textTheme.bodySmall),
                Text(bp, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                const Spacer(),
                Text(
                  getLocalizedBpStatus(context, systolic, diastolic),
                  style: TextStyle(
                    color: getBpStatus(systolic, diastolic) == "High"
                        ? Colors.red
                        : getBpStatus(systolic, diastolic) == "Low"
                        ? Colors.orange
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),


              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text("SpO₂  | ".tr(), style: Theme.of(context).textTheme.bodySmall),
                Text("$spo2%", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getEcgStatusFromScore(double? score) {
    if (score == null) return "Unknown";
    if (score < 0.33) return "Normal";
    if (score < 0.50) return "Arrhythmia";
    return "CritArr";
  }

  String getRiskLevelFromScore(double? score) {
    if (score == null) return "Unknown";

    if (score >= 0.0 && score < 0.33) {
      return "Stable";
    } else if (score >= 0.33 && score < 0.50) {
      return "Moderate Risk";
    } else if (score >= 0.50 && score <= 1.0) {
      return "Critical Risk";
    } else {
      return "Unknown"; // لو فيه رقم خارج النطاق لأي سبب
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          "Dashboard".tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 30),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.dashboard, color: Theme.of(context).iconTheme.color),
              onPressed: () => Navigator.pushNamed(context, '/nurse_home'),
            ),
            IconButton(
              icon: Icon(Icons.people_sharp, color: Theme.of(context).iconTheme.color),
              onPressed: () => Navigator.pushNamed(context, '/PatientList'),
            ),
            IconButton(
              icon: Icon(Icons.account_circle, color: Theme.of(context).iconTheme.color),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ICU Patients".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('patient_data')
                    .where('heartRate', isGreaterThan: 0)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No patient data found.".tr()));
                  }

                  final patients = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final p = patients[index].data() as Map<String, dynamic>;

                      return PatientCard(
                        name: p["name"] ?? "Unknown",
                        id: patients[index].id,
                        heartRate: (p["heartRate"] as num?)?.toInt() ?? 0,
                        spo2: (p["spo2"] as num?)?.toInt() ?? 0,
                        bp: "${p["bloodPressure"]?["systolic"] ?? '---'}/${p["bloodPressure"]?["diastolic"] ?? '---'}",
                        systolic: (p["bloodPressure"]?["systolic"] as num?)?.toInt() ?? 0,
                        diastolic: (p["bloodPressure"]?["diastolic"] as num?)?.toInt() ?? 0,
                        ecgStatus: _getEcgStatusFromScore((p["ecgRiskScore"] as num?)?.toDouble()),
                        riskLevel: getRiskLevelFromScore((p["aggregatedRiskScore"] as num?)?.toDouble()),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
