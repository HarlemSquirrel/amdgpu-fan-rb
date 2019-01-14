# frozen_string_literal: true

require_relative '../config/environment'

# The main class
class AmdgpuFanCli < Thor
  desc 'auto', 'Set mode to automatic (requires sudo)'
  def auto
    amdgpu_service.set_fan_mode! :auto
    puts fan_status
  end

  desc 'set PERCENTAGE', 'Set fan speed to PERCENTAGE (requires sudo)'
  def set(percentage)
    return puts "Invalid percentage" unless (0..100).cover?(percentage.to_i)

    amdgpu_service.set_fan_manual_speed! percent: percentage
    puts fan_status
  end

  desc 'status', 'View device info, current fan speed, and temperature'
  def status
    print_radeon_logo
    puts "📺\tGPU:   #{amdgpu_service.name}",
         "📄\tvBIOS: #{amdgpu_service.vbios_version}",
         fan_status,
         "🌡\tTemp:  #{amdgpu_service.temperature}°C",
         "⚡\tPower: #{amdgpu_service.power_dpm_state} mode using " \
          "#{amdgpu_service.power_draw} / #{amdgpu_service.power_max} Watts",
         "⚖\tLoad: #{amdgpu_service.busy_percent}%"
  end

  desc 'watch [SECONDS]', 'Watch fan speed, load, power, and temperature ' \
       'refreshed every n seconds'
  def watch(seconds=1)
    return puts "Seconds must be from 1 to 600" unless (1..600).cover?(seconds.to_i)

    puts "Watching #{amdgpu_service.name} every #{seconds} second(s)...",
         '  <Press Ctrl-C to exit>'

    trap "SIGINT" do
      puts 'And now the watch is ended.'
      exit 0
    end

    loop do
      puts "#{Time.now.strftime("%F %T")} " \
           "Fan: #{amdgpu_service.fan_speed_rpm} rpm (#{amdgpu_service.fan_speed_percent}%), " \
           "Load: #{amdgpu_service.busy_percent}%, " \
           "Power: #{amdgpu_service.power_draw} W, " \
           "Temp: #{amdgpu_service.temperature}°C "
      sleep seconds.to_i
    end
  end

  private

  def amdgpu_service
    @amdgpu_service ||= AmdgpuService.new
  end

  def current_time
    Time.now.strftime("%F %T")
  end

  def fan_status
    "🌀\tFan:   #{amdgpu_service.fan_mode} mode running at " \
     "#{amdgpu_service.fan_speed_percent}% ~ #{amdgpu_service.fan_speed_rpm} rpm"
  end

  def print_radeon_logo
    puts File.read('lib/radeon_r_black_red_100x100.ascii')
  end
end
