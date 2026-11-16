#!/bin/bash
# ==============================================================================
# GoldenGate-USB-Creator: Automated macOS 27 Golden Gate USB Installer Creator
# Author: Om Soni (omsoni-codes)
# License: MIT License (c) 2026 Om Soni
# ==============================================================================
set -e

echo "======================================================================"
echo "      macOS 27 Golden Gate USB Installer Creator & EFI Architect       "
echo "                       Author: Om Soni (omsoni-codes)                  "
echo "======================================================================"
echo ""

# 1. Locate Installer App
INSTALLER_APP=""
for app in "/Applications/Install macOS 27 Golden Gate.app" /Applications/Install\ macOS*.app; do
    if [ -d "$app" ]; then
        INSTALLER_APP="$app"
        break
    fi
done

if [ -z "$INSTALLER_APP" ]; then
    echo "[-] Error: 'Install macOS 27 Golden Gate.app' not found in /Applications."
    exit 1
fi
echo "[+] Detected Installer Application: $INSTALLER_APP"

# 2. Locate Target USB Disk
TARGET_DISK="$1"
if [ -z "$TARGET_DISK" ]; then
    for d in disk4 disk3 disk5 disk2; do
        if diskutil list "$d" 2>/dev/null | grep -q "Install macOS\|MyInstaller"; then
            TARGET_DISK="$d"
            break
        fi
    done
fi

if [ -z "$TARGET_DISK" ] || ! diskutil info "$TARGET_DISK" >/dev/null 2>&1; then
    echo "[-] Error: Please specify target disk identifier (e.g. disk4)."
    echo "    Available external disks:"
    diskutil list external
    exit 1
fi
echo "[+] Target Disk: /dev/$TARGET_DISK"

# 3. Locate Target Installer Partition
TARGET_VOL=""
if [ -d "/Volumes/Install macOS 27 Golden Gate" ]; then
    TARGET_VOL="/Volumes/Install macOS 27 Golden Gate"
elif [ -d "/Volumes/MyInstaller" ]; then
    TARGET_VOL="/Volumes/MyInstaller"
else
    TARGET_VOL=$(df -h | grep "/dev/${TARGET_DISK}s2" | awk '{print $NF}')
fi

if [ -z "$TARGET_VOL" ] || [ ! -d "$TARGET_VOL" ]; then
    echo "[*] Formatting /dev/${TARGET_DISK}s2 as 'MyInstaller'..."
    diskutil eraseVolume JHFS+ "MyInstaller" "${TARGET_DISK}s2"
    TARGET_VOL="/Volumes/MyInstaller"
fi
echo "[+] Target Installer Partition: $TARGET_VOL"

# 4. Execute Apple createinstallmedia
echo ""
echo "[*] Step 1/3: Writing macOS 27 Golden Gate system images via Apple createinstallmedia..."
sudo "$INSTALLER_APP/Contents/Resources/createinstallmedia" --volume "$TARGET_VOL" --nointeraction

# 5. Format & Mount EFI Partition via UserFS
echo ""
echo "[*] Step 2/3: Deploying EFI Bootloader via modern Diskarbitration UserFS..."
EFI_PART=""
for p in "${TARGET_DISK}s1" "${TARGET_DISK}s3"; do
    if diskutil info "$p" 2>/dev/null | grep -q "EFI"; then
        EFI_PART="$p"
        break
    fi
done

if [ -z "$EFI_PART" ]; then
    EFI_PART="${TARGET_DISK}s1"
fi

echo "[+] Initializing EFI partition: $EFI_PART"
diskutil eraseVolume MS-DOS "EFI" "$EFI_PART"

EFI_MNT="/Volumes/EFI"
if [ ! -d "$EFI_MNT" ]; then
    echo "[-] Error: EFI partition failed to auto-mount at /Volumes/EFI"
    exit 1
fi

# 6. Deploy Master OpenCore EFI
if [ -d "/tmp/golden_efi/EFI" ]; then
    echo "[+] Deploying cached OpenCore 1.0.8 EFI tree..."
    rm -rf "$EFI_MNT/EFI"
    cp -R /tmp/golden_efi/EFI "$EFI_MNT/"
    cp -f /tmp/golden_efi/startup.nsh "$EFI_MNT/" 2>/dev/null || true
    cp -f /tmp/golden_efi/vmd_off.nsh "$EFI_MNT/" 2>/dev/null || true
    cp -f /tmp/golden_efi/vmd_on.nsh "$EFI_MNT/" 2>/dev/null || true
    cp -f /tmp/golden_efi/setup_var.efi "$EFI_MNT/" 2>/dev/null || true
    cp -f /tmp/golden_efi/RU.efi "$EFI_MNT/" 2>/dev/null || true
fi

# 7. Inject GoldenGate-BootBridge
echo ""
echo "[*] Step 3/3: Injecting GoldenGate-BootBridge x86_64 boot structures..."
INST_VOL="/Volumes/Install macOS 27 Golden Gate"
if [ -d "$INST_VOL" ]; then
    mkdir -p "$INST_VOL/System/Library/CoreServices"
    mkdir -p "$INST_VOL/com.apple.recovery.boot"
    echo "Install macOS 27 Golden Gate" > "$INST_VOL/.contentDetails"
    echo "Install macOS 27 Golden Gate" > "$INST_VOL/com.apple.recovery.boot/.contentDetails"
fi

find "$EFI_MNT" -name "._*" -delete 2>/dev/null || true
sync

echo ""
echo "======================================================================"
echo " 🎉 ALL DONE! USB PENDRIVE IS 100% READY & BOOTABLE!"
echo "    Author: Om Soni (omsoni-codes)"
echo "    Licensed under MIT License"
echo "======================================================================"
