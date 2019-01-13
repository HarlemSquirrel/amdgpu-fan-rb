# frozen_string_literal: true

require 'thor'

# The main class
class AmdgpuFanCli < Thor
  FAN_POWER_FILE = Dir.glob("/sys/class/drm/card0/device/**/pwm1").first
  FAN_MAX_POWER_FILE = Dir.glob("/sys/class/drm/card0/device/**/pwm1_max").first
  FAN_INPUT_FILE = Dir.glob("/sys/class/drm/card0/device/**/fan1_input").first
  FAN_MODE_FILE = Dir.glob("/sys/class/drm/card0/device/**/pwm1_enable").first
  FAN_MODES = { auto: '2', manual: '1' }.freeze
  POWER_MAX_FILE = '/sys/class/drm/card0/device/hwmon/hwmon2/power1_cap'
  POWER_AVG_FILE = '/sys/class/drm/card0/device/hwmon/hwmon2/power1_average'
  TEMPERATURE_FILE = Dir.glob("/sys/class/drm/card0/device/**/temp1_input").first
  VBIOS_VERSION = File.read('/sys/class/drm/card0/device/vbios_version').strip

  desc 'auto', 'Set mode to automatic (requires sudo)'
  def auto
    set_mode(:auto)
  end

  desc 'set PERCENTAGE', 'Set fan speed to PERCENTAGE (requires sudo)'
  def set(percentage)
    return puts "Invalid percentage" unless (0..100).cover?(percentage.to_i)

    set_mode(:manual) unless in_manual_mode?
    puts "Setting fan to #{setting_from_percent percentage}/#{max}..."
    set_manual_speed setting_from_percent(percentage)
  end

  desc 'status', 'View device info, current fan speed, and temperature'
  def status
    print_radeon_logo
    puts "📺\tGPU:   #{device_info}",
         "📄\tvBIOS: #{VBIOS_VERSION}",
         "🌀\tFan:   #{current_mode} mode running at #{current_percentage.round}% ~ #{rpm} rpm",
         "🌡\tTemp:  #{current_temperature}°C",
         "⚡\tPower: #{current_power} / #{power_max} Watts"
  end

  desc 'watch [SECONDS]', 'Watch fan speed, power, and temperature refreshed every n seconds'
  def watch(seconds=1)
    return puts "Seconds must be from 1 to 600" unless (1..600).cover?(seconds.to_i)

    puts "Watching #{device_info} every #{seconds} second(s)...",
         '  <Press Ctrl-C to exit>'

    trap "SIGINT" do
      puts 'And now the watch is ended.'
      exit 0
    end

    loop do
      puts "#{Time.now.strftime("%F %T")} " \
           "Fan: #{current_percentage.round}% ~ #{rpm} rpm, " \
           "Power: #{current_power} W"
           "Temp: #{current_temperature}°C"
      sleep seconds.to_i
    end
  end

  private

  def device_info
    @device_info ||= lspci_subsystem.split(': ')[1].strip
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

  def current_power
    (File.read(POWER_AVG_FILE).strip.to_f / 1000000).round(2)
  end

  def current_temperature
    (File.read(TEMPERATURE_FILE).to_f / 1000).round(1)
  end

  def current_time
    Time.now.strftime("%F %T")
  end

  def gpu_pci_id
    `lspci -v | grep VGA`.split(' ').first
  end

  def lspci_subsystem
    `lspci -v -s #{gpu_pci_id} | grep "Subsystem:"`
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

  def power_max
    @power_max ||= (File.read(POWER_MAX_FILE).strip.to_f / 1000000).round(2)
  end

  def print_radeon_logo
    puts File.read('lib/radeon_r_black_red_100x100.ascii')
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
