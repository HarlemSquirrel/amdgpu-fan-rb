# frozen_string_literal: true

class AmdgpuService
  FAN_MODES = { '1' => 'manual', '2' => 'auto' }.freeze

  attr_reader :card_num

  def initialize(card_num: 0)
    @card_num = card_num
  end

  def busy_percent
    File.read("/sys/class/drm/card#{card_num}/device/gpu_busy_percent").strip
  end

  def fan_mode
    FAN_MODES[File.read(fan_mode_file).strip] || 'unknown'
  end

  def name
    lspci_subsystem.split(': ')[1].strip
  end

  def power_dpm_state
    File.read("/sys/class/drm/card#{card_num}/device/power_dpm_state").strip
  end

  def set_mode!(mode)
    puts "Setting mode to #{mode}"
    `echo "#{FAN_MODES.key(mode.to_s)}" | sudo tee #{fan_mode_file}`
  end

  def temperature
    (File.read(temperature_file).to_f / 1000).round(1)
  end

  def vbios_version
    File.read("/sys/class/drm/card#{card_num}/device/vbios_version").strip
  end

  private

  def fan_mode_file
    Dir.glob("/sys/class/drm/card#{card_num}/device/**/pwm1_enable").first
  end

  def gpu_pci_id
    `lspci -v | grep VGA`.split(' ').first
  end

  def lspci_subsystem
    `lspci -v -s #{gpu_pci_id} | grep "Subsystem:"`
  end

  def temperature_file
    Dir.glob("/sys/class/drm/card#{card_num}/device/**/temp1_input").first
  end
end
