// The one state enum the whole firmware shares. main/ drives it, mimi_ui
// draws it, mimi_api publishes it.
#pragma once

typedef enum {
    OS_BOOT = 0,
    OS_IDLE,
    OS_WAKE,
    OS_LISTENING,
    OS_THINKING,
    OS_SPEAKING,
    OS_ERROR,
    OS_OFFLINE,
    OS_STATE_COUNT,
} mimi_state_t;

// Lowercase, stable, safe to log and to put on the wire.
const char *mimi_state_name(mimi_state_t state);
