# frozen_string_literal: true

require 'thor'

# The main class
class AmdgpuFanCli < Thor
  FAN_POWER_FILE = '/sys/class/drm/card0/device/hwmon/hwmon2/pwm1'

  desc 'set PERCENTAGE', 'set fan speed to PERCENTAGE'
  def set(percentage)
    return unless (0..100).cover?(percentage.to_i)
    puts "Setting fan to #{setting_from_percent percentage}/#{max}..."
    `sudo su -c "echo #{setting_from_percent percentage} > #{FAN_POWER_FILE}"`
  end

  desc 'status', 'report the current status'
  def status
    puts device_info,
         "GPU fan running at #{current_percentage.round}% ~ #{rpm} rpm"
  end

  private

  def device_info
    @device_info ||= `glxinfo | grep -m 1 -o "AMD Radeon .* Series"`.strip
  end

  def current
    `cat #{FAN_POWER_FILE}`
  end

  def current_percentage
    current.to_f / max.to_i * 100
  end

  def max
    @max ||= `cat /sys/class/drm/card0/device/hwmon/hwmon2/pwm1_max`.to_i
  end

  def rpm
    `cat /sys/class/drm/card0/device/hwmon/hwmon2/fan1_input`.strip
  end

  def setting_from_percent(percent)
    (percent.to_f / 100 * max.to_i).round
  end
end
