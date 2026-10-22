# Vehicle tests - 2026-10-22

Target: Mazda CMU 74.00.324A EU. The owner explicitly confirmed the following five patch functions. This is evidence on this vehicle/firmware, not every variant or combination.

| Patch | Evidence |
|---|---|
| SSH access | Real password-only login as cmu on port 22 verified. Automatic startup after full reboot and operation without USB verified. Owner confirmed success. |
| Main menu loop | Installed alone, expected checksum verified, full SSH reboot. Owner confirmed circular navigation. Later uninstalled at owner request; OEM checksum verified. |
| List beep | Installed with the other two list patches; combined checksum verified, full SSH reboot. Owner confirmed scrolling sound absent. |
| Shorter list delay | Same three-patch test. Owner confirmed the three patches as tested. No timing measurements; this changes list autoscroll parameters, not horizontal main-menu code. |
| List loop | Same three-patch test. Owner explicitly confirmed wraparound works. |

## Included SSH correction

Native OpenSSH requires an absolute executable path. The service resolves `SSHD=$(command -v sshd)`, verifies an absolute path, and uses `"$SSHD"` for validation and startup. The successful device test used this corrected script. The target BusyBox grep compatibility fix is also included.

## Recovery observations

- UI hashes matched reviewed AIO ports. Internal and USB original backups matched OEM hashes.
- Regular uninstall of all four UI patches restored OEM files byte-for-byte and preserved SSH.
- Full `reboot` over SSH restored the display and retained WLAN with reconnection to its saved network.
- Opera-only service restart left a black display, also with restored OEM UI files. Do not use it as a verified interface reload method.
- An install completed its file writes but final USB read-only remount failed with `Device or resource busy`. This remains an open cleanup issue. Preserve the nonzero top-level status; do not force the remount.

## Limits

Not every combination or Full System Restore has a hardware test. Actual WLAN-absent/disabled SSH boot and other firmware/vehicle variants remain unverified. WLAN absence, port conflicts, cleanup and firewall recovery have isolated script tests. Green cards describe confirmed patch functions, not universal recovery guarantees.
