import 'package:volume_controller/volume_controller.dart';

abstract interface class SystemVolumeController {
  Future<double> getVolume();
  Future<void> setVolume(double value);
  void addListener(void Function(double value) listener);
  void dispose();
}

class DeviceSystemVolumeController implements SystemVolumeController {
  DeviceSystemVolumeController([VolumeController? controller])
      : _controller = controller ?? VolumeController();

  final VolumeController _controller;

  @override
  Future<double> getVolume() => _controller.getVolume();

  @override
  Future<void> setVolume(double value) async {
    _controller.setVolume(value);
  }

  @override
  void addListener(void Function(double value) listener) {
    _controller.listener(listener);
  }

  @override
  void dispose() {
    _controller.removeListener();
  }
}
