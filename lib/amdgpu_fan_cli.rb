# frozen_string_literal: true

require 'thor'

# The main class
class AmdgpuFanCli < Thor
  FAN_POWER_FILE = Dir.glob("/sys/class/drm/card0/device/**/pwm1").first
  FAN_MAX_POWER_FILE = Dir.glob("/sys/class/drm/card0/device/**/pwm1_max").first
  FAN_INPUT_FILE = Dir.glob("/sys/class/drm/card0/device/**/fan1_input").first
  FAN_MODE_FILE = Dir.glob("/sys/class/drm/card0/device/**/pwm1_enable").first
  FAN_MODES = { auto: '2', manual: '1' }.freeze

  desc 'auto', 'set mode to automatic (requires sudo)'
  def auto
    set_mode(:auto)
  end

  desc 'set PERCENTAGE', 'set fan speed to PERCENTAGE (requires sudo)'
  def set(percentage)
    return puts "Invalid percentage" unless (0..100).cover?(percentage.to_i)
    set_mode(:manual) unless in_manual_mode?
    puts "Setting fan to #{setting_from_percent percentage}/#{max}..."
    set_manual_speed setting_from_percent(percentage)
  end

  desc 'status', 'report the current status'
  def status
    puts device_info,
         "GPU fan in #{current_mode} mode running at #{current_percentage.round}% ~ #{rpm} rpm"
  end

  private

  def device_info
    @device_info ||= `glxinfo | grep -m 1 -o "AMD Radeon .* Series"`.strip
  end

  def current
    File.read FAN_POWER_FILE
  end

  def current_mode
    case File.read(FAN_MODE_FILE).strip
    when '1'
      'manual'
    when '2'
      'auto'
    else
      'unknown'
    end
  end

  def current_percentage
    current.to_f / max.to_i * 100
  end

  def max
    @max ||= File.read(FAN_MAX_POWER_FILE).to_i
  end

  def in_auto_mode?
    File.read(FAN_MODE_FILE).strip == '2'
  end

  def in_manual_mode?
    File.read(FAN_MODE_FILE).strip == '1'
  end

  def rpm
    File.read(FAN_INPUT_FILE).strip
  end

  def set_mode(mode)
    puts "Setting mode to #{mode}"
    `echo "#{FAN_MODES[mode]}" | sudo tee #{FAN_MODE_FILE}`
  end

  def set_manual_speed(speed)
    `echo "#{speed}" | sudo tee #{FAN_POWER_FILE}`
  end

  def setting_from_percent(percent)
    (percent.to_f / 100 * max.to_i).round
  end
end
