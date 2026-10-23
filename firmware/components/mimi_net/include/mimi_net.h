// Wi-Fi station with reconnect and backoff.
#pragma once

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>
#include "esp_err.h"

typedef enum {
    MIMI_NET_DOWN,
    MIMI_NET_UP,
} mimi_net_state_t;

typedef void (*mimi_net_cb_t)(mimi_net_state_t state, void *ctx);

esp_err_t mimi_net_start(void);
esp_err_t mimi_net_stop(void);

// Brings up netif, the event loop and the Wi-Fi driver without connecting.
// Idempotent; mimi_net_start calls it. mimi_prov calls it before Bluetooth
// setup so the station exists to scan and to join with.
esp_err_t mimi_net_init_driver(void);

// While paused mimi_net neither connects nor retries: the provisioning
// manager owns the station and reports its failures to the phone.
void mimi_net_set_paused(bool paused);

// Re-reads the saved credentials and joins that network. For /api/provision.
esp_err_t mimi_net_reconnect(void);

// Blocks until an IP arrives or the timeout expires. For boot only; the state
// machine uses the callback.
esp_err_t mimi_net_wait_up(uint32_t timeout_ms);

bool mimi_net_is_up(void);
int mimi_net_rssi(void);
uint32_t mimi_net_disconnect_count(void);
esp_err_t mimi_net_ip(char *out, size_t out_len);

esp_err_t mimi_net_register_cb(mimi_net_cb_t cb, void *ctx);
