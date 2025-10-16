// lib/data/models/device_model.dart
class Device {
  final String alive;
  final String device; // mapped from "divice" in backend
  final String ip;
  final String mac;
  final String name;
  final String via;

  Device({
    required this.alive,
    required this.device,
    required this.ip,
    required this.mac,
    required this.name,
    required this.via,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    // Algunos backends tienen la clave "divice" con typo — lo manejamos.
    final deviceField = json['device'] ?? json['divice'] ?? '';

    return Device(
      alive: (json['alive'] ?? '').toString(),
      device: deviceField.toString(),
      ip: (json['ip'] ?? '').toString(),
      mac: (json['mac'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      via: (json['via'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'alive': alive,
        'divice': device,
        'ip': ip,
        'mac': mac,
        'name': name,
        'via': via,
      };
}
