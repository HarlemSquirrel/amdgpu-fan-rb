# amdgpu_fan

[![Gem Version](https://badge.fury.io/rb/amdgpu_fan.svg)](https://badge.fury.io/rb/amdgpu_fan)
[![Verify](https://github.com/HarlemSquirrel/amdgpu-fan-rb/actions/workflows/verify.yml/badge.svg)](https://github.com/HarlemSquirrel/amdgpu-fan-rb/actions/workflows/verify.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/27233cee17ef6a2c14fd/maintainability)](https://codeclimate.com/github/HarlemSquirrel/amdgpu-fan-rb/maintainability)

A Ruby CLI to read and set fan speed, power profiles, and more for AMD Radeon graphics cards running on the AMDGPU Linux driver.

**amdgpu_fan** aims to provide a more user friendly interface on top of [sysfs](https://en.wikipedia.org/wiki/Sysfs) for displaying statistics and interacting with AMD Radeon graphics hardware running on the [AMDgpu](https://dri.freedesktop.org/docs/drm/gpu/amdgpu.html) driver.

#### Further reading
e
- https://wiki.archlinux.org/index.php/AMDGPU#Overclocking
- https://wiki.archlinux.org/index.php/Fan_speed_control#AMDGPU_sysfs_fan_control
- https://phoronix.com/scan.php?page=news_item&px=AMDGPU-Quick-WattMan-Cap-Test

## Installation

The `amdgpu_fan` CLI command can be installed in [Arch Linux from the AUR](https://aur.archlinux.org/packages/ruby-amdgpu_fan), from [RubyGems](https://rubygems.org/gems/amdgpu_fan), or run from the source code.

### Arch User Repository

Use your favorite tool such as [`paru`](https://aur.archlinux.org/packages/paru) to install [`ruby-amdgrpu_fan`](https://aur.archlinux.org/packages/ruby-amdgpu_fan) from the AUR.

```sh
paru -S ruby-amdgpu_fan
```

### From RubyGems

```sh
gem install amdgpu_fan
```

### From Source

```sh
git clone https://github.com/HarlemSquirrel/amdgpu-fan-rb.git
cd amdgpu-fan-rb
bundle install
bin/amdgpu_fan
```

## Usage

```
➤  bin/amdgpu_fan help
Commands:
  amdgpu_fan connectors                 # View the status of the display connectors.
  amdgpu_fan fan                        # View fan details.
  amdgpu_fan fan_set PERCENTAGE/AUTO    # Set fan speed to percentage or automatic mode. (requires sudo)
  amdgpu_fan help [COMMAND]             # Describe available commands or one specific command
  amdgpu_fan power_mode_auto            # Set the power profile to automatic mode.
  amdgpu_fan power_mode_high            # Set the performance level to low to force the clocks to the highest power state.
  amdgpu_fan power_mode_low             # Set the performance level to low to force the clocks to the lowest power state.
  amdgpu_fan profile                    # View power profile details.
  amdgpu_fan profile_force PROFILE_NUM  # Set performance mode to manual and set a power profile. (requires sudo)
  amdgpu_fan status [--logo]            # View device info, current fan speed, and temperature.
  amdgpu_fan version                    # Print the application version.
  amdgpu_fan watch [SECONDS]            # Watch fan speed, load, power, and temperature refreshed every n seconds.
  amdgpu_fan watch_avg                  # Watch min, max, average, and current stats.
  amdgpu_fan watch_csv [SECONDS]        # Watch stats in CSV format refreshed every n seconds defaulting to 1 second.

➤  bin/amdgpu_fan status
👾 GPU:      Advanced Micro Devices, Inc. [AMD/ATI] NITRO+ RX 7900 XTX Vapor-X
📄 vBIOS:    113-4E4710U-T4Y
📺 Displays: G321CQP E2
⏰ Clocks:   67 Core, 456 Memory
💾 Memory:   24560 MiB
🌀 Fan:      auto mode running at 0 rpm (0%)
🧯 Temp:     46.0°C
⚡ Power:    3D_FULL_SCREEN profile in auto mode using 35.0 / 339.0 Watts (10%)
🚚 Load:     00% [            ]

➤  bin/amdgpu_fan watch 3
Watching Advanced Micro Devices, Inc. [AMD/ATI] NITRO+ RX 7900 XTX Vapor-X every 3 second(s)...
  <Press Ctrl-C to exit>
2025-05-31 15:02:48 | Core:      41 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 00% [   ] | Power:  34.00 W 10% [▎  ] | Temp:  45.0°C
2025-05-31 15:02:51 | Core:       3 | Memory:      96 | Fan:    0 rpm 00% [   ] | Load: 00% [   ] | Power:  22.00 W 06% [▏  ] | Temp:  45.0°C
2025-05-31 15:02:54 | Core:       2 | Memory:      96 | Fan:    0 rpm 00% [   ] | Load: 00% [   ] | Power:  11.00 W 03% [▏  ] | Temp:  45.0°C
2025-05-31 15:02:57 | Core:      55 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 04% [▏  ] | Power:  38.00 W 11% [▍  ] | Temp:  45.0°C
2025-05-31 15:03:00 | Core:      63 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 04% [▏  ] | Power:  33.00 W 10% [▎  ] | Temp:  45.0°C
2025-05-31 15:03:03 | Core:      51 | Memory:      96 | Fan:    0 rpm 00% [   ] | Load: 03% [▏  ] | Power:  32.00 W 09% [▎  ] | Temp:  45.0°C
2025-05-31 15:03:06 | Core:      63 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 04% [▏  ] | Power:  33.00 W 10% [▎  ] | Temp:  45.0°C
2025-05-31 15:03:09 | Core:      79 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 05% [▏  ] | Power:  34.00 W 10% [▎  ] | Temp:  45.0°C
2025-05-31 15:03:12 | Core:      96 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 06% [▏  ] | Power:  35.00 W 10% [▎  ] | Temp:  45.0°C
2025-05-31 15:03:15 | Core:      94 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 05% [▏  ] | Power:  34.00 W 10% [▎  ] | Temp:  46.0°C
2025-05-31 15:03:18 | Core:      95 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 05% [▏  ] | Power:  34.00 W 10% [▎  ] | Temp:  46.0°C
2025-05-31 15:03:21 | Core:      60 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 03% [▏  ] | Power:  33.00 W 10% [▎  ] | Temp:  45.0°C
2025-05-31 15:03:24 | Core:      71 | Memory:      96 | Fan:    0 rpm 00% [   ] | Load: 04% [▏  ] | Power:  31.00 W 09% [▎  ] | Temp:  45.0°C
2025-05-31 15:03:27 | Core:      68 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 03% [▏  ] | Power:  33.00 W 10% [▎  ] | Temp:  46.0°C
2025-05-31 15:03:30 | Core:     219 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 15% [▌  ] | Power:  36.00 W 11% [▍  ] | Temp:  46.0°C
2025-05-31 15:03:33 | Core:    1328 | Memory:     772 | Fan:    0 rpm 00% [   ] | Load: 21% [▋  ] | Power:  43.00 W 12% [▍  ] | Temp:  46.0°C
2025-05-31 15:03:36 | Core:    1241 | Memory:     772 | Fan:    0 rpm 00% [   ] | Load: 32% [█  ] | Power:  55.00 W 16% [▌  ] | Temp:  46.0°C
2025-05-31 15:03:39 | Core:     216 | Memory:     456 | Fan:    0 rpm 00% [   ] | Load: 15% [▌  ] | Power:  38.00 W 11% [▍  ] | Temp:  46.0°C
^C
And now the watch is ended.
```

```
➤  bin/amdgpu_fan watch_avg
Watching Advanced Micro Devices, Inc. [AMD/ATI] NITRO+ RX 7900 XTX Vapor-X min, max and averges since 2025-05-31 15:04:22 -0400...
🚚 Load        min:      0 %   avg:    5.9 %   max:     27 %   now:      3 %
⏰ Core clock  min:      2 MHz avg:  202.4 MHz max:   1337 MHz now:     51 MHz
💾 Memory clk  min:    456 MHz avg:  501.2 MHz max:    772 MHz now:    456 MHz
🌀 Fan speed   min:      0 RPM avg:    0.0 RPM max:      0 RPM now:      0 RPM
⚡ Power usage min:   30.0 W   avg:   35.4 W   max:   51.0 W   now:   33.0 W
🧯 Temperature min:   46.0 °C  avg:   46.0 °C  max:   47.0 °C  now:   46.0 °C
^C
And now the watch is ended
```

## Dependencies

- [Ruby](https://www.ruby-lang.org) with [Bundler](https://bundler.io)
- [Thor](http://whatisthor.com/) (installed with `bundle install`)
- Internet connection - Device info is retrieved from https://pci-ids.ucw.cz/

## Building a binary

[Ruby Packer](https://github.com/pmq20/ruby-packer) provides a convenient way to compile this into a single executable. For the best results, compile Ruby Packer from source from the lastest master branch.

```sh
rubyc amdgpu_fan --output amdgpu_fan
```
