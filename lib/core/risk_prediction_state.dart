import 'risk_result_model.dart';

abstract class RiskPredictionState {}

class RiskInitial extends RiskPredictionState {}

class RiskLoading extends RiskPredictionState {}

class RiskSuccess extends RiskPredictionState {
  final RiskPrediction result;

  RiskSuccess(this.result);
}

class RiskError extends RiskPredictionState {
  final String message;

  RiskError(this.message);
}
