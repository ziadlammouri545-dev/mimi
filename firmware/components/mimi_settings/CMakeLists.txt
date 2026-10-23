idf_component_register(
    SRCS "mimi_settings.c" "settings_store.c" "settings_json.c"
    INCLUDE_DIRS "include"
    PRIV_REQUIRES esp_event esp_timer json log heap mimi_config mimi_cloud mimi_audio
)
