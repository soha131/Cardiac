import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'ecg_state.dart';

class ECGCubit extends Cubit<ECGState> {
  ECGCubit() : super(ECGInitial());

 // final String baseUrl = "http://192.168.100.6:8000";
  final String baseUrl = "http://10.0.2.2:8000";
  Future<void> predictECG(File imageFile) async {
    try {
      emit(ECGLoading());

      final uri = Uri.parse("$baseUrl/predict");

      final request = http.MultipartRequest("POST", uri)
        ..files.add(
          await http.MultipartFile.fromPath("file", imageFile.path),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        emit(
          ECGSuccess(
            predictedClass: data["predicted_class"],
            confidence: (data["confidence"] as num).toDouble(),
          ),
        );
      } else {
        emit(ECGError("Server error: ${response.statusCode}"));
      }
    } catch (e) {
      emit(ECGError(e.toString()));
    }
  }
}
