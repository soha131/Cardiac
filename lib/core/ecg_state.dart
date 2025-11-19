import 'package:equatable/equatable.dart';

abstract class ECGState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ECGInitial extends ECGState {}

class ECGLoading extends ECGState {}

class ECGSuccess extends ECGState {
  final String predictedClass;
  final double confidence;

  ECGSuccess({
    required this.predictedClass,
    required this.confidence,
  });

  @override
  List<Object?> get props => [predictedClass, confidence];
}

class ECGError extends ECGState {
  final String message;

  ECGError(this.message);

  @override
  List<Object?> get props => [message];
}
