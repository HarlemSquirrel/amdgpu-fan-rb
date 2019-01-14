# frozen_string_literal: true

## AmdgpuService
#
# A service class for reading and interacting with AMD radeon graphics cards
# through the amdgpu Linux kernel driver.
class AmdgpuService
  BASE_FOLDER = '/sys/class/drm'
  FAN_MODES = { '1' => 'manual', '2' => 'auto' }.freeze

  attr_reader :card_num

  def initialize(card_num: 0)
    @card_num = card_num
  end

  def busy_percent
    File.read("#{base_card_folder}/gpu_busy_percent").strip
  end

  def fan_mode
    FAN_MODES[File.read(fan_mode_file).strip] || 'unknown'
  end

  def set_fan_mode!(mode)
    `echo "#{FAN_MODES.key(mode.to_s)}" | sudo tee #{fan_mode_file}`
  end

  def fan_speed_percent
    (fan_speed_raw.to_f / fan_speed_raw_max.to_i * 100).round
  end

  def fan_speed_raw_max
    @fan_speed_raw_max ||= File.read("#{fan_power_file}_max").strip
  end

  def fan_speed_rpm
    File.read(fan_input_file).strip
  end

  def name
    lspci_subsystem.split(': ')[1].strip
  end

  def power_dpm_state
    File.read("#{base_card_folder}/power_dpm_state").strip
  end

  def power_draw
    power_raw_to_watts File.read(power_avg_file)
  end

  def power_max
    @power_max ||= power_raw_to_watts File.read(power_max_file)
  end

  def set_fan_manual_speed!(percent: nil, raw: nil)
    if valid_fan_percent_speed?(percent)
      new_raw = (percent.to_f / 100 * fan_speed_raw_max.to_i).round
    elsif valid_fan_raw_speed?(raw)
      new_raw = raw
    end

    raise(::Error, 'Invalid fan speed provided') unless defined?(new_raw)

    set_fan_mode!(:manual) unless fan_mode == 'manual'

    `echo "#{new_raw}" | sudo tee #{fan_power_file}`
  end

  def temperature
    (File.read(temperature_file).to_f / 1000).round(1)
  end

  def vbios_version
    @vbios_version ||= File.read("#{base_card_folder}/vbios_version").strip
  end

  private

  def base_card_folder
    @base_card_folder ||= "#{BASE_FOLDER}/card#{card_num}/device"
  end

  def fan_input_file
    @fan_input_file ||= Dir.glob("#{base_card_folder}/**/fan1_input").first
  end

  def fan_mode_file
    @fan_mode_file ||= Dir.glob("#{base_card_folder}/**/pwm1_enable").first
  end

  def fan_power_file
    @fan_power_file ||= Dir.glob("#{base_card_folder}/**/pwm1").first
  end

  def fan_speed_raw
    File.read(fan_power_file).strip
  end

  def gpu_pci_id
    @gpu_pci_id ||= `lspci -v | grep VGA`.split(' ').first
  end

  def lspci_subsystem
    @lspci_subsystem ||= `lspci -v -s #{gpu_pci_id} | grep "Subsystem:"`
  end

  def power_avg_file
    @power_avg_file ||= Dir.glob("#{base_card_folder}/**/power1_average").first
  end

  def power_max_file
    @power_avg_file ||= Dir.glob("#{base_card_folder}/**/power1_cap").first
  end

  def power_raw_to_watts(raw_string)
    (raw_string.strip.to_f / 1_000_000).round(2)
  end

  def temperature_file
    @temperature_file ||= Dir.glob("#{base_card_folder}/**/temp1_input").first
  end

  def valid_fan_raw_speed?(raw)
    (1..fan_speed_raw_max.to_i).include?(raw.to_i)
  end

  def valid_fan_percent_speed?(percent)
    (1..100.to_i).include?(percent.to_i)
  end

  class Error < StandardError; end
end
