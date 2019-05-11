# amdgpu-fan-rb

[![Build Status](https://travis-ci.org/HarlemSquirrel/amdgpu-fan-rb.svg?branch=master)](https://travis-ci.org/HarlemSquirrel/amdgpu-fan-rb)

A Ruby CLI to read and set the fan speed for AMD Radeon graphics cards running on the AMDGPU Linux driver.

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
➤  amdgpu_fan help
Commands:
  amdgpu_fan auto             # Set mode to automatic (requires sudo)
  amdgpu_fan help [COMMAND]   # Describe available commands or one specific command
  amdgpu_fan set PERCENTAGE   # Set fan speed to PERCENTAGE (requires sudo)
  amdgpu_fan status           # View device info, current fan speed, and temperature
  amdgpu_fan watch [SECONDS]  # Watch current fan speed, and temperature refreshed every n seconds

➤  amdgpu_fan status
📺	GPU:   AMD Radeon (TM) R9 Fury Series
📄	vBIOS: 113-C8800100-102
🌀	Fan:   auto mode running at 48% ~ 1828 rpm
🌡	Temp:  28.0°C
⚡	Power: 19.26 / 300.0 Watts

➤  bin/amdgpu_fan watch 3
Watching Advanced Micro Devices, Inc. [AMD/ATI] Radeon R9 FURY X / NANO every 3 second(s)...
  <Press Ctrl-C to exit>
2019-05-10 20:36:01 - Clock: 512Mhz Core, 500Mhz Memory,        Fan: 1838 rpm [|||       ]27%,  Load: [|||       ]28%,  Power: 15.12 W, Temp: 28.0°C
2019-05-10 20:36:05 - Clock: 300Mhz Core, 500Mhz Memory,        Fan: 1837 rpm [|||||     ]49%,  Load: [          ]0%,   Power: 16.18 W, Temp: 29.0°C
2019-05-10 20:36:09 - Clock: 512Mhz Core, 500Mhz Memory,        Fan: 1837 rpm [|||||     ]49%,  Load: [          ]0%,   Power: 15.11 W, Temp: 28.0°C
^C
And now the watch is ended.
```

## Dependencies

- [Ruby](https://www.ruby-lang.org) with [Bundler](https://bundler.io)
- [Thor](http://whatisthor.com/) (installed with `bundle install`)
- [`lspci`](https://linux.die.net/man/8/lspci) (included with most Linux distributions)
