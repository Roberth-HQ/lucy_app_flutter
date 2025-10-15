// lib/data/services/scan_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device_model.dart';

class ScanService {
  // Ajusta la URL según donde estés probando:
  // - Android emulator: use 'http://10.0.2.2:8081'
  // - iOS simulator / desktop: 'http://localhost:8081'
  // - Real device: 'http://<TU_IP_LOCAL>:8081'
  final String baseUrl;

  ScanService({this.baseUrl = 'http://localhost:8081'});

  /// Inicia un escaneo enviando el número de subred (ej. 181)
  /// Devuelve la lista de Device recibidos desde el backend.
  Future<List<Device>> startScan({
    required int subnet,
    String? bearerToken, // opcional, si tu backend usa auth
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final Uri uri = Uri.parse('$baseUrl/scan');

    final Map<String, dynamic> body = {
      'subnet': subnet, // usa la clave que tu backend espera
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    final response = await http
        .post(uri, headers: headers, body: jsonEncode(body))
        .timeout(timeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // asumiendo que el backend devuelve un array JSON de dispositivos
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
    } else if (response.statusCode == 202) {
      // 202 Accepted -> backend aceptó el trabajo y lo hará en background.
      // Deberías implementar una ruta para consultar resultados o usar WebSocket.
      throw Exception('Scan accepted and will be processed (202). Implement polling.');
    } else {
      // manejo simple de errores
      final msg = response.body.isNotEmpty ? response.body : 'Status ${response.statusCode}';
      throw Exception('Error starting scan: $msg');
    }
  }

  /// Variante si prefieres llamar con path param GET: /scan/181
  /// (por si decides implementar GET en el backend)
  Future<List<Device>> startScanWithGet({
    required int subnet,
    String? bearerToken,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final Uri uri = Uri.parse('$baseUrl/scan/$subnet');

    final headers = <String, String>{};
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }

    final response = await http.get(uri, headers: headers).timeout(timeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error GET scan: ${response.statusCode} ${response.body}');
    }
  }
}
