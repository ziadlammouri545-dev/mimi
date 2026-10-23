// Boot order matters here. The board must own the I2C bus before the screen
// touches it, the screen goes up before the slow things so the logo shows
// early, audio starts its clocks before the amp is enabled, and the state
// machine is last because it starts Wi-Fi and every callback lands in it.
#include <inttypes.h>
#include <stdio.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_app_desc.h"
#include "esp_chip_info.h"
#include "esp_flash.h"
#include "esp_heap_caps.h"
#include "esp_log.h"
#include "esp_psram.h"
#include "esp_system.h"
#include "esp_timer.h"
#include "esp_wifi.h"

#include "board.h"
#include "mimi_config.h"
#include "mimi_net.h"
#include "mimi_audio.h"
#include "mimi_wakeword.h"
#include "mimi_camera.h"
#include "mimi_cloud.h"
#include "mimi_ui.h"
#include "mimi_console.h"
#include "mimi_sm.h"
#include "mimi_turn.h"
#include "mimi_prov.h"
#include "mimi_api.h"
#include "mimi_settings.h"

static const char *TAG = "mimi";

#define DEFAULT_VOLUME 70
#define SETUP_MODE_MS  (10 * 60 * 1000)
#define BOOT_SETUP_MS  30000

static void report_chip(void)
{
    esp_chip_info_t chip;
    esp_chip_info(&chip);
    uint32_t flash = 0;
    esp_flash_get_size(NULL, &flash);
    ESP_LOGI(TAG, "Mimi %s by MultiX0, https://github.com/MultiX0, PolyForm Noncommercial 1.0.0",
             esp_app_get_description()->version);
    // Why the last run ended. A brownout or a power-on reset in the middle of
    // speech is the supply giving way under the speaker, not a crash.
    static const char *const why[] = {
        [ESP_RST_UNKNOWN] = "unknown", [ESP_RST_POWERON] = "power on",
        [ESP_RST_EXT] = "reset pin", [ESP_RST_SW] = "software restart",
        [ESP_RST_PANIC] = "panic", [ESP_RST_INT_WDT] = "interrupt watchdog",
        [ESP_RST_TASK_WDT] = "task watchdog", [ESP_RST_WDT] = "watchdog",
        [ESP_RST_DEEPSLEEP] = "deep sleep", [ESP_RST_BROWNOUT] = "brownout",
        [ESP_RST_SDIO] = "sdio", [ESP_RST_USB] = "usb", [ESP_RST_JTAG] = "jtag",
    };
    const esp_reset_reason_t r = esp_reset_reason();
    ESP_LOGW(TAG, "reset reason: %s (%d)",
             (unsigned) r < sizeof(why) / sizeof(why[0]) && why[r] ? why[r] : "other", (int) r);
    ESP_LOGI(TAG, "esp32-s3 rev %d.%d, flash %" PRIu32 " MB, psram %u MB, heap int %u",
             chip.revision / 100, chip.revision % 100, flash / (1024 * 1024),
             (unsigned) (esp_psram_get_size() / (1024 * 1024)),
             (unsigned) heap_caps_get_free_size(MALLOC_CAP_INTERNAL));
}

// A subsystem that fails to start is logged and skipped. The board keeps
// booting so the screen can say what is wrong instead of sitting dark.
static void try_init(const char *what, esp_err_t (*fn)(void))
{
    esp_err_t err = fn();
    if (err != ESP_OK) {
        ESP_LOGE(TAG, "%s failed: %s", what, esp_err_to_name(err));
    }
    ESP_LOGI(TAG, "after %-8s heap int %u, largest dma %u", what,
             (unsigned) heap_caps_get_free_size(MALLOC_CAP_INTERNAL),
             (unsigned) heap_caps_get_largest_free_block(MALLOC_CAP_DMA));
}

static void apply_settings(void)
{
    int32_t volume = DEFAULT_VOLUME;
    if (mimi_config_get_i32(MIMI_CFG_VOLUME, &volume) != ESP_OK) {
        volume = DEFAULT_VOLUME;
    }
    mimi_audio_set_volume((uint8_t) volume);
    mimi_wakeword_set_debug_clips(mimi_config_get_bool(MIMI_CFG_DEBUG_CLIPS, false));
    ESP_LOGI(TAG, "volume %" PRId32 ", wake phrase \"%s\", debug clips %s",
             volume, mimi_wakeword_phrase(),
             mimi_wakeword_debug_clips() ? "on" : "off");
}

// Runs on the event loop task; the ui_ calls take the LVGL lock themselves.
static void on_setup(mimi_prov_state_t st, const char *detail, void *ctx)
{
    (void) ctx;
    switch (st) {
    case MIMI_PROV_WAITING:    ui_set_setup_status(UI_SETUP_WAITING, NULL);      break;
    case MIMI_PROV_CONNECTING: ui_set_setup_status(UI_SETUP_CONNECTING, detail); break;
    case MIMI_PROV_FAILED:     ui_set_setup_status(UI_SETUP_FAILED, detail);     break;
    case MIMI_PROV_DONE:       ui_set_setup_status(UI_SETUP_DONE, detail);       break;
    default: break;
    }
}

