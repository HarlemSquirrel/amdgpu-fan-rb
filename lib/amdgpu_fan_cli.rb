require 'thor'

class AmdgpuFanCli < Thor
  desc "set PERCENTAGE", "set fan speed to PERCENTAGE"
  def set(percentage)
    return unless (0..100).include?(percentage.to_i)
    puts "Setting fan to #{setting_from_percent percentage}/#{max}..."
    `sudo su -c "echo #{setting_from_percent percentage} > /sys/class/drm/card0/device/hwmon/hwmon2/pwm1"`
  end

  desc 'status', 'report the current status'
  def status
    puts "GPU fan running at #{current_percentage.round}%"
  end

  private

  def current
    `cat /sys/class/drm/card0/device/hwmon/hwmon2/pwm1`
  end

  def current_percentage
    current.to_f / max.to_i * 100
  end

  def max
    @max ||= `cat /sys/class/drm/card0/device/hwmon/hwmon2/pwm1_max`
  end

  def setting_from_percent(percent)
    (percent.to_f / 100 * max.to_i).round
  end
end
