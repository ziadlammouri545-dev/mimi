import '../../../core/result.dart';
import '../../device/domain/device.dart';
import '../domain/device_discovery.dart';

/// Two boards appear a moment apart, like mDNS answers trickling in.
class FakeDeviceDiscovery implements DeviceDiscovery {
  static const _boards = [
    Device(
      id: 'mimi-a1b2',
      name: 'Mimi',
      host: '192.168.1.40',
      fwVersion: '0.1.0',
    ),
    Device(
      id: 'mimi-mock',
      name: 'Mimi Mock',
      host: 'localhost:8080',
      fwVersion: '0.1.0-mock',
    ),
  ];

  @override
  Stream<List<Device>> discover() async* {
    yield const [];
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    yield [_boards[0]];
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    yield _boards;
  }

  @override
  Future<Result<Device>> probe(String host) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (host.trim().isEmpty) {
      return const Err(NetworkFailure('Enter an address first'));
    }
    return Ok(
      Device(
        id: 'mimi-mock',
        name: 'Mimi',
        host: host,
        fwVersion: '0.1.0-mock',
      ),
    );
  }
}
