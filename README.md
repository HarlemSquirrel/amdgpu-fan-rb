# amdgpu-fan-rb

A Ruby CLI to read and set the fan speed for AMD Radeon graphics cards running on the AMDGPU Linux driver.

See https://wiki.archlinux.org/index.php/Fan_speed_control#AMDGPU_sysfs_fan_control

## Usage

```
➤  bin/amdgpu_fan
Commands:
  amdgpu_fan auto            # set mode to automatic (requires sudo)
  amdgpu_fan help [COMMAND]  # Describe available commands or one specific command
  amdgpu_fan set PERCENTAGE  # set fan speed to PERCENTAGE (requires sudo)
  amdgpu_fan status          # report the current status

➤  bin/amdgpu_fan status
AMD Radeon (TM) R9 Fury Series
Video BIOS version: 113-C8800100-102
🌀	Fan:   auto mode running at 27% ~ 1832 rpm
🌡	Temp:  32.0°C
⚡	Power: 49.24 / 300.0 Watts
```
