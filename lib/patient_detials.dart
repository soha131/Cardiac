import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'alert.dart';

class PatientDetailScreen extends StatelessWidget {
  final String patientId;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
  });

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


  static String getLstmExplanation(String level) {
    switch (level.toLowerCase()) {
      case 'critical':
      case 'critical risk':
        return "Patient is in critical condition and requires immediate attention.".tr();
      case 'moderate':
      case 'moderate risk':
        return "Patient at moderate risk; monitor closely.".tr();
      case 'stable':
      case 'non-critical risk':
        return "Patient is stable; continue regular monitoring.".tr();
      default:
        return "No risk level data available.".tr();
    }
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("icu_monitoring".tr(),
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(
              child: Text("patient_detail".tr(),
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('patient_data').doc(patientId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return  Center(child: Text("Patient data not found".tr()));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final riskScore = (data['aggregatedRiskScore'] as num?)?.toDouble();
          final level = getRiskLevelFromScore(riskScore);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Text("${data['name'] ?? '--'}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

                const SizedBox(height: 16),

                // ECG Chart with real data
                _buildEcgChart(data['ecgWaveform']),

                const SizedBox(height: 16),
                _vitalBlock("heart_rate".tr(), "${data['heartRate'] ?? '--'} bpm", Colors.blue),
                const SizedBox(height: 12),
                _vitalBlock(
                    "blood_pressure".tr(),
                    data['bloodPressure'] != null
                        ? '${data['bloodPressure']['systolic'] ?? '--'}/${data['bloodPressure']['diastolic'] ?? '--'}'
                        : '--',
                    Colors.blue),
                const SizedBox(height: 12),
                _oxygenBlock(data),
                const SizedBox(height: 16),

                _riskBox(
                  level,
                  getLstmExplanation(level),
                ),




                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0B2346),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text("acknowledge".tr(),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: ()async{
                          final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .get();

                        final role = userDoc.data()?['role'] ?? 'Nurse'; // fallback role

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlertScreen(currentUserRole: role),
                          ),
                        );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text("escalate".tr(),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  "alert_history".tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(patientId) // ← هنا بتحطي الـ UID بتاع اليوزر الحالي
                      .collection('notifications')
                      .orderBy('sentAt', descending: true) // ← لو انتي مسميّاه كده
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text("no_alerts".tr());
                    }

                    final alerts = snapshot.data!.docs;

                    return Column(
                      children: alerts.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final time = (data['sentAt'] as Timestamp).toDate(); // ← اسم الفيلد هنا sentAt مش timestamp
                        final timeFormatted = "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
                        final status = data['risk'] ?? 'unknown';
                        final isEscalated = status == 'Critical Risk';

                        return _alertItem(
                          timeFormatted,
                          status,
                          isEscalated ? Colors.red : Colors.blue,
                          isEscalated ? Icons.warning : Icons.check_circle,
                          DateFormat('EEEE').format(time),
                        );
                      }).toList(),
                    );
                  },
                )

              ],
            ),
          );
        },
      ),
    );
  }

  Widget _vitalBlock(String title, String value, Color lineColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(title, style: const TextStyle(fontSize: 16))),
          Expanded(flex: 5, child: Container()),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _oxygenBlock(Map<String, dynamic> data) {
    return Row(
      children: [
        Text("oxygen_saturation".tr(), style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text("${data['spo2'] ?? '--'}%",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    );
  }

  Widget _riskBox(String level, String explanation) {
    final color = _getColorForRisk(level);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
                children: [
                  TextSpan(text: "${"ai_risk_prediction".tr()} "),
                  TextSpan(text: level.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: "\n$explanation", style: const TextStyle(fontWeight: FontWeight.normal)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color _getColorForRisk(String level) {
    switch (level.toLowerCase()) {
      case "critical"|| 'critical risk':
        return Colors.red;
      case "moderate"||'moderate risk':
        return Colors.orange;
      case "stable"||'non-critical risk':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _alertItem(String time, String status, Color color, IconData icon, String day) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(child: Text(time, style: TextStyle(color: color))),
          Expanded(child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold))),
          Text(day, style: TextStyle(color: color)),
          const SizedBox(width: 8),
          Icon(icon, color: color, size: 20),
        ],
      ),
    );
  }
}
Widget _buildEcgChart(List<dynamic>? ecgData) {
  if (ecgData == null || ecgData.isEmpty) {
    return const Text("--", style: TextStyle(fontSize: 16, color: Colors.grey));
  }

  final List<double> ecgValues = ecgData.map((e) {
    if (e is double) return e;
    if (e is int) return e.toDouble();
    if (e is String) return double.tryParse(e) ?? 0.0;
    return 0.0;
  }).toList();

  final List<_ChartData> chartData = List.generate(
    ecgValues.length,
        (index) => _ChartData(index, ecgValues[index]),
  );

  return SizedBox(
    height: 200,
    child: SfCartesianChart(
      plotAreaBorderWidth: 0,  // يخفف حدود الرسم
      primaryXAxis: NumericAxis(
        isVisible: false,  // نخفي المحور الأفقي عشان الرسم أنظف
        minimum: 0,
        maximum: ecgValues.length.toDouble(),
      ),
      primaryYAxis: NumericAxis(
        isVisible: false,  // نخفي المحور الرأسي
        minimum: ecgValues.reduce((a, b) => a < b ? a : b) - 1,
        maximum: ecgValues.reduce((a, b) => a > b ? a : b) + 1,
      ),
      series: <CartesianSeries<_ChartData, int>>[
        SplineSeries<_ChartData, int>(  // انسيابية أكثر من الخط العادي
          dataSource: chartData,
          xValueMapper: (_ChartData data, _) => data.x,
          yValueMapper: (_ChartData data, _) => data.y,
          color: Colors.blueAccent,
          width: 3,
          markerSettings: const MarkerSettings(isVisible: false),
        ),
      ],
    ),
  );
}

class _ChartData {
  final int x;
  final double y;
  _ChartData(this.x, this.y);
}
