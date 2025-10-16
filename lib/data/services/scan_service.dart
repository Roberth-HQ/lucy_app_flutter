// lib/data/services/scan_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device_model.dart';

class ScanService {
  // Este es tu NestJS (gateway). Ajusta cuando vayas a la oficina.
  final String baseUrl;

  ScanService({this.baseUrl = 'http://192.168.182.136:3000'});

  /// Envía POST a /dispositivos con {"subred":"182"} y retorna la lista.
  Future<List<Device>> startScan({
    required int subred,
    String? bearerToken,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final Uri uri = Uri.parse('$baseUrl/dispositivos');

    final Map<String, dynamic> body = {
      'subred': subred.toString(),
    };

    final headers = {'Content-Type': 'application/json'};
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    final response = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded.map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
      } else if (decoded is Map<String, dynamic>) {
        return [Device.fromJson(decoded)];
      } else {
        throw Exception('Formato de respuesta desconocido.');
      }
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
