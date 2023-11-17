# amdgpu_fan

[![Gem Version](https://badge.fury.io/rb/amdgpu_fan.svg)](https://badge.fury.io/rb/amdgpu_fan)
[![Verify](https://github.com/HarlemSquirrel/amdgpu-fan-rb/actions/workflows/verify.yml/badge.svg)](https://github.com/HarlemSquirrel/amdgpu-fan-rb/actions/workflows/verify.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/27233cee17ef6a2c14fd/maintainability)](https://codeclimate.com/github/HarlemSquirrel/amdgpu-fan-rb/maintainability)

A Ruby CLI to read and set fan speed, power profiles, and more for AMD Radeon graphics cards running on the AMDGPU Linux driver.

**amdgpu_fan** aims to provide a more user friendly interface on top of [sysfs](https://en.wikipedia.org/wiki/Sysfs) for displaying statistics and interacting with AMD Radeon graphics hardware running on the [AMDgpu](https://dri.freedesktop.org/docs/drm/gpu/amdgpu.html) driver.

#### Further reading

- https://wiki.archlinux.org/index.php/AMDGPU#Overclocking
- https://wiki.archlinux.org/index.php/Fan_speed_control#AMDGPU_sysfs_fan_control
- https://phoronix.com/scan.php?page=news_item&px=AMDGPU-Quick-WattMan-Cap-Test

## Installation

The `amdgpu_fan` CLI command can be installed from [RubyGems](https://rubygems.org/gems/amdgpu_fan) or easily run from the source code.

### From RubyGems

```
gem install amdgpu_fan
```

### From Source

```
➤  git clone https://github.com/HarlemSquirrel/amdgpu-fan-rb.git
➤  cd amdgpu-fan-rb
➤  bundle install
➤  bin/amdgpu_fan
```

## Usage

```
➤  bin/amdgpu_fan help
Commands:
  amdgpu_fan connectors                 # View the status of the display connectors.
  amdgpu_fan fan                        # View fan details.
  amdgpu_fan fan_set PERCENTAGE/AUTO    # Set fan speed to percentage or automatic mode. (requires sudo)
  amdgpu_fan help [COMMAND]             # Describe available commands or one specific command
  amdgpu_fan profile                    # View power profile details.
  amdgpu_fan profile_auto               # Set the power profile to automatic mode.
  amdgpu_fan profile_force PROFILE_NUM  # Manually set a power profile. (requires sudo)
  amdgpu_fan status [--logo]            # View device info, current fan speed, and temperature.
  amdgpu_fan watch [SECONDS]            # Watch fan speed, load, power, and temperature refreshed every n seconds.
  amdgpu_fan watch_csv [SECONDS]        # Watch stats in CSV format refreshed every n seconds defaulting to 1 second.

➤  bin/amdgpu_fan status
📺 GPU:    Advanced Micro Devices, Inc. [AMD/ATI] Radeon R9 FURY X / NANO
📄 vBIOS:  113-C8800100-102
⏰ Clocks: 724Mhz Core, 500Mhz Memory
💾 Memory: 4096 MiB
🌀 Fan:    auto mode running at 1809 rpm (48%)
🌞 Temp:   21.0°C
⚡ Power:  3D_FULL_SCREEN profile in performance mode using 16.2 / 300.0 Watts (5%)
⚖  Load:   [                    ]0%

➤  bin/amdgpu_fan watch 3
Watching Advanced Micro Devices, Inc. [AMD/ATI] Radeon R9 FURY X / NANO every 3 second(s)...
  <Press Ctrl-C to exit>
2019-05-28 20:57:41 | Core: 724Mhz   | Memory: 500Mhz  | Fan: 948 rpm  [*         ]14%  | Load: [**        ]24%  | Power: 16.07 W  [*         ]6%   | Temp: 34.0°C
2019-05-28 20:57:45 | Core: 512Mhz   | Memory: 500Mhz  | Fan: 948 rpm  [*         ]14%  | Load: [          ]0%   | Power: 16.13 W  [*         ]7%   | Temp: 34.0°C
2019-05-28 20:57:49 | Core: 892Mhz   | Memory: 500Mhz  | Fan: 948 rpm  [*         ]14%  | Load: [          ]0%   | Power: 25.22 W  [*         ]5%   | Temp: 33.0°C
2019-05-28 20:57:53 | Core: 300Mhz   | Memory: 500Mhz  | Fan: 948 rpm  [*         ]14%  | Load: [          ]0%   | Power: 19.1 W   [*         ]6%   | Temp: 33.0°C
2019-05-28 20:57:57 | Core: 1050Mhz  | Memory: 500Mhz  | Fan: 948 rpm  [*         ]14%  | Load: [********* ]94%  | Power: 103.04 W [***       ]31%  | Temp: 36.0°C
2019-05-28 20:58:01 | Core: 1050Mhz  | Memory: 500Mhz  | Fan: 954 rpm  [**        ]15%  | Load: [********* ]91%  | Power: 158.07 W [*****     ]53%  | Temp: 38.0°C
2019-05-28 20:58:05 | Core: 1050Mhz  | Memory: 500Mhz  | Fan: 977 rpm  [**        ]16%  | Load: [**********]100% | Power: 218.01 W [*******   ]73%  | Temp: 40.0°C
2019-05-28 20:58:09 | Core: 1050Mhz  | Memory: 500Mhz  | Fan: 1005 rpm [**        ]16%  | Load: [**********]100% | Power: 216.24 W [*******   ]71%  | Temp: 40.0°C
2019-05-28 20:58:13 | Core: 1050Mhz  | Memory: 500Mhz  | Fan: 1033 rpm [**        ]17%  | Load: [**********]97%  | Power: 109.25 W [****      ]39%  | Temp: 38.0°C
2019-05-28 20:58:17 | Core: 724Mhz   | Memory: 500Mhz  | Fan: 1058 rpm [**        ]17%  | Load: [          ]0%   | Power: 17.17 W  [*         ]6%   | Temp: 35.0°C
^C
And now the watch is ended.
```

```
➤  bin/amdgpu_fan watch_avg
Watching Sapphire Technology Limited Vega 10 XL/XT [Radeon RX Vega 56/64] min, max and averges since
2020-06-02 23:05:20 -0400...
  <Press Ctrl-C to exit>
⏰ Core clock  min:    852 MHz avg:  887.0 MHz max:   1200 MHz now:    852 MHz
💾 Memory clk  min:    167 MHz avg:  227.1 MHz max:    945 MHz now:    167 MHz
🌀 Fan speed   min:   1231 RPM avg: 1231.0 RPM max:   1231 RPM now:   1231 RPM
⚡ Power usage min:    6.0 W   avg:   21.8 W   max:  141.0 W   now:    6.0 W
🌡  Temperature min:     30 °C  avg:   31.3 °C  max:     35 °C  now:     32 °C
^C
And now the watch is ended.
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
