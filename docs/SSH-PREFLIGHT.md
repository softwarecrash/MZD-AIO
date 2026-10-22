# Historical preflight (superseded by vehicle tests)

See [VEHICLE-TESTS.md](VEHICLE-TESTS.md) for the later successful installation, password authentication and reboot test. The preflight findings below describe the earlier state.

# SSH device preflight — 2026-10-22

Target: 74.00.324A EU, temporary owner SSH on port 2222. Only `ssh-bringback` selected on the USB at `/mnt/sdb1`.

The first device preflight failed before any installation: the actual BusyBox 1.19.2 grep has no `-x` option. Whole-line literal checks now use awk; regular-expression selections use anchored `grep -E` expressions. The same fix covers the common state/backup manager and SSH log marker.

A corrected package copy on the USB passed the real installer preflight with exit code 0, including firmware/original-file checks, the native `sshd -t` configuration check, account layout, free port 22 and firewall inspection. Native sshd warns that `UsePAM` is unsupported but accepts the configuration with exit code 0. No daemon was started and no password login was attempted.

The six corrected scripts were then copied to the USB package and compared byte-for-byte. Previous versions and preflight reports remain on that USB under `reports/ssh-preflight-19700101-001009-23148/`. The original action and selection remain `install` and `ssh-bringback`. The OEM `/jci/scripts/stage_wifi.sh` still has its original MD5 `d740449dea568696660a62fce0fb35bd`; port 22 remains inactive.

## WLAN absence

The service binds IPv4 wildcard `0.0.0.0`, without a WLAN device or address prerequisite. Its boot hook launches a background supervisor and does not wait for a network connection. The status command treats missing address output as informational.

An isolated test runs the actual supervisor script with mocked sshd, process/account/mount/firewall tools and target-style grep restrictions. It starts with WLAN absent and checks absent, disabled, disconnected, connected and absent-again states without daemon restart. Existing port rejection, OEM port coexistence, duplicate start, cleanup and firewall recovery also pass.

This proves script behavior in those fixtures, not a hardware test with WLAN disabled. Actual installation, password authentication, WLAN-off device boot, reconnect after WLAN enablement and uninstall on hardware remain unverified. No patch is marked vehicle-tested by this preflight.
