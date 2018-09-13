# frozen_string_literal: true

require 'thor'

# The main class
class AmdgpuFanCli < Thor
  FAN_POWER_FILE = Dir.glob("/sys/class/drm/card0/device/**/pwm1").first
  FAN_MAX_POWER_FILE = Dir.glob("/sys/class/drm/card0/device/**/pwm1_max").first
  FAN_INPUT_FILE = Dir.glob("/sys/class/drm/card0/device/**/fan1_input").first
  FAN_MODE_FILE = Dir.glob("/sys/class/drm/card0/device/**/pwm1_enable").first

  desc 'auto', 'set mode to automatic'
  def auto
    puts "Setting fan mode to automatic..."
    `sudo su -c "echo 2 > #{FAN_MODE_FILE}"`
  end

  desc 'set PERCENTAGE', 'set fan speed to PERCENTAGE'
  def set(percentage)
    return unless (0..100).cover?(percentage.to_i)
    puts "Setting fan to #{setting_from_percent percentage}/#{max}..."
    `sudo su -c "echo #{setting_from_percent percentage} > #{FAN_POWER_FILE}"`
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

  def rpm
    File.read(FAN_INPUT_FILE).strip
  end

  def setting_from_percent(percent)
    (percent.to_f / 100 * max.to_i).round
  end
end
