import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme_context.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/mimi_button.dart';
import '../../../core/widgets/mimi_text_field.dart';
import '../../onboarding/presentation/bluetooth/setup_copy.dart';
import '../../onboarding/presentation/bluetooth/stage_layout.dart';
import 'change_wifi.dart';

/// Mimi is online: the new network goes over the LAN with the token. The
/// board answers, then drops off and comes back on the new network.
class LanWifiForm extends ConsumerStatefulWidget {
  const LanWifiForm({super.key, required this.bluetooth});

  /// Offer the Bluetooth path too, for a board that is about to move.
  final bool bluetooth;

  @override
  ConsumerState<LanWifiForm> createState() => _LanWifiFormState();
}

class _LanWifiFormState extends ConsumerState<LanWifiForm> {
  final _ssid = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _ssid.dispose();
    _password.dispose();
    super.dispose();
  }

  void _send() => ref
      .read(changeWifiProvider.notifier)
      .send(ssid: _ssid.text, password: _password.text);

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(changeWifiProvider);
    final moved = s.movedTo;
    return StageLayout(
      label: '// Wi-Fi · Over the network',
      title: moved == null ? 'Point it elsewhere.' : 'Mimi is moving.',
      emphasis: moved == null ? 'elsewhere' : 'moving',
      lead: moved == null
          ? 'Mimi is online, so the new network goes straight to it. It '
                'reaches 2.4 GHz networks only.'
          : 'It drops off for a moment and comes back on $moved. If this '
                'phone is not on $moved, Mimi shows as offline here.',
      children: [
        if (moved == null) ...[
          MimiTextField(
            controller: _ssid,
            label: '// Wi-Fi name',
            hint: 'Exactly as the router spells it',
            autofocus: true,
          ),
          const SizedBox(height: Space.md),
          MimiTextField(
            controller: _password,
            label: '// Wi-Fi password',
            hint: 'Leave empty for an open network',
            obscure: true,
            textInputAction: TextInputAction.go,
            onSubmitted: (_) => _send(),
          ),
          if (s.error != null) StageError(failureCopy(s.error!)),
          const SizedBox(height: Space.lg),
          MimiButton(
            label: 'Move Mimi',
            trailingArrow: true,
            expand: true,
            isLoading: s.busy,
            onPressed: s.busy ? null : _send,
          ),
          if (widget.bluetooth) ...[
            const SizedBox(height: Space.sm),
            MimiButton.ghost(
              label: 'Use Bluetooth instead',
              icon: Icons.bluetooth,
              onPressed: ref.read(changeWifiProvider.notifier).useBluetooth,
            ),
          ],
        ] else
          MimiButton(
            label: 'Back to settings',
            expand: true,
            onPressed: () => context.go('/settings'),
          ),
      ],
    );
  }
}

/// Mimi is out of reach: how setup mode starts, and the way in.
class SetupModeNote extends ConsumerWidget {
  const SetupModeNote({super.key, required this.bluetooth});

  final bool bluetooth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StageLayout(
      label: '// Wi-Fi · Out of reach',
      title: 'Mimi cannot hear this device.',
      emphasis: 'hear',
      lead:
          'If it moved, it opens setup mode by itself 30 seconds after it '
          'fails to join its old network, and its screen shows a six digit '
          'code. Wi-Fi setup on its own menu does the same.',
      children: [
        if (bluetooth)
          MimiButton(
            label: 'Set up over Bluetooth',
            icon: Icons.bluetooth_searching,
            expand: true,
            onPressed: ref.read(changeWifiProvider.notifier).useBluetooth,
          )
        else
          Text(
            'Bluetooth setup runs on a phone. Open Mimi there, or bring the '
            'board back within reach of this network.',
            style: context.text.bodySmall,
          ),
      ],
    );
  }
}
