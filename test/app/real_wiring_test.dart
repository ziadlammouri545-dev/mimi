import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mimi/core/platform/platform_info.dart';
import 'package:mimi/core/storage/secret_store.dart';
import 'package:mimi/core/storage/settings_store.dart';
import 'package:mimi/core/storage/storage_providers.dart';
import 'package:mimi/core/use_fakes.dart';
import 'package:mimi/features/camera/data/camera_providers.dart';
import 'package:mimi/features/camera/domain/camera_source.dart';
import 'package:mimi/features/device/data/device_providers.dart';
import 'package:mimi/features/device/domain/device_client.dart';
import 'package:mimi/features/onboarding/data/onboarding_providers.dart';
import 'package:mimi/features/onboarding/domain/device_discovery.dart';
import 'package:mimi/features/onboarding/domain/pairing_repository.dart';
import 'package:mimi/features/providers/data/llm_providers.dart';
import 'package:mimi/features/providers/domain/fish_repository.dart';
import 'package:mimi/features/harness/data/desktop_harness_repository.dart';
import 'package:mimi/features/harness/data/harness_providers.dart';
import 'package:mimi/features/harness/data/null_harness_repository.dart';
import 'package:mimi/features/harness/domain/harness_repository.dart';
import 'package:mimi/features/providers/domain/provider_repository.dart';

/// With the fakes off, every provider has to build. The app runs this way,
/// so a provider left unimplemented fails here first.
void main() {
  test('nothing is left unimplemented when useFakes is false', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final container = ProviderContainer(
      overrides: [useFakesProvider.overrideWithValue(false)],
    );
    addTearDown(container.dispose);

    expect(container.read(secretStoreProvider), isA<SecretStore>());
    expect(container.read(settingsStoreProvider), isA<SettingsStore>());
    expect(container.read(deviceClientProvider), isA<DeviceClient>());
    expect(container.read(cameraSourceProvider), isA<CameraSource>());
    expect(container.read(deviceDiscoveryProvider), isA<DeviceDiscovery>());
    expect(container.read(pairingRepositoryProvider), isA<PairingRepository>());
    expect(
      container.read(providerRepositoryProvider),
      isA<ProviderRepository>(),
    );
    expect(container.read(fishRepositoryProvider), isA<FishRepository>());
    // The real one on a desktop, NullHarnessRepository on a phone. Building
    // it starts no server and spawns nothing; setEnabled(true) does that.
    final harness = container.read(harnessRepositoryProvider);
    expect(harness, isA<HarnessRepository>());
    expect(
      container.read(platformInfoProvider).canHostHarness
          ? harness is DesktopHarnessRepository
          : harness is NullHarnessRepository,
      isTrue,
    );
  });

  test('an unpaired app still builds a client, it just has no board', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final container = ProviderContainer(
      overrides: [useFakesProvider.overrideWithValue(false)],
    );
    addTearDown(container.dispose);

    final api = container.read(deviceApiProvider);
    expect(api.baseUrl, 'http://localhost:8080');
    expect(api.wsUri.toString(), startsWith('ws://localhost:8080/ws'));
  });
}