// Setup mode is a boot mode, see mimi_prov.h. The camera, wake word and
// cloud are not started until it ends, so NimBLE has the whole heap.
static void run_setup_mode(void)
{
    if (mimi_prov_start(on_setup, NULL) == ESP_OK) {
        ui_show_setup(mimi_prov_device_name(), mimi_prov_code());
        esp_err_t err = mimi_prov_wait(SETUP_MODE_MS);
        mimi_prov_stop();
        ESP_LOGI(TAG, "setup mode over: %s", esp_err_to_name(err));
    }
    ui_hide_setup();
    // Adopts the connection the phone made, or retries the saved network.
    try_init("wifi", mimi_net_start);
}

// The menu's Wi-Fi setup button. Called on the LVGL task, so the NVS write
// and the restart happen on a timer instead.
static void on_wifi_setup(void *ctx)
{
    (void) ctx;
    mimi_prov_request_async("menu");
}

// Which apps are here right now: the lights on the idle screen, and the
// phone's brain for the next turn. A PC that just linked is checked at once,
// so it answers the next turn without waiting for the 40 s heartbeat.
static void on_links(const mimi_api_links_t *links)
{
    static bool pc_before;
    ui_set_links(links->pc, links->phone);
    mimi_cloud_set_phone_brain(links->phone_brain, links->phone_token);
    if (links->pc && !pc_before) {
        mimi_cloud_prewarm();
        sm_post(EV_PC_INFO, 0);
    }
    pc_before = links->pc;
}

// The app's Talk screen, "ask about this", say and stop. Only from idle,
// except stop; the answer tells the app when the board is busy.
static bool on_app_request(mimi_api_request_t what, const char *text)
{
    if (what == MIMI_API_STOP) {
        sm_post(EV_CANCEL, 0);
        return true;
    }
    if (sm_state() != OS_IDLE) {
        return false;
    }
    switch (what) {
    case MIMI_API_SAY:
        turn_set_pending_text(text);
        sm_post(EV_SAY, 0);
        break;
    case MIMI_API_SNAPSHOT:
        mimi_cloud_look_next();
        turn_set_pending_text(text ? text : "What is in front of you?");
        sm_post(EV_ASK, 0);
        break;
    default:
        if (text) {
            turn_set_pending_text(text);
            sm_post(EV_ASK, 0);
        } else {
            sm_post(EV_BUTTON, 0);
        }
        break;
    }
    return true;
}

static void on_reply_progress(void)
{
    sm_post(EV_PROGRESS, 0);
}

// A setting stored from an app: the wake word switch takes effect at once.
static void on_settings_changed(void)
{
    sm_post(EV_SETTINGS, 0);
}

static void on_pair_code(const char *code, int seconds)
{
    ui_show_pair_code(code, seconds);
}

// Every key, the Wi-Fi the driver keeps too, then a restart with nothing:
// setup mode, as on the first boot. On a timer, not the LVGL task.
static void factory_reset(void *arg)
{
    (void) arg;
    ESP_LOGW(TAG, "factory reset from the menu");
    mimi_config_erase_all();
    esp_wifi_restore();
    esp_restart();
}

static void on_reset(void *ctx)
{
    (void) ctx;
    static esp_timer_handle_t t;
    const esp_timer_create_args_t a = { .callback = factory_reset, .name = "factory_reset" };
    if (t || esp_timer_create(&a, &t) == ESP_OK) {
        esp_timer_start_once(t, 300000);
    }
}

void app_main(void)
{
    report_chip();

    ESP_ERROR_CHECK(board_init());
    try_init("config", mimi_config_init);
    mimi_config_report();
    if (!mimi_config_is_provisioned()) {
        ESP_LOGW(TAG, "not provisioned, run tools/cloud/provision.py");
    }

    // Wi-Fi first. Its receive buffers need DMA capable internal RAM, and once
    // the screen, camera and wake word are up there is none left:
    // esp_wifi_init fails with ESP_ERR_NO_MEM.
    try_init("wifi", mimi_net_start);

    try_init("ui", ui_init);
    ui_set_state(OS_BOOT);

    // The console comes up before setup mode so `prov stop` works there.
    try_init("console", console_start);
    if (mimi_prov_should_run()) {
        run_setup_mode();
    } else {
        mimi_prov_release_bt();
    }
    // A saved network that never answers means the board moved: setup mode.
    if (mimi_config_has(MIMI_CFG_WIFI_SSID) && !mimi_net_is_up()) {
        mimi_prov_watch(BOOT_SETUP_MS);
    }

    try_init("audio", mimi_audio_init);
    try_init("wakeword", mimi_wakeword_init);
    try_init("camera", mimi_camera_init);
    try_init("cloud", mimi_cloud_init);
    apply_settings();

    ESP_ERROR_CHECK(sm_start());
    ui_on_wifi_setup(on_wifi_setup, NULL);
    ui_on_reset(on_reset, NULL);
    mimi_api_on_links(on_links);
    mimi_api_on_pair_code(on_pair_code);
    mimi_api_on_request(on_app_request);
    mimi_settings_on_change(on_settings_changed);
    mimi_cloud_on_progress(on_reply_progress);
    try_init("api", mimi_api_start);

    while (true) {
        vTaskDelay(pdMS_TO_TICKS(60000));
        ESP_LOGI(TAG, "state %s, turns %" PRIu32 ", heap int %u, psram %u",
                 mimi_state_name(sm_state()), sm_turn_count(),
                 (unsigned) heap_caps_get_free_size(MALLOC_CAP_INTERNAL),
                 (unsigned) heap_caps_get_free_size(MALLOC_CAP_SPIRAM));
    }
}
