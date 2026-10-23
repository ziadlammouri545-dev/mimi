idf_component_register(
    SRCS "main.c" "mimi_sm.c" "mimi_turn.c" "mimi_console.c"
    INCLUDE_DIRS "."
    REQUIRES board mimi_config mimi_net mimi_audio mimi_wakeword mimi_cloud mimi_settings
             mimi_camera mimi_ui mimi_prov mimi_api console esp_timer spiffs esp_psram
             spi_flash nvs_flash esp_wifi esp_app_format
)

# Packs firmware/assets into the 2 MB "assets" partition and flashes it with the
# app. Without this the partition is never written, esp_vfs_spiffs_register
# fails on the board, and the earcons and system prompt silently never arrive.
spiffs_create_partition_image(assets ../assets FLASH_IN_PROJECT)
