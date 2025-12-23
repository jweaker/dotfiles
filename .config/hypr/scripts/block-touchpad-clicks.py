#!/usr/bin/env python3
from evdev import InputDevice, categorize, ecodes, UInput

device = InputDevice('/dev/input/event8')
# Don't grab the device - let other processes use it
# device.grab()  # Commented out

ui = UInput.from_device(device, name='filtered-touchpad')

for event in device.read_loop():
    # Block physical button clicks
    if event.type == ecodes.EV_KEY and event.code in [ecodes.BTN_LEFT, ecodes.BTN_RIGHT, ecodes.BTN_MIDDLE]:
        continue
    
    ui.write_event(event)
    ui.syn()
```

Actually, this approach is getting complicated. Let me suggest a **simpler solution** - just physically disable the buttons in Hyprland's config.

Add this to `~/.config/hypr/hyprland.conf`:
```
input {
    touchpad {
        tap-to-click = true
        disable_while_typing = true
    }
}
