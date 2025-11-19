import 'dart:convert';

import 'package:cardiac_app/core/patient_data_model.dart';
import 'package:cardiac_app/core/risk_prediction_state.dart';
import 'package:cardiac_app/core/risk_result_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class RiskPredictionCubit extends Cubit<RiskPredictionState> {
  RiskPredictionCubit() : super(RiskInitial());

  //final String baseUrl = 'http://192.168.100.6:8000';
    final String baseUrl = "http://10.0.2.2:8000";
  Future<RiskPredictionState> predictMiRiskFloat(XGBoostRequest data) async {
    return _predictRisk(data.toJson(), '/MI_risk_float');
  }

  Future<RiskPredictionState> predictMiRiskBinary(XGBoostRequest data) async {
    return _predictRisk(data.toJson(), '/MI_risk_binary');
  }

  Future<RiskPredictionState> predictHeartFailureFloat(XGBoostRequest data) async {
    return _predictRisk(data.toJson(), '/heart_failur_risk_float');
  }

  Future<RiskPredictionState> predictHeartFailureBinary(XGBoostRequest data) async {
    return _predictRisk(data.toJson(), '/heart_failur_risk_binary');
  }

  Future<RiskPredictionState> predictCnnRiskFloat(CnnRequest data) async {
    return _predictRisk(data.toJson(), '/arrhythmia_risk_float');
  }

  Future<RiskPredictionState> predictCnnRiskBinary(CnnRequest data) async {
    return _predictRisk(data.toJson(), '/arrhythmia_risk_binary');
  }

  Future<RiskPredictionState> predictLstmRiskFloat(LstmRequest data) async {
    return _predictRisk(data.toJson(), '/sca_risk_float');
  }

  Future<RiskPredictionState> predictLstmRiskBinary(LstmRequest data) async {
    return _predictRisk(data.toJson(), '/sca_risk_binary');
  }

  Future<RiskPredictionState> predictAggregatedRisk(Map<String, dynamic> data) async {
    return _predictRisk(data, '/risk_score');
  }

  Future<RiskPredictionState> _predictRisk(Map<String, dynamic> body, String endpoint) async {
    emit(RiskLoading());
    try {

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );


      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // 👇 التعامل مع نوعين من النتائج
        final double score = (decoded is bool)
            ? (decoded ? 1.0 : 0.0) // لو boolean خليه 1 أو 0
            : double.tryParse(decoded.toString()) ?? 0.0;

        final result = RiskPrediction(score: score);

        final successState = RiskSuccess(result);
        emit(successState);
        return successState;
      } else {
        final error = RiskError('Error ($endpoint): ${response.statusCode}');

        emit(error);
        return error;
      }
    } catch (e) {
      final error = RiskError('Exception ($endpoint): $e');

      emit(error);
      return error;
    }
  }
}
