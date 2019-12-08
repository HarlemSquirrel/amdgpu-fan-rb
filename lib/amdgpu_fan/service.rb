# frozen_string_literal: true

require_relative 'mixin/fan'
require_relative 'mixin/sys_write'

require_relative 'connector'

module AmdgpuFan
  ## AmdgpuService
  #
  # A service class for reading and interacting with AMD radeon graphics cards
  # through the amdgpu Linux kernel driver.
  class Service
    include Fan
    include SysWrite

    BASE_FOLDER = '/sys/class/drm'
    FAN_MODES = { '1' => 'manual', '2' => 'auto' }.freeze

    attr_reader :card_num

    class Error < StandardError; end

    def initialize(card_num: 0)
      @card_num = card_num
    end

    def busy_percent
      File.read("#{base_card_dir}/gpu_busy_percent").strip
    end

    def connectors
      @connectors ||= Connector.where card_num: card_num
    end

    def core_clock
      clock_from_pp_file "#{base_card_dir}/pp_dpm_sclk"
    end

    def fan_mode
      FAN_MODES[File.read(fan_mode_file).strip] || 'unknown'
    end

    def fan_mode=(mode)
      sudo_write fan_mode_file, FAN_MODES.key(mode.to_s)
    end

    def fan_speed=(value)
      if valid_fan_percent_speed?(value)
        new_raw = (value.to_f / 100 * fan_raw_speeds(:max).to_i).round
      elsif valid_fan_raw_speed?(value)
        new_raw = value
      end

      raise(self.class::Error, 'Invalid fan speed provided') if new_raw.to_s.empty?

      self.fan_mode = :manual unless fan_mode == 'manual'

      sudo_write fan_power_file, new_raw
    end

    def fan_speed_percent
      (fan_speed_raw.to_f / fan_raw_speeds(:max).to_i * 100).round
    end

    def fan_speed_rpm
      File.read(fan_file(:input)).strip
    end

    def memory_clock
      clock_from_pp_file "#{base_card_dir}/pp_dpm_mclk"
    end

    def memory_total
      File.read("#{base_card_dir}/mem_info_vram_total").to_i
    end

    def name
      lspci_subsystem.split(': ')[1].strip
    end

    def power_dpm_state
      File.read("#{base_card_dir}/power_dpm_state").strip
    end

    def power_draw
      power_raw_to_watts File.read(power_avg_file)
    end

    def power_draw_percent
      (power_draw.to_f / power_max.to_i * 100).round
    end

    def power_max
      @power_max ||= power_raw_to_watts File.read("#{base_hwmon_dir}/power1_cap")
    end

    def profile_auto
      sudo_write "#{base_card_dir}/power_dpm_force_performance_level", 'auto'
    end

    def profile_force=(state)
      sudo_write "#{base_card_dir}/power_dpm_force_performance_level", 'manual'
      sudo_write "#{base_card_dir}/pp_power_profile_mode", state
    end

    def profile_mode
      File.read("#{base_card_dir}/pp_power_profile_mode").slice(/\w+\s*+\*/).delete('*').strip
    end

    def profile_summary
      File.read("#{base_card_dir}/pp_power_profile_mode")
    end

    def temperature
      (File.read(temperature_file).to_f / 1000).round(1)
    end

    def vbios_version
      @vbios_version ||= File.read("#{base_card_dir}/vbios_version").strip
    end

    private

    def base_card_dir
      @base_card_dir ||= "#{BASE_FOLDER}/card#{card_num}/device"
    end

    def base_hwmon_dir
      @base_hwmon_dir ||= Dir.glob("#{base_card_dir}/hwmon/hwmon*").first
    end

    def clock_from_pp_file(file)
      File.read(file).slice(/\w+(?= \*)/)
    end

    def gpu_pci_id
      @gpu_pci_id ||= `lspci -v | grep VGA`.split(' ').first
    end

    def lspci_subsystem
      @lspci_subsystem ||= `lspci -v -s #{gpu_pci_id} | grep "Subsystem:"`
    end

    def power_avg_file
      @power_avg_file ||= Dir.glob("#{base_card_dir}/**/power1_average").first
    end

    def power_raw_to_watts(raw_string)
      (raw_string.strip.to_f / 1_000_000).round(2)
    end

    def temperature_file
      @temperature_file ||= Dir.glob("#{base_card_dir}/**/temp1_input").first
    end
  end
end
