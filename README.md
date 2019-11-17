# amdgpu-fan-rb

[![Build Status](https://travis-ci.org/HarlemSquirrel/amdgpu-fan-rb.svg?branch=master)](https://travis-ci.org/HarlemSquirrel/amdgpu-fan-rb) [![Maintainability](https://api.codeclimate.com/v1/badges/27233cee17ef6a2c14fd/maintainability)](https://codeclimate.com/github/HarlemSquirrel/amdgpu-fan-rb/maintainability)

A Ruby CLI to read and set fan speed, power profiles, and more for AMD Radeon graphics cards running on the AMDGPU Linux driver.

See https://wiki.archlinux.org/index.php/Fan_speed_control#AMDGPU_sysfs_fan_control

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
➤  bin/amdgpu_fan
Commands:
  amdgpu_fan auto                         # Set fan mode to automatic (requires sudo)
  amdgpu_fan connectors                   # View the status of the display connectors
  amdgpu_fan help [COMMAND]               # Describe available commands or one specific command
  amdgpu_fan profile                      # View power profile details.
  amdgpu_fan profile_auto                 # Set the power profile to automatic mode.
  amdgpu_fan profile_force [PROFILE_NUM]  # Manually set a power profile.
  amdgpu_fan set PERCENTAGE               # Set fan speed to PERCENTAGE (requires sudo)
  amdgpu_fan status [--logo]              # View device info, current fan speed, and temperature
  amdgpu_fan watch [SECONDS]              # Watch fan speed, load, power, and temperature refreshed every n seconds
  amdgpu_fan watch_csv [SECONDS]          # Watch stats in CSV format refreshed every n seconds defaulting to 1 second

➤  amdgpu_fan status
📺	GPU:   AMD Radeon (TM) R9 Fury Series
📄	vBIOS: 113-C8800100-102
🌀	Fan:   auto mode running at 48% ~ 1828 rpm
🌡	Temp:  28.0°C
⚡	Power: 19.26 / 300.0 Watts

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

## Dependencies

- [Ruby](https://www.ruby-lang.org) with [Bundler](https://bundler.io)
- [Thor](http://whatisthor.com/) (installed with `bundle install`)
- [`lspci`](https://linux.die.net/man/8/lspci) (included with most Linux distributions)
