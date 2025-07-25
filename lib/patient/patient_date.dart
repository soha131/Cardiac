import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PatientProfileScreen extends StatelessWidget {
  const PatientProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    Map<String, dynamic> getRiskDisplay(double? score) {
      if (score == null) {
        return {
          'color': Colors.grey,
          'icon': Icons.help_outline,
          'label': 'Unknown'.tr(),
        };
      }

      if (score >= 0.0 && score < 0.33) {
        return {
          'color': Colors.green,
          'icon': Icons.check_circle_rounded,
          'label': 'Stable'.tr(),
        };
      } else if (score >= 0.33 && score < 0.50) {
        return {
          'color': Colors.orange,
          'icon': Icons.report_problem_rounded,
          'label': 'Moderate Risk'.tr(),
        };
      } else if (score >= 0.50 && score <= 1.0) {
        return {
          'color': Colors.red,
          'icon': Icons.warning_amber_rounded,
          'label': 'Critical Risk'.tr(),
        };
      } else {
        return {
          'color': Colors.grey,
          'icon': Icons.help_outline,
          'label': 'Unknown'.tr(),
        };
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Your Profile".tr(),
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        color:
            Theme.of(context).bottomAppBarTheme.color ??
            Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.dashboard,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => Navigator.pushNamed(context, '/patient_profile'),
            ),

            IconButton(
              icon: Icon(
                Icons.account_circle,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => Navigator.pushNamed(context, '/profile'),
            ),
          ],
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('patient_data')
                .doc(uid)
                .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return Center(child: Text("No data found.".tr()));
          }

          final medicalHistory = data['medicalHistory'] as List<dynamic>? ?? [];
          final aggregatedScore =
              (data['aggregatedRiskScore'] as num?)?.toDouble();
          final overallVisual = getRiskDisplay(aggregatedScore);
          final miScore = (data['miRiskScore'] as num?)?.toDouble();
          final hfScore = (data['heartFailureRiskScore'] as num?)?.toDouble();
          final ecgScore = (data['ecgRiskScore'] as num?)?.toDouble();
          final vitalsScore = (data['vitalSignsRiskScore'] as num?)?.toDouble();

          final miVisual = getRiskDisplay(miScore);
          final hfVisual = getRiskDisplay(hfScore);
          final ecgVisual = getRiskDisplay(ecgScore);
          final vitalsVisual = getRiskDisplay(vitalsScore);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 Basic Info Card
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: Text("Name".tr()),
                          subtitle: Text(data['name'] ?? ''),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.cake, color: Colors.purple),
                          title: Text("Age".tr()),
                          subtitle: Text("${data['age'] ?? ''}"),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.wc, color: Colors.pink),
                          title: Text("Gender".tr()),
                          subtitle: Text(data['gender'] ?? ''),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(
                            Icons.fitness_center,
                            color: Colors.orange,
                          ),
                          title: Text("BMI".tr()),
                          subtitle: Text("${data['bmi'] ?? ''}"),
                        ),

                      ],
                    ),
                  ),
                ),


                const SizedBox(height: 24),

                // 🩺 Medical Data Section
                Text(
                  "Medical Data (Filled by Nurse)".tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.favorite, color: Colors.red),
                        title: Text("Heart Rate".tr()),
                        trailing: Text("${data['heartRate'] ?? '--'} bpm"),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.bubble_chart,
                          color: Colors.blue,
                        ),
                        title: Text("SpO2".tr()),
                        trailing: Text("${data['spo2'] ?? '--'}%"),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.monitor_heart,
                          color: Colors.purple,
                        ),
                        title: Text("Blood Pressure".tr()),
                        trailing: Text(
                          data['bloodPressure'] != null
                              ? '${data['bloodPressure']['systolic'] ?? '--'}/${data['bloodPressure']['diastolic'] ?? '--'}'
                              : '--',
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.air, color: Colors.teal),
                        title: Text("Respiratory Rate".tr()),
                        trailing: Text("${data['respiratoryRate'] ?? '--'}"),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.grain, color: Colors.orange),
                        title: Text("Glucose".tr()),
                        trailing: Text("${data['glucose'] ?? '--'}"),
                      ),
                      const Divider(height: 1),
                      _buildEcgChart(data['ecgWaveform'] as List<dynamic>?),
                    ],
                  ),
                ),
                Text(
                  "Prediction Result".tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        _buildRiskTile("Overall Risk Level".tr(), overallVisual, aggregatedScore),
                        const Divider(height: 16),
                        _buildRiskTile("MI Risk".tr(), miVisual, miScore),
                        _buildRiskTile("Heart Failure Risk".tr(), hfVisual, hfScore),
                        _buildRiskTile("ECG Risk".tr(), ecgVisual, ecgScore),
                        _buildRiskTile("Vitals Risk".tr(), vitalsVisual, vitalsScore),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildRiskTile(String title, Map<String, dynamic> visual, double? score) {
    return ListTile(
      leading: Icon(
        visual['icon'],
        color: visual['color'],
        size: 30,
      ),
      title: Text(title),
      subtitle: Text("${visual['label']} (${(score ?? 0.0).toStringAsFixed(2)})"),
    );
  }

  Widget _buildEcgChart(List<dynamic>? ecgData) {
    if (ecgData == null || ecgData.isEmpty) {
      return const Text(
        "--",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      );
    }

    final List<double> ecgValues =
        ecgData.map((e) {
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
        plotAreaBorderWidth: 0, // يخفف حدود الرسم
        primaryXAxis: NumericAxis(
          isVisible: false, // نخفي المحور الأفقي عشان الرسم أنظف
          minimum: 0,
          maximum: ecgValues.length.toDouble(),
        ),
        primaryYAxis: NumericAxis(
          isVisible: false, // نخفي المحور الرأسي
          minimum: ecgValues.reduce((a, b) => a < b ? a : b) - 1,
          maximum: ecgValues.reduce((a, b) => a > b ? a : b) + 1,
        ),
        series: <CartesianSeries<_ChartData, int>>[
          SplineSeries<_ChartData, int>(
            // انسيابية أكثر من الخط العادي
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
}

class _ChartData {
  final int x;
  final double y;
  _ChartData(this.x, this.y);
}
