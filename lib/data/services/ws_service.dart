// lib/data/services/ws_service.dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/device_model.dart';

/// Servicio simple para conectarse al WebSocket del gateway de NestJS.
/// Ajusta `wsUrl` a la dirección de tu servidor (p. ej. ws://192.168.182.136:3000).
class WsService {
  final String wsUrl;
  WebSocketChannel? _channel;

  WsService({this.wsUrl = 'ws://192.168.182.136:3000'});

  /// Conectar y obtener stream crudo
  WebSocketChannel connect() {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    return _channel!;
  }

  /// Cerrar conexión
  void disconnect() {
    _channel?.sink.close();
  }

  /// Convierte mensajes JSON del WS a Device (si aplica)
  /// Nota: depende de cómo tu gateway emita eventos; normalmente emite objetos JSON
  Device? parseDeviceMessage(dynamic message) {
    try {
      final Map<String, dynamic> decoded = message is String ? jsonDecode(message) : Map<String, dynamic>.from(message);
      return Device.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
