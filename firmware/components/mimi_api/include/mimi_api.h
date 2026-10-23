// LAN API for the phone app: mDNS _mimi._tcp, a UDP beacon on 7332, REST on
// port 80 behind X-Mimi-Token, /ws state events, /capture and /stream.
// The contract is docs/DEVICE_PROTOCOL.md, which comes from the app project
// and is not edited here.
#pragma once

#include <stdbool.h>

#include "esp_err.h"
#include "mimi_state.h"

// Registers with mimi_net and serves whenever the station is up. The HTTP
// server task lives on a PSRAM stack; nothing it runs writes flash directly.
esp_err_t mimi_api_start(void);
esp_err_t mimi_api_stop(void);

// Called by the state machine on every transition. Pushed to every open /ws
// client as state, turn.start, tts.start, tts.end and turn.end events.
void mimi_api_publish_state(mimi_state_t state);
// role "user" is the transcript, "assistant" the reply.
void mimi_api_publish_text(const char *role, const char *text);

// What the app asks the board to do (POST /api/talk, /api/talk/snapshot,
// /api/say, /api/stop). text is NULL for a plain talk. Called on the HTTP
// task; main posts to the state machine and says whether it took it: false
// means the board is busy with a turn.
typedef enum {
    MIMI_API_TALK = 0,
    MIMI_API_SNAPSHOT,
    MIMI_API_SAY,
    MIMI_API_STOP,
} mimi_api_request_t;
typedef bool (*mimi_api_request_cb_t)(mimi_api_request_t what, const char *text);
void mimi_api_on_request(mimi_api_request_cb_t cb);

// A pairing code for the screen (POST /api/pair), shown for seconds, or NULL
// to take it down. Called on the HTTP server task.
typedef void (*mimi_api_pair_cb_t)(const char *code, int seconds);
void mimi_api_on_pair_code(mimi_api_pair_cb_t cb);

// The apps holding a live /ws link right now. A link is dropped the moment its
// socket closes, or 15 s after its last frame (the apps ping every 5 s).
// phone_brain is the phone's own brain, "192.168.1.23:7331", with the token it
// paired with; empty when no phone offers one. Called on every change.
typedef struct {
    bool pc;
    bool phone;
    char phone_brain[48];
    char phone_token[65];
} mimi_api_links_t;
typedef void (*mimi_api_links_cb_t)(const mimi_api_links_t *links);
void mimi_api_on_links(mimi_api_links_cb_t cb);
