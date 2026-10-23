# Mimi firmware

ESP-IDF v5.5.5 firmware for the LilyGO T-CameraPlus-S3 V1.2.

```
idf.py build
idf.py -p <port> flash
```

- Building, flashing, partitions, boot, tasks, memory and every component: [docs/FIRMWARE.md](../docs/FIRMWARE.md)
- The voice pipeline: [docs/FIRMWARE_CLOUD.md](../docs/FIRMWARE_CLOUD.md)
- Audio: [docs/FIRMWARE_AUDIO.md](../docs/FIRMWARE_AUDIO.md)
- The screen: [docs/FIRMWARE_SCREEN.md](../docs/FIRMWARE_SCREEN.md)
- The serial console: [docs/FIRMWARE_CONSOLE.md](../docs/FIRMWARE_CONSOLE.md)
- The LAN and Bluetooth API: [docs/DEVICE_PROTOCOL.md](../docs/DEVICE_PROTOCOL.md)
- Flashing a release on a new board: [docs/GETTING_STARTED.md](../docs/GETTING_STARTED.md)

```
main/            boot, the state machine, the turn worker, the console
components/      board, mimi_config, mimi_net, mimi_prov, mimi_api, mimi_settings,
                 mimi_audio, mimi_wakeword, mimi_camera, mimi_cloud, mimi_ui
assets/          the runtime filesystem: earcons and the system prompt
assets_src/      build-time sources: fonts, images and the scripts that convert them
partitions.csv   16 MB layout
sdkconfig.defaults   every configuration choice, with the reason next to it
version.txt      the firmware version
```

Pins are defined only in `components/board/include/board_pins.h`.
