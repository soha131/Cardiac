import 'package:cardiac_app/core/risk_prediction_cubit.dart';
import 'package:cardiac_app/core/risk_prediction_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/patient_data_model.dart';
import '../notification/notification.dart';

class NurseEntryScreen extends StatefulWidget {
  final String patientId;
  final Map<String, dynamic> patientData;

  const NurseEntryScreen({
    super.key,
    required this.patientId,
    required this.patientData,
  });

  @override
  State<NurseEntryScreen> createState() => _NurseEntryScreenState();
}

class _NurseEntryScreenState extends State<NurseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heartRate = TextEditingController();
  final _spo2 = TextEditingController();
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  final _ecg = TextEditingController();
  final _respiratoryRateController = TextEditingController();



  final _hbController = TextEditingController();
  final _pltController = TextEditingController();
  final _ptController = TextEditingController();
  final _apttController = TextEditingController();
  final _naController = TextEditingController();
  final _kController = TextEditingController();
  final _glucController = TextEditingController();
  final _albController = TextEditingController();
  final _astController = TextEditingController();
  final _altController = TextEditingController();
  final _bunController = TextEditingController();
  final _crController = TextEditingController();

  String? _selectedHtn;
  String? _selectedDm;
  String? _selectedEcg;
  String? _selectedPft;
  String? _selectedBmiCategory;
  String? _selectedAgeGroup;

  @override
  void initState() {
    super.initState();
    final data = widget.patientData;

    if (data['heartRate'] != null) _heartRate.text = data['heartRate'].toString();
    if (data['spo2'] != null) _spo2.text = data['spo2'].toString();
    if (data['respiratoryRate'] != null) _respiratoryRateController.text = data['respiratoryRate'].toString();
    if (data['bloodPressure'] != null) {
      final bp = data['bloodPressure'] as Map<String, dynamic>;
      if (bp['systolic'] != null) _systolic.text = bp['systolic'].toString();
      if (bp['diastolic'] != null) _diastolic.text = bp['diastolic'].toString();
    }
    if (data['ecgWaveform'] != null && data['ecgWaveform'] is List) {
      final ecgList = List.from(data['ecgWaveform']);
      _ecg.text = ecgList.join(',');
    }


    _hbController.text = data['preop_hb']?.toString() ?? '';
    _pltController.text = data['preop_plt']?.toString() ?? '';
    _ptController.text = data['preop_pt']?.toString() ?? '';
    _apttController.text = data['preop_aptt']?.toString() ?? '';
    _naController.text = data['preop_na']?.toString() ?? '';
    _kController.text = data['preop_k']?.toString() ?? '';
    _glucController.text = data['preop_gluc']?.toString() ?? '';
    _albController.text = data['preop_alb']?.toString() ?? '';
    _astController.text = data['preop_ast']?.toString() ?? '';
    _altController.text = data['preop_alt']?.toString() ?? '';
    _bunController.text = data['preop_bun']?.toString() ?? '';
    _crController.text = data['preop_cr']?.toString() ?? '';

    _selectedHtn = data['preop_htn'];
    _selectedDm = data['preop_dm'];
    _selectedEcg = data['preop_ecg'];
    _selectedPft = data['preop_pft'];
    _selectedAgeGroup = data['age_group'];
    _selectedBmiCategory = data['bmi_category'];
  }
  String getRiskLevelFromScore(double? score) {
    if (score == null) return "Unknown";

    if (score >= 0.0 && score < 0.33) {
      return "Stable";
    } else if (score >= 0.33 && score < 0.66) {
      return "Moderate Risk";
    } else if (score >= 0.66 && score <= 1.0) {
      return "Critical Risk";
    } else {
      return "Unknown"; // لو فيه رقم خارج النطاق لأي سبب
    }
  }
  final bmiOptions = ['underweight', 'normal', 'overweight', 'obese'];
  final ageGroupOptions = ['young', 'middle', 'senior', 'elderly'];

  final ecgOptions = [
    "Normal Sinus Rhythm",
    "Left anterior fascicular block",
    "1st degree A-V block, Left bundle branch block",
    "1st degree A-V block",
    "Atrial fibrillation",
    "Incomplete right bundle branch block, Left anterior fascicular block",
    "Atrial fibrillation, Right bundle branch block",
    "Premature supraventricular and ventricular complexes, Right bundle branch block",
    "Atrial fibrillation with slow ventricular response",
    "Right bundle branch block",
    "Incomplete right bundle branch block",
    "Left anterior hemiblock",
    "Atrial fibrillation with rapid ventricular response",
    "Premature ventricular complexes",
    "Left posterior fascicular block",
    "Atrial fibrillation with premature ventricular, Incomplete left bundle block",
    "Premature atrial complexes",
    "1st degree A-V block with Premature supraventricular complexes, Left bundle branch block",
    "1st degree A-V block with Premature atrial complexes",
    "Atrial fibrillation with premature ventricular or aberrantly conducted complexes",
    "Atrial flutter with 2:1 A-V conduction",
    "Premature supraventricular complexes",
    "Electronic ventricular pacemaker",
    "AV sequential or dual chamber electronic pacemaker",
    "Right bundle branch block, Left anterior fascicular block",
    "Complete right bundle branch block, occasional premature supraventricular complexes",
    "Atrial flutter with variable A-V block"
  ];

  final pftOptions = [
    'Normal', 'Mild obstructive', 'Mild restrictive', 'Moderate obstructive',
    'Borderline obstructive', 'Mixed or pure obstructive', 'Severe restrictive',
    'Moderate restrictive', 'Severe obstructive'
  ];

  @override
  void dispose() {
    _heartRate.dispose();
    _spo2.dispose();
    _systolic.dispose();
    _diastolic.dispose();
    _ecg.dispose();
    _respiratoryRateController.dispose();


    _hbController.dispose();
    _pltController.dispose();
    _ptController.dispose();
    _apttController.dispose();
    _naController.dispose();
    _kController.dispose();
    _glucController.dispose();
    _albController.dispose();
    _astController.dispose();
    _altController.dispose();
    _bunController.dispose();
    _crController.dispose();
    super.dispose();
  }


  void _submitMedicalData() async {
    if (!_formKey.currentState!.validate()) return;
    print("widget.patientId:${widget.patientId}");

    try {
      final parsedHeartRate = double.parse(_heartRate.text);
      final parsedSystolic = double.parse(_systolic.text);
      final parsedDiastolic = double.parse(_diastolic.text);
      final parsedSpO2 = double.parse(_spo2.text);
      final parsedRespRate = double.parse(_respiratoryRateController.text);
      final ecgList = _parseEcgList(_ecg.text);

      final xgbData = XGBoostRequest(
        age: (widget.patientData['age'] as num).toDouble(),
        sex: widget.patientData['sex'] ?? 'F',
        bmi: (widget.patientData['bmi'] as num).toDouble(),
        ageGroup: _selectedAgeGroup!,
        bmiCategory: _selectedBmiCategory!,
        preopHtn: _selectedHtn!,
        preopDm: _selectedDm!,
        preopEcg: _selectedEcg!,
        preopPft: _selectedPft!,
        preopHb: double.parse(_hbController.text),
        preopPlt: double.parse(_pltController.text),
        preopPt: double.parse(_ptController.text),
        preopAptt: double.parse(_apttController.text),
        preopNa: double.parse(_naController.text),
        preopK: double.parse(_kController.text),
        preopGluc: double.parse(_glucController.text),
        preopAlb: double.parse(_albController.text),
        preopAst: double.parse(_astController.text),
        preopAlt: double.parse(_altController.text),
        preopBun: double.parse(_bunController.text),
        preopCr: double.parse(_crController.text),
      );

      final lstmData = LstmRequest(
        data: List.generate(1, (_) => [
          parsedHeartRate,
          parsedSystolic,
          parsedDiastolic,
          double.parse(((parsedSystolic + parsedDiastolic) / 2).toStringAsFixed(1)),
          parsedSpO2,
          parsedRespRate,
        ]),
      );

      final cnnData = CnnRequest(ecgSignal: ecgList);
      final cubit = context.read<RiskPredictionCubit>();

      final aggregatedRequest = {
        ...xgbData.toJson(),
        "ecg_signal": ecgList,
        "lstm_data": lstmData.data,
      };

      final results = await Future.wait([
        cubit.predictMiRiskFloat(xgbData),
        cubit.predictMiRiskBinary(xgbData),
        cubit.predictHeartFailureFloat(xgbData),
        cubit.predictHeartFailureBinary(xgbData),
        cubit.predictCnnRiskFloat(cnnData),
        cubit.predictCnnRiskBinary(cnnData),
        cubit.predictLstmRiskFloat(lstmData),
        cubit.predictLstmRiskBinary(lstmData),
        cubit.predictAggregatedRisk(aggregatedRequest),
      ]);

      double? miScore, miBinary;
      double? hfScore, hfBinary;
      double? cnnScore, cnnBinary;
      double? lstmScore, lstmBinary;
      double? totalScore;

      if (results[0] is RiskSuccess) miScore = (results[0] as RiskSuccess).result.score;
      if (results[1] is RiskSuccess) miBinary = (results[1] as RiskSuccess).result.score;
      if (results[2] is RiskSuccess) hfScore = (results[2] as RiskSuccess).result.score;
      if (results[3] is RiskSuccess) hfBinary = (results[3] as RiskSuccess).result.score;
      if (results[4] is RiskSuccess) cnnScore = (results[4] as RiskSuccess).result.score;
      if (results[5] is RiskSuccess) cnnBinary = (results[5] as RiskSuccess).result.score;
      if (results[6] is RiskSuccess) lstmScore = (results[6] as RiskSuccess).result.score;
      if (results[7] is RiskSuccess) lstmBinary = (results[7] as RiskSuccess).result.score;
      if (results[8] is RiskSuccess) totalScore = (results[8] as RiskSuccess).result.score;

      if ([miScore, miBinary, hfScore, hfBinary, cnnScore, cnnBinary, lstmScore, lstmBinary, totalScore]
          .any((e) => e != null)) {
        await FirebaseFirestore.instance.collection('patient_data').doc(widget.patientId).update({
          'heartRate': parsedHeartRate,
          'spo2': parsedSpO2,
          'respiratoryRate': parsedRespRate,
          'bloodPressure': {
            'systolic': parsedSystolic,
            'diastolic': parsedDiastolic,
          },
          'ecgWaveform': ecgList,
          'miRiskScore': miScore,
          'miRiskBinary': miBinary,
          'heartFailureRiskScore': hfScore,
          'heartFailureRiskBinary': hfBinary,
          'ecgRiskScore': cnnScore,
          'ecgRiskBinary': cnnBinary,
          'vitalSignsRiskScore': lstmScore,
          'vitalSignsRiskBinary': lstmBinary,
          'aggregatedRiskScore': totalScore,
          'glucose': double.parse(_glucController.text),
          'riskUpdatedAt': DateTime.now(),
          'updatedByNurseAt': Timestamp.now(),
          ...xgbData.toJson(),
        });

        /// 🟡 إرسال إشعارات بعد التحديث
        final level = getRiskLevelFromScore(totalScore);
        final valuesText = '🫀 Heart Rate: $parsedHeartRate bpm\n🩸 BP: $parsedSystolic/$parsedDiastolic mmHg\n🧪 SpO2: $parsedSpO2%';

        try {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.patientId).get();
          final patientName = userDoc.data()?['name'] ?? 'Unknown';
          final patientToken = userDoc.data()?['fcmToken'];

          if (patientToken != null) {
            final patientMessage =
                "Your latest health risk level is: $level.\n\n$valuesText";

            await sendFCMToSpecificUser(
              title: "🩺 Your Risk Status: $level",
              body: patientMessage,
              userFcmToken: patientToken,
            );

            await FirebaseFirestore.instance
                .collection('users')
                .doc(widget.patientId)
                .collection('notifications')
                .add({
              'title': "🩺 Your Risk Status: $level",
              'body': patientMessage,
              'risk': level,
              'sentAt': Timestamp.now(), // ← دي لحظية ومضمونة
            });

          }

          final staffSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('role', whereIn: ['Nurse', 'Doctor'])
              .get();

          for (var doc in staffSnapshot.docs) {
            final staffToken = doc.data()['fcmToken'];
            final staffId = doc.id;

            if (staffToken != null) {
              final staffMessage =
                  "$patientName is currently at $level level.\n\n$valuesText";

              await sendFCMToSpecificUser(
                title: "🚨 Alert: $patientName is $level",
                body: staffMessage,
                userFcmToken: staffToken,
              );
              await FirebaseFirestore.instance
                  .collection('notifications')
                  .add({
                'title': "🚨 Alert: $patientName is $level",
                'body': staffMessage,
                'timestamp': FieldValue.serverTimestamp(),
                'targetRole': doc.data()['role'], // "Nurse" or "Doctor"
                'name': patientName,
                'alert': "$patientName is currently at $level level.",
                'risk': level, // "low", "moderate", or "critical"
                'valuesData':valuesText
              });

            }
          }
        } catch (e) {
          print("❌ Failed to send notifications: $e");
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✅ MI: $miScore ($miBinary) | HF: $hfScore ($hfBinary) | ECG: $cnnScore ($cnnBinary) | Vitals: $lstmScore ($lstmBinary) | Total: $totalScore'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل في التنبؤ بالخطورة')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: ${e.toString()}')),
      );
    }
  }


  List<double> _parseEcgList(String input) {
    return input
        .split(',')
        .map((e) => double.tryParse(e.trim()))
        .whereType<double>()
        .toList();
  }

  Widget _buildDropdown(String label, String? value, List<String> options, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              value: value,
              items: options.map((e) {
                return DropdownMenuItem<String>(
                  value: e, // القيمة الفعلية (غير مترجمة)
                  child: Text(e.tr()), // عرض الترجمة فقط
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
  @override
  Widget build(BuildContext context) {
    final data = widget.patientData;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${'Update'.tr()}: ${data['name'] ?? 'Patient'}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Basic Info'.tr(), style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('${'Name'.tr()}: ${data['name'] ?? ''}'),
              Text('${'Age'.tr()}: ${data['age'] ?? ''}'),
              Text('${'Gender'.tr()}: ${data['gender'] ?? ''}'),
              const Divider(height: 32),

              _buildField('Heart Rate'.tr(), _heartRate),
              _buildField('SpO2'.tr(), _spo2),
              _buildField('Respiratory Rate'.tr(), _respiratoryRateController),

              _buildCard([
                _buildField('Systolic BP'.tr(), _systolic),
                _buildField('Diastolic BP'.tr(), _diastolic),
              ]),


              _buildField('ECG (12 values)'.tr(), _ecg),
              const Divider(height: 32),
              Text('Pre-op Medical Data'.tr(), style: Theme.of(context).textTheme.titleMedium),

              _buildDropdown('BMI Category'.tr(), _selectedBmiCategory,
                  bmiOptions, (val) => setState(() => _selectedBmiCategory = val)),
              _buildDropdown('Age Group'.tr(), _selectedAgeGroup,
                  ageGroupOptions, (val) => setState(() => _selectedAgeGroup = val)),

              _buildDropdown('Pre-op Hypertension'.tr(), _selectedHtn, ['N', 'Y'], (val) => setState(() => _selectedHtn = val)),
              _buildDropdown('Pre-op Diabetes'.tr(), _selectedDm, ['N', 'Y'], (val) => setState(() => _selectedDm = val)),
              _buildDropdown('Pre-op ECG'.tr(), _selectedEcg,
                  ecgOptions, (val) => setState(() => _selectedEcg = val)),

              _buildDropdown('Pre-op PFT'.tr(), _selectedPft,
                  pftOptions, (val) => setState(() => _selectedPft = val)),

              _buildCard([
                _buildField('Pre-op Hb'.tr(), _hbController),
                _buildField('Pre-op PLT'.tr(), _pltController),
                _buildField('Pre-op PT'.tr(), _ptController),
                _buildField('Pre-op APTT'.tr(), _apttController),
              ]),
              _buildCard([
                _buildField('Pre-op Na'.tr(), _naController),
                _buildField('Pre-op K'.tr(), _kController),
                _buildField('Pre-op Glucose'.tr(), _glucController),
                _buildField('Pre-op Albumin'.tr(), _albController),
              ]),
              _buildCard([
                _buildField('Pre-op AST'.tr(), _astController),
                _buildField('Pre-op ALT'.tr(), _altController),
                _buildField('Pre-op BUN'.tr(), _bunController),
                _buildField('Pre-op Cr'.tr(), _crController),
              ]),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitMedicalData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(horizontal: 82, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Submit'.tr(), style: const TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),side:BorderSide(width: .5)),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (val) => (val == null || val.isEmpty) ? 'Required'.tr() : null,
      ),
    );
  }
}
