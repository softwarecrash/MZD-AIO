MAZDA 74.00.324A EU -- MP3 / TERMINAL / SSH TEST

STATUS: Prepared and locally checked. Not yet vehicle-tested.

IMPORTANT LIMIT
After a fresh MCU reboot, USB files alone currently open only the original
diagnostic menu. The OEM console launcher does not accept a USB command.
This package does NOT claim that cold-start USB -> SSH already works.

The included optional RAM hook makes this controlled test possible:
MP3 title -> JavaScript -> diagnostic test 11 -> terminal -> SSH, without
typing at that point. It requires ONE initial command from a root console
or an existing SSH connection. A reboot removes the hook.

COPY
Copy the CONTENTS of ZUM_USB_KOPIEREN into the USB drive root. Allow replacing
js/run.js. Original files are backed up separately on the notebook.
The MP3 files and their title payloads are unchanged.
Only the public key is included; the private key stays on the notebook.

TEST AFTER THE CURRENT REBOOT
1. Select USB audio and play mp3/a.mp3 (try b, c or d for another mount point).
2. The new green-bordered test display requests diagnostic test 11 by itself
   after about 15 seconds. Without the RAM hook, only the OEM menu appears.
3. To prepare the full controlled test ONCE, open TERMINAL in the OEM menu
   and run (adjust sda1 to the actual USB mount if necessary):

   sh /mnt/sda1/keyboardless/install-ram-hook.sh

   This step needs a keyboard or another already-working command channel.
   The prepared package cannot type this command by itself.
4. Return to USB audio, select another track and then a trigger MP3 again.
   If necessary, use the new overlay's 'Erneut starten' button.
5. With the RAM hook present, test 11 now starts the terminal directly.
   The terminal executes terminal-entry.sh, which starts key-only SSH on
   port 2223 and then leaves a regular shell open.
6. On the notebook use VERBINDEN-TEST.cmd (outside the USB copy folder).
   The command there still uses the private key already on the notebook.
7. After connecting, inspect:

   cat /tmp/mzd-keyboardless-test/result.txt
   cat /tmp/mzd-keyboardless-test/run-id.txt
   cat /tmp/mzd-keyboardless-test/ssh-start.log

Success means a NEW SSH login on port 2223 plus result 'ssh_started'.
An open terminal or a successful connection to old port 2222 is not proof.

CHANGES MADE BY THE OPTIONAL SETUP
Temporary files under /tmp and a bind mount over
/jci/scripts/startSystemScripts.sh. No root filesystem remount for writing;
no OEM file replacement on flash; no password change; no permanent autorun.
The SSH script adds one firewall rule for the detected IPv4 and port 2223.
It uses the same existing UID-0 login and public key as the previous test.

UNDO
sh /tmp/mzd-keyboardless-test/uninstall-ram-hook.sh
or reboot the MCU. Logs and host keys under /tmp disappear on reboot.

WHAT THIS TEST DOES NOT YET PROVE
Keyboard-free SSH directly from an untouched cold-start MCU. That still
requires finding a working command-execution path beyond the MP3 GUI entry.

SOURCES
Original USB files were read from your own USB stick before disconnection.
OEM scripts and terminal binary were read from your 74.00.324A EU unit.
Related original MP3 GUI technique:
https://github.com/naijamesz/mazda-connect-root-refactor
