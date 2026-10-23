idf_component_register(
    SRCS "mimi_prov.c" "prov_pair.c" "prov_cmds.c" "prov_config.c"
    INCLUDE_DIRS "include"
    REQUIRES esp_event
    PRIV_REQUIRES wifi_provisioning protocomm bt esp_wifi esp_netif esp_timer json console
                  mimi_config mimi_net mimi_settings
)
