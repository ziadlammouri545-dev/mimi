// What the rest of the firmware asks mimi_net: up or down, the address, the
// signal, and who wants to hear about changes. The driver side lives in
// mimi_net.c and reports in through net_priv.h.
#include "mimi_net.h"
#include "net_priv.h"

#include <string.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "esp_wifi.h"

static const char *TAG = "mimi_net";

#define MAX_CALLBACKS 4

typedef struct {
    mimi_net_cb_t fn;
    void *ctx;
} listener_t;

static listener_t s_listeners[MAX_CALLBACKS];
static bool s_up;
static bool s_ever_up;
static char s_ip[16] = "0.0.0.0";
static uint32_t s_disconnects;

static void notify(mimi_net_state_t state)
{
    for (int i = 0; i < MAX_CALLBACKS; i++) {
        if (s_listeners[i].fn) {
            s_listeners[i].fn(state, s_listeners[i].ctx);
        }
    }
}

void net_mark_up(const char *ip)
{
    strlcpy(s_ip, ip, sizeof(s_ip));
    s_up = true;
    s_ever_up = true;
    ESP_LOGI(TAG, "up, ip %s, rssi %d", s_ip, mimi_net_rssi());
    notify(MIMI_NET_UP);
}

void net_mark_down(void)
{
    if (!s_up) {
        return;
    }
    s_up = false;
    strlcpy(s_ip, "0.0.0.0", sizeof(s_ip));
    notify(MIMI_NET_DOWN);
}

bool net_ever_up(void)
{
    return s_ever_up;
}

uint32_t net_count_disconnect(void)
{
    return ++s_disconnects;
}

esp_err_t mimi_net_wait_up(uint32_t timeout_ms)
{
    const uint32_t step = 100;
    uint32_t waited = 0;
    while (!s_up && waited < timeout_ms) {
        vTaskDelay(pdMS_TO_TICKS(step));
        waited += step;
    }
    return s_up ? ESP_OK : ESP_ERR_TIMEOUT;
}

bool mimi_net_is_up(void)
{
    return s_up;
}

int mimi_net_rssi(void)
{
    wifi_ap_record_t ap;
    if (!s_up || esp_wifi_sta_get_ap_info(&ap) != ESP_OK) {
        return 0;
    }
    return ap.rssi;
}

uint32_t mimi_net_disconnect_count(void)
{
    return s_disconnects;
}

esp_err_t mimi_net_ip(char *out, size_t out_len)
{
    if (!out || out_len == 0) {
        return ESP_ERR_INVALID_ARG;
    }
    strlcpy(out, s_ip, out_len);
    return s_up ? ESP_OK : ESP_ERR_INVALID_STATE;
}

esp_err_t mimi_net_register_cb(mimi_net_cb_t cb, void *ctx)
{
    for (int i = 0; i < MAX_CALLBACKS; i++) {
        if (!s_listeners[i].fn) {
            s_listeners[i].fn = cb;
            s_listeners[i].ctx = ctx;
            return ESP_OK;
        }
    }
    return ESP_ERR_NO_MEM;
}
