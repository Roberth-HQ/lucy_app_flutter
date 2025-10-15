class Device {
  final String alive;
  final String device;
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
    return Device(
      alive: json['alive'] ?? '',
      device: json['divice'] ?? '', // <- nota: tu JSON original tiene "divice"
      ip: json['ip'] ?? '',
      mac: json['mac'] ?? '',
      name: json['name'] ?? '',
      via: json['via'] ?? '',
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
