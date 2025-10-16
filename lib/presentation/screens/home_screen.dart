// lib/presentation/screens/home_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../data/models/device_model.dart';
import '../../data/services/scan_service.dart';
import '../../data/services/ws_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScanService _scanService = ScanService(
    baseUrl: 'http://192.168.182.136:3000', // apunta a tu NestJS
  );

  final WsService _wsService = WsService(
    wsUrl: 'ws://192.168.182.136:3000', // ajusta según tu gateway
  );

  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;

  List<Device> _devices = [];
  bool _loading = false;
  int _selectedSubred = 182;

  // lista de subredes para el dropdown (ej. 170-190)
  final List<int> _subredOptions = List.generate(21, (i) => 170 + i);

  @override
  void initState() {
    super.initState();
    _connectWs();
  }

  void _connectWs() {
    try {
      _channel = _wsService.connect();
      _wsSub = _channel!.stream.listen((message) {
        // mensaje puede venir como JSON-string o Map
        Device? d;
        try {
          final decoded = message is String ? jsonDecode(message) : message;
          if (decoded is List) {
            // si viene una lista de dispositivos
            final list = (decoded as List).map((e) => Device.fromJson(Map<String, dynamic>.from(e))).toList();
            setState(() {
              _devices.insertAll(0, list); // insertar al inicio
            });
          } else if (decoded is Map) {
            d = Device.fromJson(Map<String, dynamic>.from(decoded));
            setState(() {
              _devices.insert(0, d!);
            });
          }
        } catch (e) {
          // ignorar mensajes no-JSON
        }
      }, onError: (err) {
        // manejar error de WS
      }, onDone: () {
        // reconectar si se cae (opcional)
      });
    } catch (e) {
      // no conectado
    }
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _wsService.disconnect();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() => _loading = true);
    try {
      // Llamamos al NestJS que reenvía al microservicio de escaneo.
      final results = await _scanService.startScan(subred: _selectedSubred);
      // Si backend retorna resultados inmediatos, los mostramos también
      setState(() {
        _devices.insertAll(0, results);
      });
    } catch (e) {
      // mostrar error sencillo
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  IconData _iconForDevice(String deviceStr) {
    final s = deviceStr.toLowerCase();
    if (s.contains('nas') || s.contains('windows') || s.contains('desktop') || s.contains('pc') || s.contains('workstation')) {
      return Icons.computer;
    } else if (s.contains('camera') || s.contains('cam') || s.contains('ipcamera')) {
      return Icons.videocam;
    } else if (s.contains('printer') || s.contains('epson') || s.contains('hp')) {
      return Icons.print;
    } else if (s.contains('router') || s.contains('gateway')) {
      return Icons.router;
    } else if (s.contains('linux') || s.contains('unix') || s.contains('ssh')) {
      return Icons.laptop;
    } else {
      return Icons.devices; // genérico
    }
  }

  Widget _buildDeviceTile(Device d) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        leading: Icon(_iconForDevice(d.device), size: 36),
        title: Text(d.name.isEmpty ? d.ip : d.name),
        subtitle: Text('${d.device} • ${d.ip}\nMAC: ${d.mac} • via ${d.via}'),
        isThreeLine: true,
        trailing: Text(d.alive, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner - Minimal Fing'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedSubred,
                    items: _subredOptions
                        .map((v) => DropdownMenuItem(value: v, child: Text(v.toString())))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSubred = v ?? _selectedSubred),
                    decoration: const InputDecoration(labelText: 'Subred (último octeto)'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _startScan,
                  child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Scan'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _devices.isEmpty
                ? const Center(child: Text('No hay dispositivos aún. Presiona Scan.'))
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) => _buildDeviceTile(_devices[index]),
                  ),
          ),
        ],
      ),
    );
  }
}
