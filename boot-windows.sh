#!/usr/bin/env bash
#
# boot-windows.sh — reboot straight into Windows, one time.
#
# How it works:
#   Instead of touching Limine's config, this uses the UEFI firmware's
#   built-in one-shot "BootNext" setting. That tells the firmware:
#   "for the NEXT boot only, start Windows." After Windows loads, the
#   machine goes back to booting Limine (Linux) as normal.
#
#   Nothing permanent is changed, so you can't accidentally lock yourself
#   out of Linux. Run this script again any time you want Windows.
#
set -euo pipefail

# --- re-run ourselves as root if needed (BootNext + reboot require it) ---
if [ "$(id -u)" -ne 0 ]; then
    exec sudo bash "$(realpath "$0")" "$@"
fi

# --- sanity checks -----------------------------------------------------------
if [ ! -d /sys/firmware/efi ]; then
    echo "This isn't a UEFI system, so BootNext isn't available." >&2
    exit 1
fi

if ! command -v efibootmgr >/dev/null 2>&1; then
    echo "efibootmgr is not installed. Install it with:" >&2
    echo "    sudo pacman -S efibootmgr" >&2
    exit 1
fi

# --- find the Windows Boot Manager entry -------------------------------------
win_entry=$(efibootmgr \
    | grep -i 'Windows Boot Manager' \
    | head -n1 \
    | sed -E 's/^Boot([0-9A-Fa-f]{4}).*/\1/' \
    || true)

if [ -z "${win_entry:-}" ]; then
    echo "Couldn't find a 'Windows Boot Manager' UEFI entry." >&2
    echo "Here's what your firmware knows about — check for Windows:" >&2
    echo >&2
    efibootmgr >&2
    exit 1
fi

echo "Found Windows Boot Manager: Boot${win_entry}"

# --- queue Windows for the next boot only ------------------------------------
efibootmgr --bootnext "$win_entry" >/dev/null
echo "Next boot is set to Windows (this one time only)."

# --- reboot, with a chance to bail out ---------------------------------------
echo
echo "Rebooting into Windows in 5 seconds...  press Ctrl-C to cancel."
sleep 5
systemctl reboot
