# 🛠️ GoldenGate-USB-Creator
### Automated macOS 27 Golden Gate USB Installer Creator with UserFS EFI Deployment

[![macOS Golden Gate](https://img.shields.io/badge/macOS-27_Golden_Gate-orange.svg?style=for-the-badge&logo=apple)](https://apple.com)
[![Diskarbitration UserFS](https://img.shields.io/badge/Filesystem-UserFS_Diskarbitration-brightgreen.svg?style=for-the-badge&logo=apple)](https://apple.com)
[![OpenCore](https://img.shields.io/badge/OpenCore-1.0.8-blue.svg?style=for-the-badge&logo=apple)](https://github.com/acidanthera/OpenCorePkg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

**Author:** [Om Soni (omsoni-codes)](https://github.com/omsoni-codes)  

---

## 🌟 Overview

**GoldenGate-USB-Creator** is an automated turnkey utility designed to create bootable **macOS 27 Golden Gate** USB installation media. It resolves the notorious `kmutil` `msdosfs.kext` signature revocation on modern Apple Silicon Macs running macOS 27 / Sequoia by using native Diskarbitration UserFS calls.

---

## 🚀 Key Innovations

1. **UserFS EFI Mount Bypass**: Avoids the `mount_msdos` kernel panic / error 71 by formatting and mounting the EFI partition directly into user-space.
2. **Integrated BootBridge**: Automatically embeds the `GoldenGate-BootBridge` x86_64 boot structures onto the target installer partition.
3. **Automated VMD Switching Scripts**: Installs `startup.nsh`, `vmd_off.nsh`, `setup_var.efi`, and `RU.efi` directly into the EFI root for instant Intel VMD bypass.

---

## 📦 Usage

```bash
git clone https://github.com/omsoni-codes/GoldenGate-USB-Creator.git
cd GoldenGate-USB-Creator
chmod +x create_goldengate_usb.sh
./create_goldengate_usb.sh disk4
```

---

## ⚖️ License

Released under the **MIT License**. Copyright (c) 2026 **Om Soni (omsoni-codes)**. All rights reserved.
