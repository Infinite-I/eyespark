class BluetoothDeviceModel {
  final String id;
  final String name;
  final bool isConnected;

  BluetoothDeviceModel({
    required this.id,
    required this.name,
    this.isConnected = false,
  });

  BluetoothDeviceModel copyWith({
    bool? isConnected,
  }) {
    return BluetoothDeviceModel(
      id: id,
      name: name,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}