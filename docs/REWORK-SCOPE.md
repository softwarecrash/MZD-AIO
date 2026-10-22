# Rework scope: 74.00.324A EU

The web catalog contains 38 tweaks. Five have owner-confirmed vehicle tests on 74.00.324A EU and remain available; 33 remain locked.

The following legacy tweaks are retired and are not porting tasks:

| ID | Reason | Original installer evidence |
|---|---|---|
| legacy-usb-audio | Old USB Audio Mod is explicitly incompatible with 59.00.502 and later. | `26_usbaudiomod-i.txt`: `COMPAT_GROUP -lt 5`; rejection message names 59.00.502+. |
| legacy-flac-order | Version-specific legacy FLAC/library patch only for older firmware. Do not port the old replacement library. | `08_orderflac-i.txt`: `COMPAT_GROUP -lt 5` and explicit old firmware whitelist. |
| pause-on-mute | Original installer reports the feature as included since 59.00.502+. No additional patch planned. | `10_pausemute-i.txt`: rejects `COMPAT_GROUP -gt 5`; inclusion message names 59.00.502+. |

These entries are removed from the active feature matrix. Historical source files and comparison evidence are retained for traceability, not as outstanding work. Temporary lack of compatibility verification alone does not retire another tweak; existing targeted ports remain in scope.
